param(
    [string]$RequestId = ("req-" + (Get-Date -Format "yyyyMMddHHmmss")),
    [string]$UserId = "example-user",
    [string]$DisplayName = "Example User",
    [string]$PersonaStyle = "professional_concise",
    [string[]]$PersonaBoundaries = @(
        "default_no_exec",
        "default_no_ops_actions",
        "default_no_cross_user_memory"
    ),
    [string[]]$PersonaNotes = @(
        "prefer concise answers",
        "store stable preferences only after repeated evidence"
    ),
    [string[]]$AccountIds = @("example-account"),
    [string[]]$ChannelIds = @(),
    [string]$Language = "zh-CN",
    [string]$Tone = "professional",
    [string]$MemorySensitivity = "strict",
    [switch]$OverwriteWorkspaceFiles,
    [switch]$Apply,
    [switch]$ValidateAfterApply
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

function Upsert-ByKey {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Items,
        [Parameter(Mandatory = $true)]
        [object]$Candidate,
        [Parameter(Mandatory = $true)]
        [string[]]$Keys
    )

    $list = @()
    $found = $false
    foreach ($item in @($Items)) {
        $isMatch = $true
        foreach ($k in $Keys) {
            if ([string]$item.$k -ne [string]$Candidate.$k) {
                $isMatch = $false
                break
            }
        }
        if ($isMatch) {
            $list += $Candidate
            $found = $true
        } else {
            $list += $item
        }
    }

    if (-not $found) {
        $list += $Candidate
    }

    return @($list)
}

function Add-BindingEntries {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Bindings,
        [Parameter(Mandatory = $true)]
        [object[]]$NewEntries
    )

    $existing = @()
    foreach ($item in @($Bindings)) {
        $existing += $item
    }

        foreach ($entry in @($NewEntries)) {
            $exists = $false
            foreach ($item in @($existing)) {
                $sameUser = ([string]$item.userId -eq [string]$entry.userId)
                $sameAgent = ([string]$item.agentId -eq [string]$entry.agentId)
                $itemAccount = if ($null -ne $item.match -and $item.match.PSObject.Properties.Name -contains "accountId") { [string]$item.match.accountId } else { "" }
                $entryAccount = if ($null -ne $entry.match -and $entry.match.PSObject.Properties.Name -contains "accountId") { [string]$entry.match.accountId } else { "" }
                $itemChannel = if ($null -ne $item.match -and $item.match.PSObject.Properties.Name -contains "channelId") { [string]$item.match.channelId } else { "" }
                $entryChannel = if ($null -ne $entry.match -and $entry.match.PSObject.Properties.Name -contains "channelId") { [string]$entry.match.channelId } else { "" }
                $sameAccount = ($itemAccount -eq $entryAccount)
                $sameChannel = ($itemChannel -eq $entryChannel)
                if ($sameUser -and $sameAgent -and $sameAccount -and $sameChannel) {
                    $exists = $true
                    break
                }
            }
        if (-not $exists) {
            $existing += $entry
        }
    }

    return @($existing)
}

function Append-JsonlLine {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [object]$Item
    )

    ($Item | ConvertTo-Json -Compress -Depth 12) | Add-Content -Path $Path -Encoding UTF8
}

function Read-JsonlObjects {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $items = @()
    if (-not (Test-Path $Path)) { return $items }
    foreach ($line in @(Get-Content -Path $Path)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try {
            $items += ($line | ConvertFrom-Json)
        } catch {}
    }
    return @($items)
}

function Jsonl-HasMatch {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Items,
        [Parameter(Mandatory = $true)]
        [object]$Candidate,
        [Parameter(Mandatory = $true)]
        [string[]]$Keys
    )

    foreach ($item in @($Items)) {
        $match = $true
        foreach ($k in $Keys) {
            if ($item -is [System.Collections.IDictionary]) {
                $left = if ($item.Contains($k)) { [string]$item[$k] } else { "" }
            } else {
                $left = if ($item.PSObject.Properties.Name -contains $k) { [string]$item.$k } else { "" }
            }
            if ($Candidate -is [System.Collections.IDictionary]) {
                $right = if ($Candidate.Contains($k)) { [string]$Candidate[$k] } else { "" }
            } else {
                $right = if ($Candidate.PSObject.Properties.Name -contains $k) { [string]$Candidate.$k } else { "" }
            }
            if ($left -ne $right) {
                $match = $false
                break
            }
        }
        if ($match) { return $true }
    }
    return $false
}

$root = Resolve-RepoRoot -startPath $PSScriptRoot
$usersPath = Join-Path $root "state/users/index.json"
$agentsPath = Join-Path $root "state/agents/catalog.json"
$openclawPath = Join-Path $root "openclaw.json"
$userProvisionAuditPath = Join-Path $root "state/audit/user-provision.jsonl"
$reviewGateAuditPath = Join-Path $root "state/audit/review-gate.jsonl"

foreach ($path in @($usersPath, $agentsPath, $openclawPath, $userProvisionAuditPath, $reviewGateAuditPath)) {
    if (-not (Test-Path $path)) {
        throw "Missing required file: $path"
    }
}

$dailyAgentId = "daily-$UserId"
$workspaceId = "workspace-daily-$UserId"
$workspaceRoot = Join-Path $root $workspaceId
$now = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
$reviewId = "review-$RequestId-$UserId"

$userProfile = [ordered]@{
    userId = $UserId
    displayName = $DisplayName
    persona = [ordered]@{
        style = $PersonaStyle
        boundaries = @($PersonaBoundaries)
        customNotes = @($PersonaNotes)
    }
    dailyAgentId = $dailyAgentId
    workspaceId = $workspaceId
    capabilityProfile = "daily_light"
    bindings = [ordered]@{
        accountIds = @($AccountIds)
        channelIds = @($ChannelIds)
    }
    preferences = [ordered]@{
        language = $Language
        tone = $Tone
        memorySensitivity = $MemorySensitivity
    }
    status = "pending_review"
    createdAt = $now
    updatedAt = $now
}

$agentRecord = [ordered]@{
    agentId = $dailyAgentId
    role = "daily_user_domain"
    runtime = "native"
    workspaceId = $workspaceId
    status = "pending_review"
}

$bindingEntries = @()
foreach ($accountId in @($AccountIds)) {
    if (-not [string]::IsNullOrWhiteSpace([string]$accountId)) {
        $bindingEntries += [ordered]@{
            userId = $UserId
            agentId = $dailyAgentId
            match = [ordered]@{
                accountId = [string]$accountId
            }
        }
    }
}
foreach ($channelId in @($ChannelIds)) {
    if (-not [string]::IsNullOrWhiteSpace([string]$channelId)) {
        $bindingEntries += [ordered]@{
            userId = $UserId
            agentId = $dailyAgentId
            match = [ordered]@{
                channelId = [string]$channelId
            }
        }
    }
}

$userProvisionEvents = @(
    [ordered]@{
        timestamp = $now
        event = "user_provision_requested"
        requestId = $RequestId
        userId = $UserId
        requestedBy = "agent-smith"
        status = "accepted"
    },
    [ordered]@{
        timestamp = $now
        event = "user_workspace_materialized"
        requestId = $RequestId
        userId = $UserId
        workspaceId = $workspaceId
        status = "success"
    },
    [ordered]@{
        timestamp = $now
        event = "user_agent_registered"
        requestId = $RequestId
        userId = $UserId
        agentId = $dailyAgentId
        status = "success"
    },
    [ordered]@{
        timestamp = $now
        event = "user_binding_updated"
        requestId = $RequestId
        userId = $UserId
        status = "success"
    },
    [ordered]@{
        timestamp = $now
        event = "user_provision_submitted_for_review"
        requestId = $RequestId
        userId = $UserId
        reviewer = "critic"
        status = "pending_review"
    }
)

$reviewRecord = [ordered]@{
    timestamp = $now
    requestId = $RequestId
    reviewId = $reviewId
    targetType = "user_instance"
    targetRef = $dailyAgentId
    reviewer = "critic"
    status = "pending"
    lifecyclePhase = "submitted"
    flow = [ordered]@{
        startedBy = "agent-smith"
        routedBy = "orchestrator"
        handledBy = "agent-smith"
        closedBy = "apply-daily-user-review-outcome"
        nextStep = "wait_critic_review"
    }
    createdAt = $now
    updatedAt = $now
}

$workspaceFiles = [ordered]@{
    "AGENTS.md" = @"
# AGENTS

## 1. Role
You are `$dailyAgentId`, the daily runtime for `$UserId`.

## 2. Responsibilities
- Handle this user's daily chat and queries.
- Maintain local memory for this user only.
- Provide lightweight help and small task support.

## 3. Boundaries
- No exec.
- No ops actions.
- No deployment.
- No cross-user memory.
- Keep writes local and minimal.
"@
    "SOUL.md" = @"
# SOUL

## 1. Style
- Professional
- Concise
- Stable
- Privacy-first
"@
    "USER.md" = @"
# USER

## Service Target
- Direct service target: `$UserId`

## Default Scope
- Daily chat
- Lightweight queries
- Short task assistance
"@
    "IDENTITY.md" = @"
# IDENTITY

## 1. Identity
- agentId: `$dailyAgentId`
- workspaceId: `$workspaceId`
- role: daily_user_domain
"@
    "TOOLS.md" = @"
# TOOLS

## Allowed
- Lightweight chat and query handling
- Local memory notes
- Read-only inspection in this workspace

## Restricted
- exec
- deployment
- broad file writes
- ops lifecycle actions
"@
    "HEARTBEAT.md" = @"
# HEARTBEAT

## Checks
- Confirm workspace identity is stable.
- Check memory for cross-user leakage.
- Check profile and bindings for drift.
"@
    "BOOT.md" = @"
# BOOT

## Startup Checklist
1. Confirm agent identity.
2. Read role and tool files.
3. Check memory and state files.
"@
    "BOOTSTRAP.md" = @"
# BOOTSTRAP

## Purpose
Initialize the daily user workspace for `$UserId`.
"@
    "MEMORY.md" = @"
# MEMORY

## Rules
- Keep only durable and validated preferences.
- Never store secrets.
- Never store cross-user data.
"@
}

$profileJson = ($userProfile | ConvertTo-Json -Depth 12)
$localStateJson = ([ordered]@{
    agentId = $dailyAgentId
    status = "materialized"
    createdBy = "agent-smith"
} | ConvertTo-Json -Depth 8)

Write-Host "Replay requestId: $RequestId"
Write-Host "Mode: $(if ($Apply) { "apply" } else { "dry-run" })"
Write-Host "UserId: $UserId"
Write-Host "AgentId: $dailyAgentId"
Write-Host "WorkspaceId: $workspaceId"
Write-Host "Binding entries to add: $(@($bindingEntries).Count)"
Write-Host "User-provision events: $(@($userProvisionEvents).Count)"
Write-Host "Review-gate events: 1"

if (-not $Apply) {
    Write-Host "----- workspace files preview -----"
    @($workspaceFiles.Keys) | ForEach-Object { Write-Host "$workspaceId/$_" }
    Write-Host "$workspaceId/profile.json"
    Write-Host "$workspaceId/state/local-state.json"
    Write-Host "----- user-provision.jsonl preview -----"
    $userProvisionEvents | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 12 }
    Write-Host "----- review-gate.jsonl preview -----"
    $reviewRecord | ConvertTo-Json -Compress -Depth 12
    exit 0
}

$usersDoc = Get-Content -Raw -Path $usersPath | ConvertFrom-Json
$agentsDoc = Get-Content -Raw -Path $agentsPath | ConvertFrom-Json
$openclawDoc = Get-Content -Raw -Path $openclawPath | ConvertFrom-Json

$usersDoc.users = Upsert-ByKey -Items @($usersDoc.users) -Candidate $userProfile -Keys @("userId")
$agentsDoc.agents = Upsert-ByKey -Items @($agentsDoc.agents) -Candidate $agentRecord -Keys @("agentId")
$openclawDoc.bindings = Add-BindingEntries -Bindings @($openclawDoc.bindings) -NewEntries @($bindingEntries)

$workspaceDirs = @(
    $workspaceRoot,
    (Join-Path $workspaceRoot "memory"),
    (Join-Path $workspaceRoot "docs"),
    (Join-Path $workspaceRoot "state")
)
foreach ($dir in $workspaceDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}

foreach ($name in @($workspaceFiles.Keys)) {
    $target = Join-Path $workspaceRoot $name
    if ((-not (Test-Path $target)) -or $OverwriteWorkspaceFiles) {
        Set-Content -Path $target -Value $workspaceFiles[$name] -Encoding UTF8
    }
}

Set-Content -Path (Join-Path $workspaceRoot "profile.json") -Value $profileJson -Encoding UTF8
Set-Content -Path (Join-Path $workspaceRoot "state/local-state.json") -Value $localStateJson -Encoding UTF8

Set-Content -Path $usersPath -Value ($usersDoc | ConvertTo-Json -Depth 12) -Encoding UTF8
Set-Content -Path $agentsPath -Value ($agentsDoc | ConvertTo-Json -Depth 12) -Encoding UTF8
Set-Content -Path $openclawPath -Value ($openclawDoc | ConvertTo-Json -Depth 20) -Encoding UTF8

$existingUserProvision = Read-JsonlObjects -Path $userProvisionAuditPath
foreach ($eventItem in $userProvisionEvents) {
    $exists = Jsonl-HasMatch -Items $existingUserProvision -Candidate $eventItem -Keys @("requestId", "event", "userId")
    if (-not $exists) {
        Append-JsonlLine -Path $userProvisionAuditPath -Item $eventItem
    }
}
$existingReviewGate = Read-JsonlObjects -Path $reviewGateAuditPath
$hasReview = Jsonl-HasMatch -Items $existingReviewGate -Candidate $reviewRecord -Keys @("reviewId", "lifecyclePhase", "targetRef")
if (-not $hasReview) {
    Append-JsonlLine -Path $reviewGateAuditPath -Item $reviewRecord
}

Write-Host "Applied workspace and state updates."
Write-Host "Updated: $usersPath"
Write-Host "Updated: $agentsPath"
Write-Host "Updated: $openclawPath"
Write-Host "Appended: $userProvisionAuditPath"
Write-Host "Appended: $reviewGateAuditPath"

if ($ValidateAfterApply) {
    $validateScript = Join-Path $root "Xuanzhi-Dev/testing/scripts/validate-daily-user-chain.ps1"
    if (-not (Test-Path $validateScript)) {
        throw "Missing validation script: $validateScript"
    }
    Write-Host "Running validation: validate-daily-user-chain.ps1 -UserId $UserId"
    powershell -ExecutionPolicy Bypass -File $validateScript -UserId $UserId
    if ($LASTEXITCODE -ne 0) {
        throw "Validation command failed with exit code $LASTEXITCODE"
    }
}
