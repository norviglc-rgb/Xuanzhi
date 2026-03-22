param(
    [Parameter(Mandatory = $true)]
    [string]$PackageDir,
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$requiredInput = @("TASK.json", "PLAN.md", "DECISIONS.md", "ACCEPTANCE.md", "NEXT_STEPS.md")
$requiredOutput = @("EXECUTION_REPORT.md")

$resolved = Resolve-Path -Path $PackageDir -ErrorAction Stop
$dir = $resolved.Path

$missingInput = @()
foreach ($f in $requiredInput) {
    if (-not (Test-Path (Join-Path $dir $f))) { $missingInput += $f }
}

$missingOutput = @()
foreach ($f in $requiredOutput) {
    if (-not (Test-Path (Join-Path $dir $f))) { $missingOutput += $f }
}

$taskChecks = [ordered]@{
    exists = $false
    parseOk = $false
    typeOk = $false
    targetAgentOk = $false
    runtimeOk = $false
    routeReasonOk = $false
}

$taskPath = Join-Path $dir "TASK.json"
if (Test-Path $taskPath) {
    $taskChecks.exists = $true
    try {
        $task = Get-Content -Path $taskPath -Raw | ConvertFrom-Json
        $taskChecks.parseOk = $true
        $taskChecks.typeOk = ([string]$task.type -eq "complex_development")
        $taskChecks.targetAgentOk = ([string]$task.route.targetAgent -eq "claude-code")
        $taskChecks.runtimeOk = ([string]$task.route.runtime -eq "acp")
        $reasons = @($task.route.reason)
        $taskChecks.routeReasonOk = ($reasons.Count -gt 0 -and ($reasons -join "").Trim().Length -gt 0)
    } catch {
        $taskChecks.parseOk = $false
    }
}

$executionReportChecks = [ordered]@{
    exists = $false
    hasScope = $false
    hasChangedFiles = $false
    hasVerification = $false
    hasRisks = $false
}

$reportPath = Join-Path $dir "EXECUTION_REPORT.md"
if (Test-Path $reportPath) {
    $executionReportChecks.exists = $true
    $report = Get-Content -Path $reportPath -Raw
    $executionReportChecks.hasScope = ($report -match "(?im)^##\s*scope")
    $executionReportChecks.hasChangedFiles = ($report -match "(?im)^##\s*changed files")
    $executionReportChecks.hasVerification = ($report -match "(?im)^##\s*verification")
    $executionReportChecks.hasRisks = ($report -match "(?im)^##\s*unresolved risks")
}

$passed = (
    $missingInput.Count -eq 0 -and
    $missingOutput.Count -eq 0 -and
    $taskChecks.exists -and
    $taskChecks.parseOk -and
    $taskChecks.typeOk -and
    $taskChecks.targetAgentOk -and
    $taskChecks.runtimeOk -and
    $taskChecks.routeReasonOk -and
    $executionReportChecks.exists -and
    $executionReportChecks.hasScope -and
    $executionReportChecks.hasChangedFiles -and
    $executionReportChecks.hasVerification -and
    $executionReportChecks.hasRisks
)

$result = [ordered]@{
    packageDir = $dir
    missing = [ordered]@{
        inputFiles = $missingInput
        outputFiles = $missingOutput
    }
    taskChecks = $taskChecks
    executionReportChecks = $executionReportChecks
    passed = $passed
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 8
    exit 0
}

Write-Host "Package dir: $dir"
Write-Host "Missing input files: $($missingInput.Count)"
if ($missingInput.Count -gt 0) { Write-Host (" - " + ($missingInput -join ", ")) }
Write-Host "Missing output files: $($missingOutput.Count)"
if ($missingOutput.Count -gt 0) { Write-Host (" - " + ($missingOutput -join ", ")) }
Write-Host "TASK checks: type=$($taskChecks.typeOk), targetAgent=$($taskChecks.targetAgentOk), runtime=$($taskChecks.runtimeOk), routeReason=$($taskChecks.routeReasonOk)"
Write-Host "EXECUTION_REPORT checks: scope=$($executionReportChecks.hasScope), changedFiles=$($executionReportChecks.hasChangedFiles), verification=$($executionReportChecks.hasVerification), risks=$($executionReportChecks.hasRisks)"
Write-Host "PASSED: $passed"
