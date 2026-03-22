param(
    [string]$RuntimeRoot = (Join-Path $env:USERPROFILE ".openclaw"),
    [switch]$Apply,
    [switch]$IncludeAgentsState
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

$repoRoot = Resolve-RepoRoot -startPath $PSScriptRoot
$runtimeRootResolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($RuntimeRoot)

$copyItems = @(
    "openclaw.json",
    "docs/system",
    "policies",
    "schemas",
    "workflows",
    "state",
    "hooks",
    "skills",
    "workspace-orchestrator",
    "workspace-critic",
    "workspace-architect",
    "workspace-ops",
    "workspace-skills-smith",
    "workspace-agent-smith",
    "workspace-claude-code"
)

if ($IncludeAgentsState) {
    $copyItems += "agents"
}

function Ensure-Dir([string]$path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

function Copy-Path([string]$src, [string]$dst, [bool]$apply) {
    if (-not (Test-Path $src)) {
        return [ordered]@{ source = $src; target = $dst; status = "missing_source" }
    }

    $item = Get-Item $src
    if ($item.PSIsContainer) {
        if ($apply) {
            Ensure-Dir $dst
            Copy-Item -Path (Join-Path $src "*") -Destination $dst -Recurse -Force
        }
        return [ordered]@{ source = $src; target = $dst; status = "directory_synced_or_preview" }
    }

    if ($apply) {
        Ensure-Dir (Split-Path -Path $dst -Parent)
        Copy-Item -Path $src -Destination $dst -Force
    }
    return [ordered]@{ source = $src; target = $dst; status = "file_synced_or_preview" }
}

Write-Host "Repo root: $repoRoot"
Write-Host "Runtime root: $runtimeRootResolved"
Write-Host ("Mode: " + ($(if ($Apply) { "apply" } else { "dry-run" })))

$results = @()
foreach ($rel in $copyItems) {
    $src = Join-Path $repoRoot $rel
    $dst = Join-Path $runtimeRootResolved $rel
    $results += Copy-Path -src $src -dst $dst -apply:$Apply
}

$summary = [ordered]@{
    repoRoot = $repoRoot
    runtimeRoot = $runtimeRootResolved
    mode = $(if ($Apply) { "apply" } else { "dry-run" })
    itemCount = $results.Count
    includeAgentsState = [bool]$IncludeAgentsState
    timestamp = (Get-Date).ToString("o")
}

Write-Host "Sync summary:"
$summary.GetEnumerator() | ForEach-Object { Write-Host ("- {0}: {1}" -f $_.Key, $_.Value) }
Write-Host "Items:"
$results | ForEach-Object { Write-Host ("- [{0}] {1} -> {2}" -f $_.status, $_.source, $_.target) }
