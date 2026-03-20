Set-StrictMode -Version Latest

function Get-RepoRoot {
  param([string]$OverrideRoot = "")
  if ($OverrideRoot) {
    return (Resolve-Path $OverrideRoot).Path
  }
  return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

function Ensure-Directory {
  param([Parameter(Mandatory = $true)][string]$Path)
  if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
  }
}

function Read-JsonFile {
  param([Parameter(Mandatory = $true)][string]$Path)
  return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-JsonFile {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)]$Object
  )
  $dir = Split-Path -Parent $Path
  Ensure-Directory -Path $dir
  $json = $Object | ConvertTo-Json -Depth 30
  [System.IO.File]::WriteAllText($Path, $json, [System.Text.UTF8Encoding]::new($false))
}

function Write-WorkflowAudit {
  param(
    [Parameter(Mandatory = $true)][string]$FilePath,
    [Parameter(Mandatory = $true)][string]$RequestId,
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$Target,
    [Parameter(Mandatory = $true)][string]$Action,
    [Parameter(Mandatory = $true)][ValidateSet("allow", "deny", "success", "failure", "pending_review")][string]$Decision,
    [string]$Reason
  )

  $entry = [ordered]@{
    requestId = $RequestId
    source = $Source
    target = $Target
    action = $Action
    decision = $Decision
    timestamp = (Get-Date).ToString("o")
  }
  if ($Reason) {
    $entry.reason = $Reason
  }

  $dir = Split-Path -Parent $FilePath
  Ensure-Directory -Path $dir
  Add-Content -LiteralPath $FilePath -Value (($entry | ConvertTo-Json -Compress) + "`n")
}
