param(
  [string]$Image = "ghcr.io/openclaw/openclaw:latest",
  [string]$ContainerPrefix = "xuanzhi-openrouter-e2e",
  [string]$Message = "Docker OpenRouter e2e check",
  [int]$TimeoutSeconds = 60
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$docker = Get-Command docker -ErrorAction SilentlyContinue
if (-not $docker) {
  throw "Docker CLI is not available in PATH; install Docker before running this script."
}

if (-not $env:OPENROUTER_API_KEY) {
  throw "OPENROUTER_API_KEY must be set in the environment to reach OpenRouter."
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Resolve-Path (Join-Path $scriptRoot "..")
$containerName = $null
$tempConfig = $null
$runRequestId = [guid]::NewGuid().ToString()

. (Join-Path $scriptRoot "model-failover-audit.ps1")
Push-Location $projectRoot
try {
  $tempConfig = Join-Path $env:TEMP ("openclaw-docker-openrouter-e2e-$([guid]::NewGuid().ToString()).json")
  Copy-Item -Path (Join-Path $projectRoot "openclaw.json") -Destination $tempConfig -Force

  $syncScript = Join-Path $projectRoot "scripts" "sync-openrouter-free-models.ps1"
  if (-not (Test-Path $syncScript)) {
    throw "Missing $syncScript"
  }

  Write-Host "Probing OpenRouter model chain..."
  Write-ModelFailoverAuditEvent -RequestId $runRequestId -Source "docker-openrouter-e2e" -Target "openrouter-model-chain" -Action "docker_e2e_probe_start" -Decision "success" -Reason "probe_started"
  & $syncScript -ConfigPath $tempConfig -Probe

  $containerName = "$ContainerPrefix-$([guid]::NewGuid().ToString().Substring(0,8))"
  $containerId = & docker run -d --entrypoint sh --name $containerName $Image -c "tail -f /dev/null"
  if (-not $containerId) {
    throw "Failed to start the OpenClaw container."
  }

  $destRoot = "/home/node/.openclaw"
  & docker exec $containerName sh -c "rm -rf $destRoot && mkdir -p $destRoot"

  Write-Host "Copying runtime artifacts into container..."
  $runtimeItems = @("agents","hooks","skills","logs","credentials","cron")
  foreach ($item in $runtimeItems) {
    $source = Join-Path $projectRoot $item
    if (-not (Test-Path $source)) {
      continue
    }
    & docker cp $source "${containerName}:/home/node/.openclaw/"
  }

  $workspaceDirs = Get-ChildItem -Path $projectRoot -Directory -Filter "workspace-*" -ErrorAction SilentlyContinue
  foreach ($workspace in $workspaceDirs) {
    & docker cp $workspace.FullName "${containerName}:/home/node/.openclaw/"
  }

  & docker cp $tempConfig "${containerName}:/home/node/.openclaw/openclaw.json"
  & docker exec -u 0 $containerName sh -c "chown -R node:node $destRoot"

  Write-Host "Running OpenClaw agent turn against OpenRouter..."
  $openClawArgs = @(
    "exec",
    "-w",
    "/home/node",
    "-e",
    "OPENROUTER_API_KEY=$($env:OPENROUTER_API_KEY)",
    "-u",
    "node",
    $containerName,
    "openclaw",
    "agent",
    "--agent",
    "orchestrator",
    "--message",
    $Message,
    "--timeout",
    $TimeoutSeconds.ToString(),
    "--json"
  )

  try {
    & docker @openClawArgs
    Write-Host "OpenRouter call succeeded."
    Write-ModelFailoverAuditEvent -RequestId $runRequestId -Source "docker-openrouter-e2e" -Target $containerName -Action "docker_openrouter_agent_call" -Decision "success" -Reason "openclaw_agent_completed"
  } catch {
    Write-ModelFailoverAuditEvent -RequestId $runRequestId -Source "docker-openrouter-e2e" -Target $containerName -Action "docker_openrouter_agent_call" -Decision "failure" -Reason $_.Exception.Message -ErrorCode "AGENT_CALL_FAILED"
    throw "OpenRouter call failed: $($_.Exception.Message)"
  }
} finally {
  Pop-Location
  if ($tempConfig -and (Test-Path $tempConfig)) {
    Remove-Item $tempConfig -Force
  }
  if ($containerName) {
    try {
      & docker rm -f $containerName | Out-Null
    } catch {
      Write-Warning "Unable to remove temporary container ${containerName}: $($_.Exception.Message)"
    }
  }
}
