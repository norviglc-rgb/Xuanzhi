function Get-ModelFailoverAuditLogFilePath {
  param(
    [string]$OverridePath
  )

  if ($OverridePath) {
    $fullPath = [System.IO.Path]::GetFullPath($OverridePath)
  } else {
    $projectRoot = Resolve-Path -Path (Join-Path $PSScriptRoot "..")
    $fullPath = Join-Path $projectRoot "logs" "audit" "model-failover.jsonl"
  }

  $logDir = Split-Path -Parent $fullPath
  if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
  }

  return $fullPath
}

function Write-ModelFailoverAuditEvent {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$Target,
    [Parameter(Mandatory = $true)][string]$Action,
    [Parameter(Mandatory = $true)][ValidateSet("success", "failure")][string]$Decision,
    [string]$RequestId,
    [string]$Model,
    [string]$Reason,
    [string]$ErrorCode,
    [string]$LogPath
  )

  $logFile = Get-ModelFailoverAuditLogFilePath -OverridePath $LogPath
  $entry = [ordered]@{
    requestId = $(if ($RequestId) { $RequestId } else { [guid]::NewGuid().ToString() })
    source = $Source
    target = $Target
    action = $Action
    decision = $Decision
    timestamp = (Get-Date).ToString("o")
  }

  if ($Model) { $entry.model = $Model }
  if ($Reason) { $entry.reason = $Reason }
  if ($ErrorCode) { $entry.errorCode = $ErrorCode }

  $jsonLine = $entry | ConvertTo-Json -Depth 6 -Compress
  Add-Content -LiteralPath $logFile -Value "$jsonLine`n"
}
