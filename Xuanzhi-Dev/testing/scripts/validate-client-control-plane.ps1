param(
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
    if (-not (Test-Path $path)) {
        throw "Missing required file: $path"
    }
    return (Get-Content -Path $path -Raw | ConvertFrom-Json)
}

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = Resolve-RepoRoot -startPath $PSScriptRoot
} else {
    $RepoRoot = (Resolve-Path $RepoRoot).Path
}

$agentsPath = Join-Path $RepoRoot "AGENTS.md"
$claudePath = Join-Path $RepoRoot "CLAUDE.md"
$claudeSettingsPath = Join-Path $RepoRoot ".claude/settings.json"
$sessionHardGuardsPath = Join-Path $RepoRoot ".codex/SESSION-HARD-GUARDS.md"
$tasklistPath = Join-Path $RepoRoot ".codex/native-tasklist.json"
$auditPath = Join-Path $RepoRoot ".codex/agent-workflow-skill-foundation-audit.json"
$clientStatusPath = Join-Path $RepoRoot ".codex/client-control-plane-status.json"
$syncScriptRel = "Xuanzhi-Dev/testing/scripts/sync-client-progress.ps1"
$briefScriptRel = "Xuanzhi-Dev/testing/scripts/emit-client-control-brief.ps1"
$guardWrapperRel = "Xuanzhi-Dev/testing/scripts/invoke-session-hard-guards.ps1"

$violations = @()

foreach ($required in @(
    $agentsPath,
    $claudePath,
    $claudeSettingsPath,
    $sessionHardGuardsPath,
    $tasklistPath,
    $auditPath,
    $clientStatusPath
)) {
    if (-not (Test-Path $required)) {
        $violations += "required_file_missing:$required"
    }
}

if (@($violations).Count -gt 0) {
    $result = [ordered]@{
        repoRoot = $RepoRoot
        violations = @($violations)
        passed = $false
        timestamp = (Get-Date).ToString("o")
    }
    if ($AsJson) {
        $result | ConvertTo-Json -Depth 8
        exit 0
    }
    throw ($violations -join "`n")
}

$agentsText = Get-Content -Path $agentsPath -Raw
$claudeText = Get-Content -Path $claudePath -Raw
$sessionHardGuardsText = Get-Content -Path $sessionHardGuardsPath -Raw
$claudeSettings = Read-Json $claudeSettingsPath
$tasklist = Read-Json $tasklistPath
$audit = Read-Json $auditPath
$clientStatus = Read-Json $clientStatusPath

foreach ($snippet in @(
    ".codex/SESSION-HARD-GUARDS.md",
    ".codex/native-tasklist.json",
    ".codex/agent-workflow-skill-foundation-audit.json",
    $guardWrapperRel
)) {
    if (-not $agentsText.Contains($snippet)) {
        $violations += "agents_md_missing_snippet:$snippet"
    }
    if (-not $claudeText.Contains($snippet)) {
        $violations += "claude_md_missing_snippet:$snippet"
    }
}

if (-not $claudeText.Contains(".claude/settings.json")) {
    $violations += "claude_md_missing_settings_reference"
}

$sessionStartHooks = @($claudeSettings.hooks.SessionStart)
$preToolUseHooks = @($claudeSettings.hooks.PreToolUse)
$stopHooks = @($claudeSettings.hooks.Stop)

if (@($sessionStartHooks).Count -eq 0) {
    $violations += "claude_settings_missing_session_start_hooks"
}
if (@($preToolUseHooks).Count -eq 0) {
    $violations += "claude_settings_missing_pre_tool_use_hooks"
}
if (@($stopHooks).Count -eq 0) {
    $violations += "claude_settings_missing_stop_hooks"
}

$settingsText = Get-Content -Path $claudeSettingsPath -Raw
foreach ($requiredCommand in @(
    $briefScriptRel,
    $syncScriptRel,
    $guardWrapperRel,
    "Xuanzhi-Dev/testing/scripts/validate-client-control-plane.ps1"
)) {
    if (-not $settingsText.Contains($requiredCommand)) {
        $violations += "claude_settings_missing_command:$requiredCommand"
    }
}

$requiredGuardId = "GUARD-CLIENT-CONTROL-001"
$alwaysRunIds = @($tasklist.priorityPolicy.alwaysRunBeforeAnyTask | ForEach-Object { [string]$_ })
if ($alwaysRunIds -notcontains $requiredGuardId) {
    $violations += "native_tasklist_priority_missing_guard:$requiredGuardId"
}

$nativeTaskById = @{}
foreach ($task in @($tasklist.tasks)) {
    $nativeTaskById[[string]$task.id] = $task
}
if (-not $nativeTaskById.ContainsKey($requiredGuardId)) {
    $violations += "native_tasklist_missing_guard:$requiredGuardId"
}

$auditGuardIds = @($audit.hardGuards.guards | ForEach-Object { [string]$_.id })
if ($auditGuardIds -notcontains $requiredGuardId) {
    $violations += "audit_missing_guard:$requiredGuardId"
}

$enforcementOrder = @($audit.nativeSupport.enforcementOrder | ForEach-Object { [string]$_ })
if ($enforcementOrder -notcontains "validate-client-control-plane.ps1") {
    $violations += "audit_enforcement_order_missing_client_control_validator"
}

if ([string]$clientStatus.sourceOfTruth.tasklist -ne ".codex/native-tasklist.json") {
    $violations += "client_status_tasklist_source_mismatch"
}
if ([string]$clientStatus.sourceOfTruth.audit -ne ".codex/agent-workflow-skill-foundation-audit.json") {
    $violations += "client_status_audit_source_mismatch"
}
foreach ($clientName in @("codex", "claude")) {
    if ($null -eq $clientStatus.clients.$clientName) {
        $violations += "client_status_missing_client:$clientName"
    }
}

if (-not $sessionHardGuardsText.Contains("validate-client-control-plane.ps1")) {
    $violations += "session_hard_guards_missing_client_control_validator"
}

$result = [ordered]@{
    repoRoot = $RepoRoot
    checkedFiles = @(
        $agentsPath,
        $claudePath,
        $claudeSettingsPath,
        $sessionHardGuardsPath,
        $tasklistPath,
        $auditPath,
        $clientStatusPath
    )
    counts = [ordered]@{
        nativeTaskCount = @($tasklist.tasks).Count
        auditTaskCount = @($audit.tasks).Count
        violations = @($violations).Count
    }
    violations = @($violations)
    passed = (@($violations).Count -eq 0)
    timestamp = (Get-Date).ToString("o")
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 10
    exit 0
}

Write-Host "Validate client control plane"
Write-Host "Native task count: $($result.counts.nativeTaskCount)"
Write-Host "Audit task count: $($result.counts.auditTaskCount)"
Write-Host "Violations: $($result.counts.violations)"
Write-Host "PASSED: $($result.passed)"
if (@($violations).Count -gt 0) {
    Write-Host "Violation details:"
    foreach ($violation in @($violations)) {
        Write-Host " - $violation"
    }
}
