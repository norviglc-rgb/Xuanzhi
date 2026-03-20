param(
  [string]$ConfigPath = "openclaw.json",
  [int]$MaxFallbacks = 4,
  [switch]$Probe
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $scriptDir "model-failover-audit.ps1")
if (-not (Test-Path $ConfigPath)) {
  throw "Config file not found: $ConfigPath"
}

$preferred = @(
  "openrouter/nvidia/nemotron-3-super-120b-a12b:free",
  "openrouter/qwen/qwen3-coder:free",
  "openrouter/openai/gpt-oss-120b:free",
  "openrouter/z-ai/glm-4.5-air:free",
  "openrouter/minimax/minimax-m2.5:free",
  "openrouter/mistralai/mistral-small-3.1-24b-instruct:free",
  "openrouter/qwen/qwen3-next-80b-a3b-instruct:free",
  "openrouter/arcee-ai/trinity-mini:free"
)

$modelsResp = Invoke-RestMethod -Uri "https://openrouter.ai/api/v1/models" -Method Get
$freeSet = @{}
foreach ($m in $modelsResp.data) {
  if ($m.id -like "*:free") {
    $freeSet["openrouter/$($m.id)"] = $true
  }
}

$selected = @()
foreach ($model in $preferred) {
  if ($freeSet.ContainsKey($model)) {
    $selected += $model
  }
}

if ($selected.Count -eq 0) {
  throw "No preferred free models available on OpenRouter."
}

if ($Probe -and $env:OPENROUTER_API_KEY) {
  $probeRequestId = [guid]::NewGuid().ToString()
  $probeHeaders = @{
    Authorization = "Bearer $($env:OPENROUTER_API_KEY)"
    "Content-Type" = "application/json"
  }
  $healthy = @()
  foreach ($model in $selected) {
    $rawModel = $model -replace "^openrouter/", ""
    $probeBody = @{
      model = $rawModel
      messages = @(@{ role = "user"; content = "ok" })
      max_tokens = 4
    } | ConvertTo-Json -Depth 6
    try {
      $resp = Invoke-RestMethod -Uri "https://openrouter.ai/api/v1/chat/completions" -Method Post -Headers $probeHeaders -Body $probeBody -TimeoutSec 45
      if ($resp.choices.Count -gt 0) {
        $healthy += $model
        Write-ModelFailoverAuditEvent -RequestId $probeRequestId -Source "openrouter" -Target $model -Action "probe" -Decision "success" -Model $rawModel -Reason "response_with_choices"
      } else {
        Write-ModelFailoverAuditEvent -RequestId $probeRequestId -Source "openrouter" -Target $model -Action "probe" -Decision "failure" -Model $rawModel -Reason "empty_choices" -ErrorCode "NO_CHOICES"
      }
    } catch {
      $errorMessage = $_.Exception.Message
      $errorCode = "UNKNOWN"
      if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
        try {
          $payload = $_.ErrorDetails.Message | ConvertFrom-Json
          if ($payload.error -and $payload.error.code) {
            $errorCode = [string]$payload.error.code
          }
        } catch {
          $errorCode = "UNPARSEABLE_ERROR"
        }
      }
      Write-ModelFailoverAuditEvent -RequestId $probeRequestId -Source "openrouter" -Target $model -Action "probe" -Decision "failure" -Model $rawModel -Reason $errorMessage -ErrorCode $errorCode
      # keep fallback order and skip temporarily unavailable/free-quota exhausted model
    }
  }
  if ($healthy.Count -gt 0) {
    $selected = $healthy + ($selected | Where-Object { $healthy -notcontains $_ })
  }
}

$primary = $selected[0]
$fallbacks = @()
if ($selected.Count -gt 1) {
  $take = [Math]::Min($MaxFallbacks, $selected.Count - 1)
  $fallbacks = $selected[1..$take]
}

$configObj = Get-Content $ConfigPath -Raw | ConvertFrom-Json
if (-not $configObj.agents) { $configObj | Add-Member -MemberType NoteProperty -Name agents -Value ([pscustomobject]@{}) }
if (-not $configObj.agents.defaults) { $configObj.agents | Add-Member -MemberType NoteProperty -Name defaults -Value ([pscustomobject]@{}) }

$configObj.agents.defaults | Add-Member -MemberType NoteProperty -Name model -Value ([pscustomobject]@{
  primary = $primary
  fallbacks = $fallbacks
}) -Force

$json = $configObj | ConvertTo-Json -Depth 20
[System.IO.File]::WriteAllText((Resolve-Path $ConfigPath), $json, [System.Text.UTF8Encoding]::new($false))

Write-Output "Updated $ConfigPath"
Write-Output "Primary:   $primary"
Write-Output "Fallbacks: $($fallbacks -join ', ')"
if ($Probe) {
  if ($env:OPENROUTER_API_KEY) {
    Write-Output "Probe mode: enabled (used OPENROUTER_API_KEY)."
  } else {
    Write-Output "Probe mode requested but OPENROUTER_API_KEY was empty; probe skipped."
  }
}
