$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$workflowScripts = @(
    "workflow-materialize-core-agents.ps1",
    "workflow-create-daily-user.ps1",
    "workflow-memory-promote.ps1"
)

$summaries = @()
foreach ($workflowScript in $workflowScripts) {
    $path = Join-Path $scriptDir $workflowScript
    if (-not (Test-Path $path)) {
        throw "Replay entrypoint could not find $workflowScript."
    }
    Write-Host "Executing $workflowScript..."
    $resultLines = & $path
    $resultJson = ($resultLines -join '').Trim()
    if (-not $resultJson) {
        throw "Workflow script $workflowScript returned no summary."
    }
    $result = $resultJson | ConvertFrom-Json
    $summaries += [PSCustomObject]@{
        script = $workflowScript
        workflowId = $result.workflowId
        requestId = $result.requestId
        auditLog = $result.auditLog
        stateFile = "$($result.workflowId).json"
        steps = $result.stepCount
    }
}

Write-Host "Workflow replay summary:"
foreach ($summary in $summaries) {
    Write-Host ("{0}: request {1}, {2} steps, audit {3}" -f $summary.workflowId, $summary.requestId, $summary.steps, $summary.auditLog)
}

return $summaries
