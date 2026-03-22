param(
    [Parameter(Mandatory = $true)]
    [string]$HandoffDir,
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$policyPath = Join-Path $root "policies/routing-policy.json"

if (-not (Test-Path $policyPath)) {
    throw "Missing policy file: $policyPath"
}

$policy = Get-Content -Path $policyPath -Raw | ConvertFrom-Json
$required = @($policy.complexity_upgrade.handoff_required)
$targetAgent = [string]$policy.complexity_upgrade.target
$expectedRuntime = [string]$policy.complexity_upgrade.runtime

$resolvedHandoffDir = Resolve-Path -Path $HandoffDir -ErrorAction Stop
$dir = $resolvedHandoffDir.Path

$missing = @()
foreach ($name in $required) {
    $path = Join-Path $dir $name
    if (-not (Test-Path $path)) {
        $missing += $name
    }
}

$taskPath = Join-Path $dir "TASK.json"
$taskValidation = [ordered]@{
    exists = $false
    parseOk = $false
    typeOk = $false
    runtimeOk = $false
    targetAgentOk = $false
    routeReasonOk = $false
}

if (Test-Path $taskPath) {
    $taskValidation.exists = $true
    try {
        $task = Get-Content -Path $taskPath -Raw | ConvertFrom-Json
        $taskValidation.parseOk = $true
        $taskValidation.typeOk = ([string]$task.type -eq "complex_development")
        $taskValidation.runtimeOk = ([string]$task.route.runtime -eq $expectedRuntime)
        $taskValidation.targetAgentOk = ([string]$task.route.targetAgent -eq $targetAgent)
        $reasons = @($task.route.reason)
        $taskValidation.routeReasonOk = ($reasons.Count -gt 0 -and ($reasons -join "").Trim().Length -gt 0)
    } catch {
        $taskValidation.parseOk = $false
    }
}

$passed = (
    $missing.Count -eq 0 -and
    $taskValidation.exists -and
    $taskValidation.parseOk -and
    $taskValidation.typeOk -and
    $taskValidation.runtimeOk -and
    $taskValidation.targetAgentOk -and
    $taskValidation.routeReasonOk
)

$result = [ordered]@{
    handoffDir = $dir
    requiredFiles = $required
    missingFiles = $missing
    expected = [ordered]@{
        taskType = "complex_development"
        runtime = $expectedRuntime
        targetAgent = $targetAgent
        routeReasonNotEmpty = $true
    }
    taskValidation = $taskValidation
    passed = $passed
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 8
    exit 0
}

Write-Host "Handoff dir: $dir"
Write-Host "Required files missing: $($missing.Count)"
if ($missing.Count -gt 0) {
    Write-Host (" - " + ($missing -join ", "))
}
Write-Host "TASK.json exists: $($taskValidation.exists)"
Write-Host "TASK.json parseOk: $($taskValidation.parseOk)"
Write-Host "task.type == complex_development: $($taskValidation.typeOk)"
Write-Host "route.runtime == $expectedRuntime : $($taskValidation.runtimeOk)"
Write-Host "route.targetAgent == $targetAgent : $($taskValidation.targetAgentOk)"
Write-Host "route.reason not empty: $($taskValidation.routeReasonOk)"
Write-Host "PASSED: $passed"
