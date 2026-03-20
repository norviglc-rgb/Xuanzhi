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

$hasOpenRouterKey = -not [string]::IsNullOrWhiteSpace($env:OPENROUTER_API_KEY)
$hasMiniMaxKey = -not [string]::IsNullOrWhiteSpace($env:MINIMAX_API_KEY)
if (-not $hasOpenRouterKey -and -not $hasMiniMaxKey) {
  throw "Set OPENROUTER_API_KEY or MINIMAX_API_KEY before running Docker provider E2E."
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Resolve-Path (Join-Path $scriptRoot "..")
$containerName = $null
$tempConfig = $null
$tempEnvFile = $null
$runRequestId = [guid]::NewGuid().ToString()

. (Join-Path $scriptRoot "model-failover-audit.ps1")

function Write-ModelSwitchEventsFromOutput {
  param(
    [string[]]$Lines = @(),
    [Parameter(Mandatory = $true)][string]$RequestId
  )

  if (-not $Lines -or $Lines.Count -eq 0) {
    return
  }

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

  if ($hasOpenRouterKey) {
    Write-Host "Probing OpenRouter model chain..."
    Write-ModelFailoverAuditEvent -RequestId $runRequestId -Source "docker-openrouter-e2e" -Target "openrouter-model-chain" -Action "docker_e2e_probe_start" -Decision "success" -Reason "probe_started"
    & $syncScript -ConfigPath $tempConfig -Probe
  } else {
    Write-Host "OPENROUTER_API_KEY not set; skipping OpenRouter probe and using static config."
  }

  $tempConfigObj = Get-Content -LiteralPath $tempConfig -Raw | ConvertFrom-Json
  $hasGateway = $tempConfigObj.PSObject.Properties.Name -contains "gateway"
  if (-not $hasGateway) {
    $tempConfigObj | Add-Member -MemberType NoteProperty -Name gateway -Value ([pscustomobject]@{})
  }
  $tempConfigObj.gateway | Add-Member -MemberType NoteProperty -Name mode -Value "local" -Force

  if ($hasMiniMaxKey) {
    $hasModels = $tempConfigObj.PSObject.Properties.Name -contains "models"
    if (-not $hasModels) {
      $tempConfigObj | Add-Member -MemberType NoteProperty -Name models -Value ([pscustomobject]@{})
    }
    $tempConfigObj.models | Add-Member -MemberType NoteProperty -Name mode -Value "merge" -Force

    $hasProviders = $tempConfigObj.models.PSObject.Properties.Name -contains "providers"
    if (-not $hasProviders) {
      $tempConfigObj.models | Add-Member -MemberType NoteProperty -Name providers -Value ([pscustomobject]@{})
    }

    $tempConfigObj.models.providers | Add-Member -MemberType NoteProperty -Name minimax -Value ([pscustomobject]@{
      baseUrl = "https://api.minimaxi.com/anthropic"
      api = "anthropic-messages"
      apiKey = '${MINIMAX_API_KEY}'
      models = @(
        [pscustomobject]@{
          id = "MiniMax-M2.5"
          name = "MiniMax M2.5"
          reasoning = $true
          input = @("text")
          cost = [pscustomobject]@{
            input = 0.3
            output = 1.2
            cacheRead = 0.03
            cacheWrite = 0.12
          }
          contextWindow = 200000
          maxTokens = 8192
        },
        [pscustomobject]@{
          id = "MiniMax-M2.5-highspeed"
          name = "MiniMax M2.5 Highspeed"
          reasoning = $true
          input = @("text")
          cost = [pscustomobject]@{
            input = 0.3
            output = 1.2
            cacheRead = 0.03
            cacheWrite = 0.12
          }
          contextWindow = 200000
          maxTokens = 8192
        }
      )
    }) -Force

    $minimaxFallbacks = @("minimax/MiniMax-M2.5-highspeed", "minimax/MiniMax-M2.5")
    $existingFallbacks = @()
    if ($tempConfigObj.agents.defaults.model.fallbacks) {
      $existingFallbacks = @($tempConfigObj.agents.defaults.model.fallbacks)
    }
    foreach ($fallbackModel in $minimaxFallbacks) {
      if ($existingFallbacks -notcontains $fallbackModel) {
        $existingFallbacks += $fallbackModel
      }
    }
    $tempConfigObj.agents.defaults.model | Add-Member -MemberType NoteProperty -Name fallbacks -Value $existingFallbacks -Force
  }

  [System.IO.File]::WriteAllText($tempConfig, ($tempConfigObj | ConvertTo-Json -Depth 20), [System.Text.UTF8Encoding]::new($false))

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
  $providerEnvLines = @()
  if ($hasOpenRouterKey) { $providerEnvLines += "OPENROUTER_API_KEY=$($env:OPENROUTER_API_KEY)" }
  if ($hasMiniMaxKey) { $providerEnvLines += "MINIMAX_API_KEY=$($env:MINIMAX_API_KEY)" }
  $providerEnvContent = ($providerEnvLines -join [Environment]::NewLine) + [Environment]::NewLine
  $tempEnvFile = Join-Path $env:TEMP ("openclaw-docker-provider-env-$([guid]::NewGuid().ToString()).env")
  [System.IO.File]::WriteAllText($tempEnvFile, $providerEnvContent, [System.Text.UTF8Encoding]::new($false))
  & docker cp $tempEnvFile "${containerName}:/home/node/.openclaw/.env"
  & docker exec -u 0 $containerName sh -c "chown -R node:node $destRoot"

  Write-Host "Starting foreground gateway process inside container..."
  $gatewayEnvArgs = @("exec")
  if ($hasOpenRouterKey) { $gatewayEnvArgs += @("-e", "OPENROUTER_API_KEY=$($env:OPENROUTER_API_KEY)") }
  if ($hasMiniMaxKey) { $gatewayEnvArgs += @("-e", "MINIMAX_API_KEY=$($env:MINIMAX_API_KEY)") }
  $gatewayEnvArgs += @("-u", "node", $containerName, "sh", "-lc", "cd /home/node/.openclaw && nohup openclaw gateway run --allow-unconfigured >/tmp/openclaw-gateway.log 2>&1 & echo \$! >/tmp/openclaw-gateway.pid")
  & docker @gatewayEnvArgs
  & docker exec -u node $containerName sh -lc 'i=0; while [ "$i" -lt 20 ]; do if command -v curl >/dev/null 2>&1 && curl -fsS http://127.0.0.1:18789/healthz >/dev/null 2>&1; then exit 0; fi; i=$((i+1)); sleep 1; done; exit 1'
  if ($LASTEXITCODE -ne 0) {
    & docker exec -u node $containerName sh -lc "tail -n 120 /tmp/openclaw-gateway.log || true"
    throw "Gateway failed to become healthy inside container."
  }
  Write-ModelFailoverAuditEvent -RequestId $runRequestId -Source "docker-openrouter-e2e" -Target $containerName -Action "docker_gateway_start" -Decision "success" -Reason "gateway_healthz_ok"

  Write-Host "Running OpenClaw agent turn against OpenRouter..."
  $agentOutputLines = @()
  $openClawArgs = @(
    "exec",
    "-w",
    "/home/node",
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
  if ($hasOpenRouterKey) {
    $openClawArgs = @("exec", "-w", "/home/node", "-e", "OPENROUTER_API_KEY=$($env:OPENROUTER_API_KEY)", "-u", "node", $containerName, "openclaw", "agent", "--agent", "orchestrator", "--message", $Message, "--timeout", $TimeoutSeconds.ToString(), "--json")
  }
  if ($hasMiniMaxKey) {
    $openClawArgs = @("exec", "-w", "/home/node", "-e", "MINIMAX_API_KEY=$($env:MINIMAX_API_KEY)") + $openClawArgs[3..($openClawArgs.Count - 1)]
  }

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
    $gatewayLogLines = @()
    if ($containerName) {
      Write-Host "Gateway log tail (failure context):"
      $gatewayLogLines = @(& docker exec -u node $containerName sh -lc "tail -n 120 /tmp/openclaw-gateway.log || true")
      foreach ($line in $gatewayLogLines) {
        Write-Host $line
      }
    }
    Write-ModelSwitchEventsFromOutput -Lines $agentOutputLines -RequestId $runRequestId
    Write-ModelSwitchEventsFromOutput -Lines $gatewayLogLines -RequestId $runRequestId
    Write-ModelFailoverAuditEvent -RequestId $runRequestId -Source "docker-openrouter-e2e" -Target $containerName -Action "docker_openrouter_agent_call" -Decision "failure" -Reason $_.Exception.Message -ErrorCode "AGENT_CALL_FAILED"
    throw "OpenRouter call failed: $($_.Exception.Message)"
  }
} finally {
  Pop-Location
  if ($tempConfig -and (Test-Path $tempConfig)) {
    Remove-Item $tempConfig -Force
  }
  if ($tempEnvFile -and (Test-Path $tempEnvFile)) {
    Remove-Item $tempEnvFile -Force
  }
  if ($containerName) {
    try {
      & docker rm -f $containerName | Out-Null
    } catch {
      Write-Warning "Unable to remove temporary container ${containerName}: $($_.Exception.Message)"
    }
  }
}
