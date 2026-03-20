param(
  [string]$UserId = "r4-user-001",
  [string]$DisplayName = "",
  [string]$Persona = "general",
  [string]$RequestId = "",
  [string]$RepoRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "workflow-utils.ps1")

if (-not $RequestId) {
  $RequestId = [guid]::NewGuid().ToString()
}
if (-not $DisplayName) {
  $DisplayName = $UserId
}

$root = Get-RepoRoot -OverrideRoot $RepoRoot
$workflowId = "create-daily-user"
$agentId = "daily-$UserId"
$workspaceId = "workspace-daily-$UserId"
$workspacePath = Join-Path $root $workspaceId

Ensure-Directory -Path $workspacePath
Ensure-Directory -Path (Join-Path $workspacePath "memory")
Ensure-Directory -Path (Join-Path $workspacePath "docs")
Ensure-Directory -Path (Join-Path $workspacePath "state")
Ensure-Directory -Path (Join-Path $root "agents/$agentId/agent")
Ensure-Directory -Path (Join-Path $root "agents/$agentId/sessions")

$workspaceFiles = @{
  "AGENTS.md" = "# $agentId`n`nDaily user agent workspace."
  "IDENTITY.md" = "# Identity`n`n- userId: $UserId`n- displayName: $DisplayName"
  "MEMORY.md" = "# MEMORY`n"
}
foreach ($file in $workspaceFiles.Keys) {
  $path = Join-Path $workspacePath $file
  if (-not (Test-Path $path)) {
    [System.IO.File]::WriteAllText($path, $workspaceFiles[$file], [System.Text.UTF8Encoding]::new($false))
  }
}

$profile = [pscustomobject]@{
  userId = $UserId
  displayName = $DisplayName
  persona = $Persona
  workspaceId = $workspaceId
  agentId = $agentId
}
Write-JsonFile -Path (Join-Path $workspacePath "profile.json") -Object $profile

$usersPath = Join-Path $root "state/users/index.json"
$users = Read-JsonFile -Path $usersPath
$users.users = @($users.users | Where-Object { $_.userId -ne $UserId })
$users.users += [pscustomobject]@{
  userId = $UserId
  agentId = $agentId
  workspaceId = $workspaceId
  status = "pending_review"
}
Write-JsonFile -Path $usersPath -Object $users

$catalogPath = Join-Path $root "state/agents/catalog.json"
$catalog = Read-JsonFile -Path $catalogPath
$catalog.agents = @($catalog.agents | Where-Object { $_.agentId -ne $agentId })
$catalog.agents += [pscustomobject]@{
  agentId = $agentId
  role = "daily_user_agent"
  runtime = "native"
  workspaceId = $workspaceId
  status = "pending_review"
}
Write-JsonFile -Path $catalogPath -Object $catalog

$auditLogRel = "logs/audit/create-daily-user.jsonl"
$auditPath = Join-Path $root $auditLogRel
Write-WorkflowAudit -FilePath $auditPath -RequestId $RequestId -Source "ops" -Target "workflows/users/create-daily-user.json" -Action "create_daily_user" -Decision "pending_review" -Reason "daily user provisioned"

$statePath = Join-Path $root "state/workflows/create-daily-user.json"
$stateObj = [ordered]@{
  workflowId = $workflowId
  requestId = $RequestId
  lastAction = "create_daily_user"
  lastDecision = "pending_review"
  lastSource = "ops"
  lastTarget = "workflows/users/create-daily-user.json"
  lastTimestamp = (Get-Date).ToString("o")
  stepCount = 8
  auditLog = $auditLogRel
}
Write-JsonFile -Path $statePath -Object $stateObj

$summary = [ordered]@{
  workflowId = $workflowId
  requestId = $RequestId
  stepCount = 8
  auditLog = $auditLogRel
}
$summary | ConvertTo-Json -Depth 5
