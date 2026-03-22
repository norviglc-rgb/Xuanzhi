param(
    [string]$RequestId = ("req-" + (Get-Date -Format "yyyyMMddHHmmss")),
    [string]$UserId = "example-user",
    [string]$ReviewId = "",
    [ValidateSet("approved", "rejected", "needs_changes")]
    [string]$ReviewStatus = "approved",
    [string]$Reviewer = "critic",
    [string]$FindingsMessage = "daily_user_review_outcome_applied",
    [switch]$Apply,
    [switch]$ValidateAfterApply
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

function Read-JsonlObjects {
    param([string]$Path)
    $rows = @()
    if (-not (Test-Path $Path)) { return $rows }
    foreach ($line in @(Get-Content -Path $Path)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try { $rows += ($line | ConvertFrom-Json) } catch {}
    }
    return @($rows)
}

function Jsonl-HasMatch {
    param(
        [object[]]$Items,
        [object]$Candidate,
        [string[]]$Keys
    )
    foreach ($item in @($Items)) {
        $match = $true
        foreach ($k in $Keys) {
            if ($item -is [System.Collections.IDictionary]) {
                $left = if ($item.Contains($k)) { [string]$item[$k] } else { "" }
            } else {
                $left = if ($item.PSObject.Properties.Name -contains $k) { [string]$item.$k } else { "" }
            }
            if ($Candidate -is [System.Collections.IDictionary]) {
                $right = if ($Candidate.Contains($k)) { [string]$Candidate[$k] } else { "" }
            } else {
                $right = if ($Candidate.PSObject.Properties.Name -contains $k) { [string]$Candidate.$k } else { "" }
            }
            if ($left -ne $right) {
                $match = $false
                break
            }
        }
        if ($match) { return $true }
    }
    return $false
}

function Append-JsonlLine {
    param([string]$Path, [object]$Item)
    ($Item | ConvertTo-Json -Compress -Depth 12) | Add-Content -Path $Path -Encoding UTF8
}

$root = Resolve-RepoRoot -startPath $PSScriptRoot
$usersPath = Join-Path $root "state/users/index.json"
$reviewAuditPath = Join-Path $root "state/audit/review-gate.jsonl"

if (-not (Test-Path $usersPath)) { throw "Missing state file: $usersPath" }
if (-not (Test-Path $reviewAuditPath)) { throw "Missing audit file: $reviewAuditPath" }

$usersDoc = Get-Content -Raw -Path $usersPath | ConvertFrom-Json
$usersArray = @($usersDoc.users)
$userRecord = @($usersArray | Where-Object { [string]$_.userId -eq $UserId } | Select-Object -First 1)
if ($null -eq $userRecord) {
    throw "User not found in state/users/index.json: $UserId"
}
if ([string]$userRecord.status -ne "pending_review") {
    throw "User status must be pending_review before apply; current=$([string]$userRecord.status)"
}

$now = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
$dailyAgentId = "daily-$UserId"
if ([string]::IsNullOrWhiteSpace($ReviewId)) {
    $ReviewId = "review-$RequestId-$UserId"
}

$finalStatus = if ($ReviewStatus -eq "approved") { "active" } elseif ($ReviewStatus -eq "rejected") { "disabled" } else { "pending_review" }
$nextStep = if ($ReviewStatus -eq "needs_changes") { "rerun create-daily-user after fixes" } else { "none" }

$findings = @(
    [ordered]@{
        severity = $(if ($ReviewStatus -eq "approved") { "info" } else { "warning" })
        message = $FindingsMessage
    }
)

$decisionRecord = [ordered]@{
    reviewId = $ReviewId
    targetType = "user_instance"
    targetRef = $dailyAgentId
    reviewer = $Reviewer
    status = $ReviewStatus
    lifecyclePhase = "decision"
    flow = [ordered]@{
        startedBy = "ops"
        routedBy = "orchestrator"
        handledBy = "ops"
        closedBy = "apply-daily-user-review-outcome"
        nextStep = $nextStep
    }
    findings = $findings
    createdAt = $now
    updatedAt = $now
}

$closureRecord = [ordered]@{
    reviewId = $ReviewId
    targetType = "user_instance"
    targetRef = $dailyAgentId
    reviewer = "critic"
    status = $ReviewStatus
    lifecyclePhase = "closure"
    flow = [ordered]@{
        startedBy = "ops"
        routedBy = "orchestrator"
        handledBy = "ops"
        closedBy = "apply-daily-user-review-outcome"
        nextStep = $nextStep
    }
    createdAt = $now
    updatedAt = $now
}

$userPatch = [ordered]@{
    userId = $UserId
    status = $finalStatus
    reviewId = $ReviewId
    updatedAt = $now
}

Write-Host "Replay apply-daily-user-review-outcome"
Write-Host "Mode: $(if ($Apply) { "apply" } else { "dry-run" })"
Write-Host "RequestId: $RequestId"
Write-Host "UserId: $UserId"
Write-Host "ReviewId: $ReviewId"
Write-Host "ReviewStatus: $ReviewStatus"
Write-Host "Final user status: $finalStatus"

if (-not $Apply) {
    Write-Host "----- decision record preview -----"
    $decisionRecord | ConvertTo-Json -Compress -Depth 12
    Write-Host "----- closure record preview -----"
    $closureRecord | ConvertTo-Json -Compress -Depth 12
    Write-Host "----- user patch preview -----"
    $userPatch | ConvertTo-Json -Compress -Depth 12
    exit 0
}

$mergedUsers = @()
$foundUser = $false
foreach ($item in $usersArray) {
    if ([string]$item.userId -eq $UserId) {
        $itemCopy = $item | Select-Object *
        $itemCopy.status = $userPatch.status
        $itemCopy.reviewId = $userPatch.reviewId
        $itemCopy.updatedAt = $userPatch.updatedAt
        $mergedUsers += $itemCopy
        $foundUser = $true
    } else {
        $mergedUsers += $item
    }
}
if (-not $foundUser) {
    $mergedUsers += $userPatch
}
$usersDoc.users = @($mergedUsers)
Set-Content -Path $usersPath -Value ($usersDoc | ConvertTo-Json -Depth 12) -Encoding UTF8

$existingAudit = Read-JsonlObjects -Path $reviewAuditPath
if (-not (Jsonl-HasMatch -Items $existingAudit -Candidate $decisionRecord -Keys @("reviewId", "lifecyclePhase", "targetRef"))) {
    Append-JsonlLine -Path $reviewAuditPath -Item $decisionRecord
}
if (-not (Jsonl-HasMatch -Items $existingAudit -Candidate $closureRecord -Keys @("reviewId", "lifecyclePhase", "targetRef"))) {
    Append-JsonlLine -Path $reviewAuditPath -Item $closureRecord
}

Write-Host "Updated: $usersPath"
Write-Host "Appended decision/closure audit to: $reviewAuditPath"

if ($ValidateAfterApply) {
    $validateScript = Join-Path $root "Xuanzhi-Dev/testing/scripts/validate-daily-user-chain.ps1"
    if (-not (Test-Path $validateScript)) {
        throw "Missing validation script: $validateScript"
    }
    Write-Host "Running validation with expected status: $finalStatus"
    powershell -ExecutionPolicy Bypass -File $validateScript -UserId $UserId -ExpectedStatus $finalStatus
    if ($LASTEXITCODE -ne 0) {
        throw "Validation command failed with exit code $LASTEXITCODE"
    }
}
