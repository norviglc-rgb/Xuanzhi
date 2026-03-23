param(
    [ValidateSet("codex", "claude")]
    [string]$Client,
    [string]$Phase = "checkpoint",
    [string]$RepoRoot = "",
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-RepoRoot([string]$startPath) {
    $cursor = (Resolve-Path $startPath).Path
    while ($true) {
        if (Test-Path (Join-Path $cursor "openclaw.json")) {
            return $cursor
        }
        $parent = Split-Path -Path $cursor -Parent
        if ([string]::IsNullOrWhiteSpace($parent) -or $parent -eq $cursor) {
            throw "Cannot locate repository root from start path: $startPath"
        }
        $cursor = $parent
    }
}

function Read-Json([string]$path) {
    return (Get-Content -Path $path -Raw | ConvertFrom-Json)
}

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = Resolve-RepoRoot -startPath $PSScriptRoot
} else {
    $RepoRoot = (Resolve-Path $RepoRoot).Path
}

$tasklistPath = Join-Path $RepoRoot ".codex/native-tasklist.json"
$auditPath = Join-Path $RepoRoot ".codex/agent-workflow-skill-foundation-audit.json"
$statusPath = Join-Path $RepoRoot ".codex/client-control-plane-status.json"

$tasklist = Read-Json $tasklistPath
$audit = Read-Json $auditPath
$status = if (Test-Path $statusPath) { Read-Json $statusPath } else { $null }

if ($null -eq $status) {
    $status = [ordered]@{
        version = "v1"
        owner = "codex"
        sourceOfTruth = [ordered]@{
            tasklist = ".codex/native-tasklist.json"
            audit = ".codex/agent-workflow-skill-foundation-audit.json"
        }
        cadencePolicy = [ordered]@{
            codex = "Run sync-client-progress.ps1 at session checkpoint and before closeout."
            claude = "Run sync-client-progress.ps1 at SessionStart and Stop via .claude/settings.json hooks."
        }
        clients = [ordered]@{
            codex = [ordered]@{ lastSyncAt = $null; lastPhase = $null }
            claude = [ordered]@{ lastSyncAt = $null; lastPhase = $null }
        }
        lastUpdated = $null
    }
}

$taskById = @{}
foreach ($task in @($tasklist.tasks)) {
    $taskById[[string]$task.id] = [string]$task.status
}

$auditTaskMirror = @()
foreach ($task in @($audit.tasks)) {
    if ([string]$task.scope -ne "codex_only") {
        continue
    }
    $auditTaskMirror += [ordered]@{
        id = [string]$task.id
        auditStatus = [string]$task.status
        nativeStatus = if ($taskById.ContainsKey([string]$task.id)) { [string]$taskById[[string]$task.id] } else { "<missing>" }
    }
}

$mirrorPassed = $true
foreach ($item in $auditTaskMirror) {
    if ([string]$item.auditStatus -ne [string]$item.nativeStatus) {
        $mirrorPassed = $false
        break
    }
}

$now = (Get-Date).ToString("o")
$status.clients.$Client = [ordered]@{
    lastSyncAt = $now
    lastPhase = $Phase
    summary = [ordered]@{
        nativeTaskCount = @($tasklist.tasks).Count
        auditTaskCount = @($audit.tasks).Count
        blockingGuardCount = @($tasklist.tasks | Where-Object { $_.blocking -eq $true }).Count
        mirrorPassed = $mirrorPassed
    }
}
$status.lastUpdated = $now

$jsonText = $status | ConvertTo-Json -Depth 10
Set-Content -Path $statusPath -Value $jsonText -Force -Encoding utf8

$result = [ordered]@{
    client = $Client
    phase = $Phase
    statusPath = $statusPath
    mirrorPassed = $mirrorPassed
    timestamp = $now
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 8
    exit 0
}

Write-Host "Client control-plane progress synced"
Write-Host "Client: $Client"
Write-Host "Phase: $Phase"
Write-Host "Mirror passed: $mirrorPassed"
Write-Host "Status path: $statusPath"
