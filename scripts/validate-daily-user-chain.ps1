param(
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$usersPath = Join-Path $root "state/users/index.json"
$agentsPath = Join-Path $root "state/agents/catalog.json"
$openclawPath = Join-Path $root "openclaw.json"
$userProvisionAuditPath = Join-Path $root "state/audit/user-provision.jsonl"
$reviewGateAuditPath = Join-Path $root "state/audit/review-gate.jsonl"

$users = Get-Content $usersPath -Raw | ConvertFrom-Json
$agents = Get-Content $agentsPath -Raw | ConvertFrom-Json
$openclaw = Get-Content $openclawPath -Raw | ConvertFrom-Json

$userRecord = @($users.users) | Where-Object { [string]$_.userId -eq $UserId } | Select-Object -First 1
$dailyAgentId = "daily-$UserId"
$workspaceId = "workspace-daily-$UserId"

$agentRecord = @($agents.agents) | Where-Object { [string]$_.agentId -eq $dailyAgentId } | Select-Object -First 1
$bindingRecords = @(@($openclaw.bindings) | Where-Object { [string]$_.userId -eq $UserId -and [string]$_.agentId -eq $dailyAgentId })

$userProvisionLines = @()
if (Test-Path $userProvisionAuditPath) {
    $userProvisionLines = Get-Content $userProvisionAuditPath | Where-Object { $_.Trim().Length -gt 0 }
}
$reviewGateLines = @()
if (Test-Path $reviewGateAuditPath) {
    $reviewGateLines = Get-Content $reviewGateAuditPath | Where-Object { $_.Trim().Length -gt 0 }
}

$userProvisionHits = @()
foreach ($line in $userProvisionLines) {
    try {
        $item = $line | ConvertFrom-Json
        if ([string]$item.userId -eq $UserId -or [string]$item.agentId -eq $dailyAgentId) {
            $userProvisionHits += $item
        }
    } catch {}
}

$reviewHits = @()
foreach ($line in $reviewGateLines) {
    try {
        $item = $line | ConvertFrom-Json
        if ([string]$item.targetRef -eq $dailyAgentId -and [string]$item.targetType -eq "user_instance") {
            $reviewHits += $item
        }
    } catch {}
}

$checks = [ordered]@{
    userRecordExists = ($null -ne $userRecord)
    userStatusPendingReview = ($null -ne $userRecord -and [string]$userRecord.status -eq "pending_review")
    userWorkspaceMatches = ($null -ne $userRecord -and [string]$userRecord.workspaceId -eq $workspaceId)
    userDailyAgentMatches = ($null -ne $userRecord -and [string]$userRecord.dailyAgentId -eq $dailyAgentId)
    agentRecordExists = ($null -ne $agentRecord)
    agentWorkspaceMatches = ($null -ne $agentRecord -and [string]$agentRecord.workspaceId -eq $workspaceId)
    hasBindingEntries = ($bindingRecords.Count -gt 0)
    hasUserProvisionAudit = ($userProvisionHits.Count -gt 0)
    hasReviewGateRecord = ($reviewHits.Count -gt 0)
}

$passed = $true
foreach ($k in $checks.Keys) {
    if (-not $checks[$k]) { $passed = $false; break }
}

$result = [ordered]@{
    userId = $UserId
    dailyAgentId = $dailyAgentId
    workspaceId = $workspaceId
    checks = $checks
    counts = [ordered]@{
        bindingEntries = $bindingRecords.Count
        userProvisionAuditHits = $userProvisionHits.Count
        reviewGateHits = $reviewHits.Count
    }
    passed = $passed
    timestamp = (Get-Date).ToString("o")
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 8
    exit 0
}

Write-Host "Daily user chain validation for: $UserId"
foreach ($k in $checks.Keys) {
    Write-Host ("- {0}: {1}" -f $k, $checks[$k])
}
Write-Host "Binding entries: $($bindingRecords.Count)"
Write-Host "User-provision audit hits: $($userProvisionHits.Count)"
Write-Host "Review-gate hits: $($reviewHits.Count)"
Write-Host "PASSED: $passed"
