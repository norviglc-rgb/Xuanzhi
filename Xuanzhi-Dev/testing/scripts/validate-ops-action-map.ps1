param(
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

$root = Resolve-RepoRoot -startPath $PSScriptRoot
$mapPath = Join-Path $root "policies/ops-action-map.json"
$toolPolicyPath = Join-Path $root "policies/tool-policy-matrix.json"
$allowlistPath = Join-Path $root "hooks/ops-action-guard/allowlist.json"

$map = Get-Content -Path $mapPath -Raw | ConvertFrom-Json
$toolPolicy = Get-Content -Path $toolPolicyPath -Raw | ConvertFrom-Json
$allowlist = Get-Content -Path $allowlistPath -Raw | ConvertFrom-Json

$opsAllows = @($toolPolicy.agents.ops.allow)
$opsCapabilitySet = New-Object System.Collections.Generic.HashSet[string]
foreach ($c in $opsAllows) { [void]$opsCapabilitySet.Add([string]$c) }

$allowlistActionSet = New-Object System.Collections.Generic.HashSet[string]
foreach ($r in @($allowlist.rules)) {
    if ($null -ne $r.action) { [void]$allowlistActionSet.Add([string]$r.action) }
}

$workflowActionSet = New-Object System.Collections.Generic.HashSet[string]
$wfFiles = Get-ChildItem -Path (Join-Path $root "workflows") -Recurse -Filter *.json
foreach ($f in $wfFiles) {
    $wf = Get-Content -Path $f.FullName -Raw | ConvertFrom-Json
    if ([string]$wf.owner -eq "ops") {
        foreach ($step in @($wf.steps)) {
            if ($null -ne $step.action) { [void]$workflowActionSet.Add([string]$step.action) }
        }
    }
}

$verbMap = $map.workflowVerbToAbstractCapabilities.PSObject.Properties.Name
$mappedVerbs = New-Object System.Collections.Generic.HashSet[string]
foreach ($v in $verbMap) { [void]$mappedVerbs.Add([string]$v) }

$missingWorkflowVerbs = @()
foreach ($v in $workflowActionSet) {
    if (-not $mappedVerbs.Contains($v)) { $missingWorkflowVerbs += $v }
}

$capMap = $map.abstractCapabilityToAllowlistActions.PSObject.Properties.Name
$missingCapabilities = @()
foreach ($c in $capMap) {
    if (-not $opsCapabilitySet.Contains([string]$c) -and [string]$c -ne "read") {
        $missingCapabilities += [string]$c
    }
}

$missingAllowlistActions = @()
foreach ($cap in $map.abstractCapabilityToAllowlistActions.PSObject.Properties.Name) {
    $actions = @($map.abstractCapabilityToAllowlistActions.$cap)
    foreach ($a in $actions) {
        if (-not $allowlistActionSet.Contains([string]$a)) {
            $missingAllowlistActions += "$cap=>$a"
        }
    }
}

$passed = ($missingWorkflowVerbs.Count -eq 0 -and $missingCapabilities.Count -eq 0 -and $missingAllowlistActions.Count -eq 0)

$result = [ordered]@{
    passed = $passed
    timestamp = (Get-Date).ToString("o")
    stats = [ordered]@{
        opsWorkflowActionCount = $workflowActionSet.Count
        mappedVerbCount = $mappedVerbs.Count
        opsCapabilityCount = $opsCapabilitySet.Count
        allowlistActionCount = $allowlistActionSet.Count
    }
    missing = [ordered]@{
        workflowVerbs = $missingWorkflowVerbs | Sort-Object -Unique
        capabilitiesInToolPolicy = $missingCapabilities | Sort-Object -Unique
        allowlistActions = $missingAllowlistActions | Sort-Object -Unique
    }
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 8
    exit 0
}

Write-Host "PASSED: $passed"
Write-Host "Workflow actions (ops-owner): $($workflowActionSet.Count)"
Write-Host "Mapped verbs: $($mappedVerbs.Count)"
Write-Host "Ops capabilities: $($opsCapabilitySet.Count)"
Write-Host "Allowlist actions: $($allowlistActionSet.Count)"

if ($missingWorkflowVerbs.Count -gt 0) {
    Write-Host "Missing workflow verb mappings:"
    $missingWorkflowVerbs | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
}
if ($missingCapabilities.Count -gt 0) {
    Write-Host "Mapped capabilities not present in tool-policy ops.allow:"
    $missingCapabilities | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
}
if ($missingAllowlistActions.Count -gt 0) {
    Write-Host "Mapped allowlist actions missing from allowlist rules:"
    $missingAllowlistActions | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
}
