param(
    [string]$RepoRoot = "",
    [string]$PolicyPath = "",
    [string]$ReportPath = "",
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-RepoRoot([string]$startPath) {
    $cursor = (Resolve-Path $startPath).Path
    while ($true) {
        if (Test-Path (Join-Path $cursor "openclaw.json")) {
            return $cursor
        }
        $parent = Split-Path -Path $cursor -Parent
        if ([string]::IsNullOrWhiteSpace($parent) -or $parent -eq $cursor) {
            throw "Cannot locate repository root from start path: $startPath"
        }
        $cursor = $parent
    }
}

function Normalize-RelPath([string]$path) {
    return ($path -replace "\\", "/").Trim()
}

function Parse-GitStatusLine([string]$line) {
    if ([string]::IsNullOrWhiteSpace($line) -or $line.Length -lt 4) {
        return $null
    }

    $x = $line.Substring(0, 1)
    $y = $line.Substring(1, 1)
    $payload = $line.Substring(3)

    if ($payload -match " -> ") {
        $parts = $payload -split " -> ", 2
        return [ordered]@{
            x = $x
            y = $y
            oldPath = Normalize-RelPath $parts[0]
            newPath = Normalize-RelPath $parts[1]
            isRename = $true
        }
    }

    return [ordered]@{
        x = $x
        y = $y
        path = Normalize-RelPath $payload
        isRename = $false
    }
}

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = Resolve-RepoRoot -startPath $PSScriptRoot
} else {
    $RepoRoot = (Resolve-Path $RepoRoot).Path
}

if ([string]::IsNullOrWhiteSpace($PolicyPath)) {
    $PolicyPath = Join-Path $RepoRoot "Xuanzhi-Dev/testing/policies/execution-guardrails.json"
} else {
    $PolicyPath = (Resolve-Path $PolicyPath).Path
}

if (-not (Test-Path $PolicyPath)) {
    throw "Missing policy file: $PolicyPath"
}

$policy = Get-Content -Path $PolicyPath -Raw | ConvertFrom-Json
$boundaries = $policy.change_boundaries

$statusLines = @()
$statusRaw = git -C $RepoRoot status --porcelain=v1 --untracked-files=all
if ($LASTEXITCODE -ne 0) {
    throw "git status failed under $RepoRoot"
}
if ($null -ne $statusRaw) {
    $statusLines = @($statusRaw | Where-Object { $_.Trim().Length -gt 0 })
}

$newRootFiles = @()
$invalidTestPaths = @()
$emptyNewFiles = @()
$reportMissingSections = @()
$reportForbiddenHits = @()
$smokeOnlyWithoutEvidence = @()
$checkedPaths = @()

$allowRoot = @()
if ($null -ne $boundaries.allow_new_repo_root_files) {
    $allowRoot = @($boundaries.allow_new_repo_root_files | ForEach-Object { Normalize-RelPath ([string]$_) })
}

$testPrefix = Normalize-RelPath ([string]$boundaries.test_related_must_live_under)
$testPathMarkers = @($boundaries.test_related_path_markers | ForEach-Object { [string]$_ })
$testFileMarkers = @($boundaries.test_related_file_markers | ForEach-Object { [string]$_ })

foreach ($line in $statusLines) {
    $parsed = Parse-GitStatusLine $line
    if ($null -eq $parsed) { continue }

    $pathsToCheck = @()
    $isNew = $false
    if ($parsed.isRename) {
        $pathsToCheck += [string]$parsed.newPath
        $isNew = ($parsed.x -eq "R")
    } else {
        $pathsToCheck += [string]$parsed.path
        $isNew = ($parsed.x -eq "A" -or $parsed.x -eq "?" -or $parsed.y -eq "A")
    }

    foreach ($rel in $pathsToCheck) {
        if ([string]::IsNullOrWhiteSpace($rel)) { continue }
        $checkedPaths += $rel

        $isRootFile = ($rel -notmatch "/")
        if ($isNew -and [bool]$boundaries.forbid_new_repo_root_files -and $isRootFile -and ($allowRoot -notcontains $rel)) {
            $newRootFiles += $rel
        }

        $markerHit = $false
        $pathTokens = $rel.ToLowerInvariant().Split("/")
        foreach ($mk in $testPathMarkers) {
            if ($pathTokens -contains $mk.ToLowerInvariant()) {
                $markerHit = $true
                break
            }
        }
        if (-not $markerHit) {
            $lowerRel = $rel.ToLowerInvariant()
            foreach ($fmk in $testFileMarkers) {
                if ($lowerRel.Contains($fmk.ToLowerInvariant())) {
                    $markerHit = $true
                    break
                }
            }
        }

        if ($markerHit -and -not $rel.StartsWith($testPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            $invalidTestPaths += $rel
        }

        if ($isNew -and [bool]$boundaries.forbid_empty_new_files) {
            $abs = Join-Path $RepoRoot ($rel -replace "/", "\")
            if (Test-Path $abs) {
                $item = Get-Item $abs
                if (-not $item.PSIsContainer -and $item.Length -eq 0) {
                    $emptyNewFiles += $rel
                }
            }
        }
    }
}

$reportChecked = $false
if (-not [string]::IsNullOrWhiteSpace($ReportPath)) {
    $reportChecked = $true
    $resolvedReport = (Resolve-Path $ReportPath).Path
    $reportText = Get-Content -Path $resolvedReport -Raw
    $reportLower = $reportText.ToLowerInvariant()

    foreach ($sec in @($policy.reporting_guardrails.required_sections)) {
        if (-not $reportText.Contains([string]$sec)) {
            $reportMissingSections += [string]$sec
        }
    }

    foreach ($term in @($policy.reporting_guardrails.forbidden_terms)) {
        if ($reportLower.Contains(([string]$term).ToLowerInvariant())) {
            $reportForbiddenHits += [string]$term
        }
    }

    if (
        $null -ne $policy.verification_guardrails -and
        [bool]$policy.verification_guardrails.forbidden_completion_if_only_smoke
    ) {
        $smokeMarkers = @($policy.verification_guardrails.smoke_markers | ForEach-Object { ([string]$_).ToLowerInvariant() })
        $realMarkers = @($policy.verification_guardrails.required_real_verification_markers | ForEach-Object { [string]$_ })
        $smokeHit = $false
        foreach ($mk in $smokeMarkers) {
            if ($reportLower.Contains($mk)) {
                $smokeHit = $true
                break
            }
        }

        if ($smokeHit) {
            $hasRealEvidence = $false
            foreach ($ev in $realMarkers) {
                if ($reportText.Contains($ev)) {
                    $hasRealEvidence = $true
                    break
                }
            }

            if (-not $hasRealEvidence) {
                $smokeOnlyWithoutEvidence += (Normalize-RelPath $ReportPath)
            }
        }
    }
}

$passed = (
    $newRootFiles.Count -eq 0 -and
    $invalidTestPaths.Count -eq 0 -and
    $emptyNewFiles.Count -eq 0 -and
    $reportMissingSections.Count -eq 0 -and
    $reportForbiddenHits.Count -eq 0 -and
    $smokeOnlyWithoutEvidence.Count -eq 0
)

$result = [ordered]@{
    repoRoot = $RepoRoot
    policyPath = $PolicyPath
    reportChecked = $reportChecked
    checkedPathCount = @($checkedPaths | Sort-Object -Unique).Count
    violations = [ordered]@{
        newRepoRootFiles = $newRootFiles | Sort-Object -Unique
        testFilesOutsideTestingRoot = $invalidTestPaths | Sort-Object -Unique
        emptyNewFiles = $emptyNewFiles | Sort-Object -Unique
        reportMissingSections = $reportMissingSections | Sort-Object -Unique
        reportForbiddenTerms = $reportForbiddenHits | Sort-Object -Unique
        smokeOnlyWithoutRealEvidence = $smokeOnlyWithoutEvidence | Sort-Object -Unique
    }
    passed = $passed
    timestamp = (Get-Date).ToString("o")
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 8
    exit 0
}

Write-Host "Execution guardrails validation"
Write-Host "Repo root: $RepoRoot"
Write-Host "Checked changed paths: $($result.checkedPathCount)"
Write-Host "- new root files: $(@($result.violations.newRepoRootFiles).Count)"
Write-Host "- test paths outside Xuanzhi-Dev/testing: $(@($result.violations.testFilesOutsideTestingRoot).Count)"
Write-Host "- empty new files: $(@($result.violations.emptyNewFiles).Count)"
if ($reportChecked) {
    Write-Host "- report missing sections: $(@($result.violations.reportMissingSections).Count)"
    Write-Host "- report forbidden terms: $(@($result.violations.reportForbiddenTerms).Count)"
    Write-Host "- smoke-only without real evidence: $(@($result.violations.smokeOnlyWithoutRealEvidence).Count)"
}
Write-Host "PASSED: $($result.passed)"
