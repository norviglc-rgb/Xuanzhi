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

$commands = @(
    [ordered]@{ id = "validate-native-tasklist"; path = "Xuanzhi-Dev/testing/scripts/validate-native-tasklist.ps1" },
    [ordered]@{ id = "validate-execution-guardrails"; path = "Xuanzhi-Dev/testing/scripts/validate-execution-guardrails.ps1" },
    [ordered]@{ id = "validate-agent-workflow-skill-foundation"; path = "Xuanzhi-Dev/testing/scripts/validate-agent-workflow-skill-foundation.ps1" },
    [ordered]@{ id = "validate-codex-session-foundation"; path = "Xuanzhi-Dev/testing/scripts/validate-codex-session-foundation.ps1" },
    [ordered]@{ id = "validate-client-control-plane"; path = "Xuanzhi-Dev/testing/scripts/validate-client-control-plane.ps1" }
)

$results = @()
$failed = $false
foreach ($entry in $commands) {
    $scriptPath = Join-Path $RepoRoot ($entry.path -replace "/", "\")
    $jsonOutput = & powershell -ExecutionPolicy Bypass -File $scriptPath -RepoRoot $RepoRoot -AsJson
    $exitCode = $LASTEXITCODE
    $parsed = $null
    if (-not [string]::IsNullOrWhiteSpace(($jsonOutput | Out-String))) {
        $parsed = ($jsonOutput | Out-String | ConvertFrom-Json)
    }
    $passed = ($exitCode -eq 0)
    if ($null -ne $parsed -and $null -ne $parsed.passed) {
        $passed = ([bool]$parsed.passed)
    }
    $results += [ordered]@{
        id = [string]$entry.id
        path = [string]$entry.path
        passed = $passed
    }
    if (-not $passed) {
        $failed = $true
        break
    }
}

$result = [ordered]@{
    repoRoot = $RepoRoot
    validatorCount = @($results).Count
    results = @($results)
    passed = (-not $failed)
    timestamp = (Get-Date).ToString("o")
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 8
    if ($failed) { exit 1 } else { exit 0 }
}

Write-Host "Invoke session hard guards"
Write-Host "Validator count: $($result.validatorCount)"
Write-Host "PASSED: $($result.passed)"
if ($failed) { exit 1 }
