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

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = Resolve-RepoRoot -startPath $PSScriptRoot
} else {
    $RepoRoot = (Resolve-Path $RepoRoot).Path
}

$tasklistPath = Join-Path $RepoRoot ".codex/native-tasklist.json"
$schemaPath = Join-Path $RepoRoot ".codex/native-tasklist.schema.json"

if (-not (Test-Path $tasklistPath)) { throw "Missing: $tasklistPath" }
if (-not (Test-Path $schemaPath)) { throw "Missing: $schemaPath" }

$tasklist = Get-Content -Raw -Path $tasklistPath | ConvertFrom-Json

$errors = @()

if ($tasklist.tasks.Count -eq 0) {
    $errors += "tasks_empty"
}

$idSet = New-Object "System.Collections.Generic.HashSet[string]" ([System.StringComparer]::OrdinalIgnoreCase)
foreach ($task in @($tasklist.tasks)) {
    if (-not $idSet.Add([string]$task.id)) {
        $errors += "duplicate_task_id:$($task.id)"
    }
}

$blockingIds = @($tasklist.tasks | Where-Object { $_.blocking -eq $true } | ForEach-Object { [string]$_.id })
foreach ($required in @($tasklist.priorityPolicy.alwaysRunBeforeAnyTask)) {
    if ($blockingIds -notcontains [string]$required) {
        $errors += "priority_rule_missing_blocking_task:$required"
    }
}

$guardTasks = @($tasklist.tasks | Where-Object { [string]$_.kind -eq "guard" })
foreach ($guard in $guardTasks) {
    if ($null -eq $guard.checks -or @($guard.checks).Count -eq 0) {
        $errors += "guard_without_checks:$($guard.id)"
    }
}

$allowedStatus = @("pending", "in_progress", "blocked", "completed")
foreach ($task in @($tasklist.tasks)) {
    if ($allowedStatus -notcontains [string]$task.status) {
        $errors += "invalid_status:$($task.id):$($task.status)"
    }
}

$result = [ordered]@{
    tasklistPath = $tasklistPath
    schemaPath = $schemaPath
    taskCount = @($tasklist.tasks).Count
    guardTaskCount = @($guardTasks).Count
    blockingTaskCount = @($blockingIds).Count
    errors = @($errors)
    passed = (@($errors).Count -eq 0)
    timestamp = (Get-Date).ToString("o")
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 8
    exit 0
}

Write-Host "Validate native tasklist"
Write-Host "Task count: $($result.taskCount)"
Write-Host "Guard task count: $($result.guardTaskCount)"
Write-Host "Blocking task count: $($result.blockingTaskCount)"
Write-Host "Errors: $(@($result.errors).Count)"
Write-Host "PASSED: $($result.passed)"
