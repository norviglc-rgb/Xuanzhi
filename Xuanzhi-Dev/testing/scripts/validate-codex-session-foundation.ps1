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

$readmePath = Join-Path $RepoRoot ".codex/README.md"
$sessionStatePath = Join-Path $RepoRoot ".codex/session-state.json"
$handoffPath = Join-Path $RepoRoot ".codex/handoff.md"
$standardsPath = Join-Path $RepoRoot ".codex/engineering-standards.md"
$tasklistPath = Join-Path $RepoRoot ".codex/native-tasklist.json"
$auditPath = Join-Path $RepoRoot ".codex/agent-workflow-skill-foundation-audit.json"
$hardGuardsPath = Join-Path $RepoRoot ".codex/SESSION-HARD-GUARDS.md"

$requiredFiles = @(
    $readmePath,
    $sessionStatePath,
    $handoffPath,
    $standardsPath,
    $tasklistPath,
    $auditPath,
    $hardGuardsPath
)

$violations = @()
foreach ($required in $requiredFiles) {
    if (-not (Test-Path $required)) {
        $violations += "required_codex_file_missing:$required"
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

$readmeText = Get-Content -Path $readmePath -Raw
$handoffText = Get-Content -Path $handoffPath -Raw
$hardGuardsText = Get-Content -Path $hardGuardsPath -Raw
$sessionState = Read-Json $sessionStatePath
$tasklist = Read-Json $tasklistPath
$audit = Read-Json $auditPath

$expectedResumeOrder = @(
    ".codex/SESSION-HARD-GUARDS.md",
    ".codex/session-state.json",
    ".codex/handoff.md",
    ".codex/engineering-standards.md",
    ".codex/native-tasklist.json",
    ".codex/agent-workflow-skill-foundation-audit.json"
)

$actualResumeOrder = @($sessionState.resume_order | ForEach-Object { [string]$_ })
if (@($actualResumeOrder).Count -ne @($expectedResumeOrder).Count) {
    $violations += "session_state_resume_order_count_mismatch"
} else {
    for ($i = 0; $i -lt $expectedResumeOrder.Count; $i++) {
        if ([string]$actualResumeOrder[$i] -ne [string]$expectedResumeOrder[$i]) {
            $violations += "session_state_resume_order_mismatch:index=$i:expected=$($expectedResumeOrder[$i]):actual=$($actualResumeOrder[$i])"
        }
    }
}

foreach ($requiredSnippet in @(
    'read `session-state.json`',
    'read `native-tasklist.json`',
    'read `agent-workflow-skill-foundation-audit.json`'
)) {
    if (-not $readmeText.Contains($requiredSnippet)) {
        $violations += "readme_missing_resume_snippet:$requiredSnippet"
    }
}

foreach ($requiredSnippet in @(
    ".codex/SESSION-HARD-GUARDS.md",
    ".codex/native-tasklist.json",
    ".codex/agent-workflow-skill-foundation-audit.json"
) ) {
    if (-not $handoffText.Contains($requiredSnippet)) {
        $violations += "handoff_missing_resume_snippet:$requiredSnippet"
    }
}

$expectedCommands = @(
    "powershell -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/validate-native-tasklist.ps1",
    "powershell -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/validate-execution-guardrails.ps1",
    "powershell -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/validate-agent-workflow-skill-foundation.ps1",
    "powershell -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/validate-codex-session-foundation.ps1"
)
foreach ($command in $expectedCommands) {
    if (-not $hardGuardsText.Contains($command)) {
        $violations += "session_hard_guards_missing_command:$command"
    }
}

$requiredGuardIds = @(
    "GUARD-PATH-001",
    "GUARD-VERIFY-001",
    "GUARD-REPORT-001",
    "GUARD-FOUNDATION-001",
    "GUARD-CODEX-STATE-001"
)

$alwaysRunIds = @($tasklist.priorityPolicy.alwaysRunBeforeAnyTask | ForEach-Object { [string]$_ })
foreach ($guardId in $requiredGuardIds) {
    if ($alwaysRunIds -notcontains $guardId) {
        $violations += "native_tasklist_priority_missing_guard:$guardId"
    }
}

$taskById = @{}
foreach ($task in @($tasklist.tasks)) {
    $taskById[[string]$task.id] = $task
}

foreach ($guardId in $requiredGuardIds) {
    if (-not $taskById.ContainsKey($guardId)) {
        $violations += "native_tasklist_missing_guard_task:$guardId"
        continue
    }
    $guardTask = $taskById[$guardId]
    if ([string]$guardTask.kind -ne "guard") {
        $violations += "native_tasklist_guard_kind_mismatch:$guardId"
    }
    if ($guardTask.blocking -ne $true) {
        $violations += "native_tasklist_guard_not_blocking:$guardId"
    }
}

$enforcementOrder = @($audit.nativeSupport.enforcementOrder | ForEach-Object { [string]$_ })
$expectedEnforcementOrder = @(
    "validate-native-tasklist.ps1",
    "validate-execution-guardrails.ps1",
    "validate-agent-workflow-skill-foundation.ps1",
    "validate-codex-session-foundation.ps1",
    "implementation",
    "real verification",
    "report with required sections"
)
if (@($enforcementOrder).Count -ne @($expectedEnforcementOrder).Count) {
    $violations += "audit_enforcement_order_count_mismatch"
} else {
    for ($i = 0; $i -lt $expectedEnforcementOrder.Count; $i++) {
        if ([string]$enforcementOrder[$i] -ne [string]$expectedEnforcementOrder[$i]) {
            $violations += "audit_enforcement_order_mismatch:index=$i:expected=$($expectedEnforcementOrder[$i]):actual=$($enforcementOrder[$i])"
        }
    }
}

$auditGuardIds = @($audit.hardGuards.guards | ForEach-Object { [string]$_.id })
foreach ($guardId in $requiredGuardIds) {
    if ($auditGuardIds -notcontains $guardId) {
        $violations += "audit_missing_guard:$guardId"
    }
}

$auditTaskById = @{}
foreach ($task in @($audit.tasks)) {
    $auditTaskById[[string]$task.id] = $task
}

foreach ($taskId in @($auditTaskById.Keys)) {
    if (-not $taskById.ContainsKey($taskId)) {
        if ([string]$auditTaskById[$taskId].scope -eq "codex_only") {
            $violations += "audit_codex_task_missing_from_native_tasklist:$taskId"
        }
        continue
    }
    $auditStatus = [string]$auditTaskById[$taskId].status
    $nativeStatus = [string]$taskById[$taskId].status
    if ($auditStatus -ne $nativeStatus) {
        $violations += "task_status_mirror_mismatch:${taskId}:audit=$auditStatus:native=$nativeStatus"
    }
}

$completedCodexTasks = @($tasklist.tasks | Where-Object { [string]$_.scope -eq "codex_only" -and [string]$_.kind -eq "workitem" -and [string]$_.status -eq "completed" })
foreach ($task in $completedCodexTasks) {
    if (-not $auditTaskById.ContainsKey([string]$task.id)) {
        $violations += "completed_codex_task_missing_from_audit:$([string]$task.id)"
    }
}

if ([string]$audit.statusControl.sourceOfTruth -ne ".codex/native-tasklist.json") {
    $violations += "audit_status_control_source_of_truth_mismatch"
}

$result = [ordered]@{
    repoRoot = $RepoRoot
    checkedFiles = @(
        $readmePath,
        $sessionStatePath,
        $handoffPath,
        $standardsPath,
        $tasklistPath,
        $auditPath,
        $hardGuardsPath
    )
    counts = [ordered]@{
        requiredGuardCount = @($requiredGuardIds).Count
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

Write-Host "Validate Codex session foundation"
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
