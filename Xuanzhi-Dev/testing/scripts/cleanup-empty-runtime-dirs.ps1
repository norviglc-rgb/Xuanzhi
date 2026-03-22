param(
    [string]$RepoRoot = "",
    [switch]$Apply,
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

function Normalize-Rel([string]$base, [string]$target) {
    $uriBase = [System.Uri]((Resolve-Path $base).Path + [System.IO.Path]::DirectorySeparatorChar)
    $uriTarget = [System.Uri](Resolve-Path $target).Path
    $rel = $uriBase.MakeRelativeUri($uriTarget).ToString()
    return ($rel -replace "\\", "/")
}

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = Resolve-RepoRoot -startPath $PSScriptRoot
} else {
    $RepoRoot = (Resolve-Path $RepoRoot).Path
}

$protected = New-Object "System.Collections.Generic.HashSet[string]" ([System.StringComparer]::OrdinalIgnoreCase)

foreach ($name in @(".git", ".claude", ".codex", "Xuanzhi-Dev")) {
    [void]$protected.Add($name)
}

$openclawPath = Join-Path $RepoRoot "openclaw.json"
if (Test-Path $openclawPath) {
    $oc = Get-Content -Path $openclawPath -Raw | ConvertFrom-Json
    foreach ($agent in @($oc.agents.list)) {
        foreach ($key in @("workspace", "agentDir")) {
            $raw = [string]$agent.$key
            if ([string]::IsNullOrWhiteSpace($raw)) { continue }
            $resolved = $raw
            if ($raw.StartsWith("~/.openclaw/")) {
                $resolved = Join-Path $RepoRoot ($raw.Substring("~/.openclaw/".Length))
            } elseif (-not [System.IO.Path]::IsPathRooted($raw)) {
                $resolved = Join-Path $RepoRoot $raw
            }
            if (Test-Path $resolved) {
                $rel = Normalize-Rel -base $RepoRoot -target $resolved
                [void]$protected.Add($rel)
            }
        }
    }
}

$integrityPolicyPath = Join-Path $RepoRoot "hooks/workspace-integrity/control-policy.json"
if (Test-Path $integrityPolicyPath) {
    $wp = Get-Content -Path $integrityPolicyPath -Raw | ConvertFrom-Json
    foreach ($workspaceName in @($wp.managedWorkspaces)) {
        foreach ($requiredDir in @($wp.requiredDirs)) {
            $full = Join-Path (Join-Path $RepoRoot ([string]$workspaceName)) ([string]$requiredDir)
            if (Test-Path $full) {
                $rel = Normalize-Rel -base $RepoRoot -target $full
                [void]$protected.Add($rel)
            }
        }
    }
}

$emptyDirs = Get-ChildItem -Path $RepoRoot -Directory -Recurse | Where-Object {
    $_.FullName -notmatch "\\.git(\\|$)" -and
    $_.FullName -notmatch "\\.codex(\\|$)" -and
    $_.FullName -notmatch "\\.claude(\\|$)" -and
    $_.FullName -notmatch "Xuanzhi-Dev(\\|$)" -and
    (Get-ChildItem -Force -LiteralPath $_.FullName | Measure-Object).Count -eq 0
}

$deletable = @()
$protectedHits = @()

foreach ($dir in $emptyDirs | Sort-Object { $_.FullName.Length } -Descending) {
    $rel = Normalize-Rel -base $RepoRoot -target $dir.FullName
    $isProtected = $false
    foreach ($p in $protected) {
        if ($rel -eq $p -or $rel.StartsWith($p + "/", [System.StringComparison]::OrdinalIgnoreCase)) {
            $isProtected = $true
            break
        }
    }
    if ($isProtected) {
        $protectedHits += $rel
    } else {
        $deletable += $rel
        if ($Apply) {
            Remove-Item -LiteralPath $dir.FullName -Force
        }
    }
}

$result = [ordered]@{
    repoRoot = $RepoRoot
    mode = $(if ($Apply) { "apply" } else { "dry-run" })
    emptyDirCount = @($emptyDirs).Count
    deletedCount = $(if ($Apply) { @($deletable).Count } else { 0 })
    deletable = @($deletable | Sort-Object -Unique)
    protectedEmptyDirs = @($protectedHits | Sort-Object -Unique)
    timestamp = (Get-Date).ToString("o")
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 8
    exit 0
}

Write-Host "Cleanup empty runtime dirs ($($result.mode))"
Write-Host "Repo root: $RepoRoot"
Write-Host "Empty dirs detected: $($result.emptyDirCount)"
Write-Host "Deletable empty dirs: $(@($result.deletable).Count)"
Write-Host "Protected empty dirs: $(@($result.protectedEmptyDirs).Count)"
Write-Host "Deleted: $($result.deletedCount)"
