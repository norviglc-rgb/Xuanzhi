param(
  [string]$WorkspaceId = "workspace-orchestrator",
  [string]$CandidateContent = "r4 replay validated execution chain",
  [string]$Reason = "r4 replay check",
  [string]$RequestId = "",
  [string]$RepoRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "workflow-utils.ps1")

if (-not $RequestId) {
  $RequestId = [guid]::NewGuid().ToString()
}

$root = Get-RepoRoot -OverrideRoot $RepoRoot
$workflowId = "memory-promote"
$policyPath = Join-Path $root "policies/memory-policy.json"
$policy = Read-JsonFile -Path $policyPath

foreach ($forbidden in $policy.forbidden_content) {
  if ($CandidateContent -match [regex]::Escape([string]$forbidden)) {
    $auditPath = Join-Path $root "logs/audit/memory-promote.jsonl"
    Write-WorkflowAudit -FilePath $auditPath -RequestId $RequestId -Source "critic" -Target "workflows/memory/promote.json" -Action "memory_promote" -Decision "deny" -Reason "forbidden_content:$forbidden"
    throw "candidate contains forbidden content: $forbidden"
  }
}

$workspacePath = Join-Path $root $WorkspaceId
Ensure-Directory -Path $workspacePath
$memoryPath = Join-Path $workspacePath "MEMORY.md"
if (-not (Test-Path $memoryPath)) {
  [System.IO.File]::WriteAllText($memoryPath, "# MEMORY`n", [System.Text.UTF8Encoding]::new($false))
}

$section = @"

## promoted-$RequestId
- timestamp: $(Get-Date -Format o)
- reason: $Reason
- content: $CandidateContent
"@
Add-Content -LiteralPath $memoryPath -Value $section

$auditLogRel = "logs/audit/memory-promote.jsonl"
$auditPath = Join-Path $root $auditLogRel
Write-WorkflowAudit -FilePath $auditPath -RequestId $RequestId -Source "critic" -Target "workflows/memory/promote.json" -Action "memory_promote" -Decision "success" -Reason "memory appended"

$statePath = Join-Path $root "state/workflows/memory-promote.json"
$stateObj = [ordered]@{
  workflowId = $workflowId
  requestId = $RequestId
  lastAction = "memory_promote"
  lastDecision = "success"
  lastSource = "critic"
  lastTarget = "workflows/memory/promote.json"
  lastTimestamp = (Get-Date).ToString("o")
  stepCount = 6
  auditLog = $auditLogRel
}
Write-JsonFile -Path $statePath -Object $stateObj

$summary = [ordered]@{
  workflowId = $workflowId
  requestId = $RequestId
  stepCount = 6
  auditLog = $auditLogRel
}
$summary | ConvertTo-Json -Depth 5
