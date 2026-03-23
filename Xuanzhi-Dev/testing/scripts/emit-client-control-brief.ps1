param(
    [ValidateSet("codex", "claude")]
    [string]$Client,
    [string]$Phase = "session_start",
    [string]$RepoRoot = ""
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

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = Resolve-RepoRoot -startPath $PSScriptRoot
} else {
    $RepoRoot = (Resolve-Path $RepoRoot).Path
}

$tasklistPath = Join-Path $RepoRoot ".codex/native-tasklist.json"
$auditPath = Join-Path $RepoRoot ".codex/agent-workflow-skill-foundation-audit.json"
$tasklist = Get-Content -Path $tasklistPath -Raw | ConvertFrom-Json
$audit = Get-Content -Path $auditPath -Raw | ConvertFrom-Json

$activeTasks = @($tasklist.tasks | Where-Object { [string]$_.status -ne "completed" } | Select-Object -First 5)
$blockers = @($audit.executionState.blockers | Where-Object { [string]$_.status -ne "resolved" } | Select-Object -First 5)

Write-Host "[client-control-brief]"
Write-Host "client=$Client"
Write-Host "phase=$Phase"
Write-Host "read=.codex/SESSION-HARD-GUARDS.md -> .codex/session-state.json -> .codex/handoff.md -> .codex/engineering-standards.md -> .codex/native-tasklist.json -> .codex/agent-workflow-skill-foundation-audit.json"
Write-Host "run=powershell -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/invoke-session-hard-guards.ps1"
Write-Host "taskCount=$(@($tasklist.tasks).Count)"
Write-Host "auditTaskCount=$(@($audit.tasks).Count)"
if (@($activeTasks).Count -gt 0) {
    Write-Host "activeTasks=$((@($activeTasks | ForEach-Object { "" + [string]$_.id + ":" + [string]$_.status }) -join ", "))"
} else {
    Write-Host "activeTasks=<none>"
}
if (@($blockers).Count -gt 0) {
    Write-Host "blockers=$((@($blockers | ForEach-Object { "" + [string]$_.id + ":" + [string]$_.status }) -join ", "))"
} else {
    Write-Host "blockers=<none>"
}
