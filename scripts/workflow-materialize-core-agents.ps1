param(
  [string]$RequestId = "",
  [string[]]$AgentIds = @(),
  [string]$RepoRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "workflow-utils.ps1")

if (-not $RequestId) {
  $RequestId = [guid]::NewGuid().ToString()
}

$root = Get-RepoRoot -OverrideRoot $RepoRoot
$workflowId = "materialize-core-agents"
$workflowPath = Join-Path $root "workflows/system/materialize-core-agents.json"
$workflow = Read-JsonFile -Path $workflowPath
if ($AgentIds.Count -eq 0) {
  $AgentIds = @($workflow.defaults.agentIds)
}

foreach ($agentId in $AgentIds) {
  Ensure-Directory -Path (Join-Path $root "workspace-$agentId")
  Ensure-Directory -Path (Join-Path $root "workspace-$agentId/memory")
  Ensure-Directory -Path (Join-Path $root "workspace-$agentId/docs")
  Ensure-Directory -Path (Join-Path $root "agents/$agentId/agent")
  Ensure-Directory -Path (Join-Path $root "agents/$agentId/sessions")
}

$catalogPath = Join-Path $root "state/agents/catalog.json"
$catalog = Read-JsonFile -Path $catalogPath
foreach ($agentId in $AgentIds) {
  $exists = $false
  foreach ($item in $catalog.agents) {
    if ($item.agentId -eq $agentId) { $exists = $true; break }
  }
  if (-not $exists) {
    $catalog.agents += [pscustomobject]@{
      agentId = $agentId
      role = "core_agent"
      runtime = "native"
      workspaceId = "workspace-$agentId"
      status = "active"
    }
  }
}
Write-JsonFile -Path $catalogPath -Object $catalog

$auditLogRel = "logs/audit/materialize-core-agents.jsonl"
$auditPath = Join-Path $root $auditLogRel
Write-WorkflowAudit -FilePath $auditPath -RequestId $RequestId -Source "ops" -Target "workflows/system/materialize-core-agents.json" -Action "materialize_core_agents" -Decision "pending_review" -Reason "core agents materialized and catalog synced"

$statePath = Join-Path $root "state/workflows/materialize-core-agents.json"
$stateObj = [ordered]@{
  workflowId = $workflowId
  requestId = $RequestId
  lastAction = "materialize_core_agents"
  lastDecision = "pending_review"
  lastSource = "ops"
  lastTarget = "workflows/system/materialize-core-agents.json"
  lastTimestamp = (Get-Date).ToString("o")
  stepCount = 5
  auditLog = $auditLogRel
}
Write-JsonFile -Path $statePath -Object $stateObj

$summary = [ordered]@{
  workflowId = $workflowId
  requestId = $RequestId
  stepCount = 5
  auditLog = $auditLogRel
}
$summary | ConvertTo-Json -Depth 5
