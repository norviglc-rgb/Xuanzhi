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

function Write-ModelSwitchEventsFromOutput {
  param(
    [Parameter(Mandatory = $true)][string[]]$Lines,
    [Parameter(Mandatory = $true)][string]$RequestId
  )

  foreach ($line in $Lines) {
    if (-not $line) {
      continue
    }
    if ($line -notmatch "\[model-fallback/decision\]") {
      continue
    }

    $decisionMatch = [regex]::Match($line, "decision=([^\s]+)")
    $requestedMatch = [regex]::Match($line, "requested=([^\s]+)")
    $candidateMatch = [regex]::Match($line, "candidate=([^\s]+)")
    $nextMatch = [regex]::Match($line, "next=([^\s]+)")
    $reasonMatch = [regex]::Match($line, "reason=([^\s]+)")

    $decisionRaw = if ($decisionMatch.Success) { $decisionMatch.Groups[1].Value } else { "unknown" }
    $requested = if ($requestedMatch.Success) { $requestedMatch.Groups[1].Value } else { "unknown" }
    $candidate = if ($candidateMatch.Success) { $candidateMatch.Groups[1].Value } else { "unknown" }
    $nextModel = if ($nextMatch.Success) { $nextMatch.Groups[1].Value } else { "none" }
    $reason = if ($reasonMatch.Success) { $reasonMatch.Groups[1].Value } else { "unknown" }

    $auditDecision = "failure"
    if ($decisionRaw -eq "candidate_succeeded") {
      $auditDecision = "success"
    }

    $target = "$requested->$candidate"
    $errorCode = if ($auditDecision -eq "failure") { "MODEL_SWITCH_FAILED" } else { $null }
    $reasonText = "decision=$decisionRaw; reason=$reason; next=$nextModel"

    Write-ModelFailoverAuditEvent -RequestId $RequestId -Source "docker-openrouter-e2e" -Target $target -Action "model_switch" -Decision $auditDecision -Model $candidate -Reason $reasonText -ErrorCode $errorCode
  }
}

function Parse-AgentJsonOutput {
  param([Parameter(Mandatory = $true)][string]$Text)
  $trimmed = $Text.Trim()
  if (-not $trimmed) {
    return $null
  }
  try {
    return ($trimmed | ConvertFrom-Json)
  } catch {
    return $null
  }
}

Push-Location $projectRoot
try {
  $tempConfig = Join-Path $env:TEMP ("openclaw-docker-openrouter-e2e-$([guid]::NewGuid().ToString()).json")
  Copy-Item -Path (Join-Path $projectRoot "openclaw.json") -Destination $tempConfig -Force

  $syncScript = Join-Path (Join-Path $projectRoot "scripts") "sync-openrouter-free-models.ps1"
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
    $stderrPath = Join-Path $env:TEMP ("openclaw-docker-e2e-stderr-$([guid]::NewGuid().ToString()).log")
    $agentStdout = & docker @openClawArgs 2> $stderrPath
    $dockerExitCode = $LASTEXITCODE
    $agentOutputLines = @($agentStdout | ForEach-Object { [string]$_ })
    foreach ($line in $agentOutputLines) {
      Write-Host $line
    }
    if (Test-Path $stderrPath) {
      $stderrLines = Get-Content -LiteralPath $stderrPath
      foreach ($line in $stderrLines) {
        Write-Host $line
      }
      $agentOutputLines += @($stderrLines | ForEach-Object { [string]$_ })
      Remove-Item $stderrPath -Force
    }
    if ($dockerExitCode -ne 0) {
      throw "docker returned exit code $dockerExitCode"
    }

    $jsonCandidate = ($agentStdout -join "`n")
    $agentJson = Parse-AgentJsonOutput -Text $jsonCandidate
    if ($null -eq $agentJson) {
      throw "agent output is not valid JSON"
    }
    $stopReason = [string]$agentJson.meta.stopReason
    if ($stopReason -eq "error") {
      $payloadText = ""
      if ($agentJson.payloads -and $agentJson.payloads.Count -gt 0) {
        $payloadText = [string]$agentJson.payloads[0].text
      }
      throw "agent returned stopReason=error; payload=$payloadText"
    }

    Write-ModelSwitchEventsFromOutput -Lines $agentOutputLines -RequestId $runRequestId
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
