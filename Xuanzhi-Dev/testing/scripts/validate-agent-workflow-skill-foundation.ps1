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

function Read-Json([string]$path) {
    if (-not (Test-Path $path)) {
        throw "Missing required file: $path"
    }
    return (Get-Content -Path $path -Raw | ConvertFrom-Json)
}

$routingPath = Join-Path $RepoRoot "policies/routing-policy.json"
$createDailyPath = Join-Path $RepoRoot "workflows/users/create-daily-user.json"
$createSkillPath = Join-Path $RepoRoot "workflows/skills/create-skill.json"
$applySkillReviewPath = Join-Path $RepoRoot "workflows/skills/apply-skill-review-outcome.json"
$skillsCatalogPath = Join-Path $RepoRoot "state/skills/catalog.json"
$agentsCatalogPath = Join-Path $RepoRoot "state/agents/catalog.json"
$skillDir = Join-Path $RepoRoot "skills/agent-smith-daily-user-materialization"
$skillJsonPath = Join-Path $skillDir "skill.json"
$skillMdPath = Join-Path $skillDir "SKILL.md"
$agentSmithWorkspace = Join-Path $RepoRoot "workspace-agent-smith"

$routing = Read-Json $routingPath
$createDaily = Read-Json $createDailyPath
$createSkill = Read-Json $createSkillPath
$skillsCatalog = Read-Json $skillsCatalogPath
$agentsCatalog = Read-Json $agentsCatalogPath
$skillJson = Read-Json $skillJsonPath

$violations = @()

if ([string]$routing.ownership_routes.create_daily_user_runtime.target -ne "agent-smith") {
    $violations += "ownership_route_create_daily_user_runtime_target_not_agent_smith"
}
if ([string]$routing.closure_routes.daily_user_lifecycle.start -ne "agent-smith") {
    $violations += "closure_route_daily_user_lifecycle_start_not_agent_smith"
}
if ([string]$createDaily.owner -ne "agent-smith") {
    $violations += "workflow_create_daily_user_owner_not_agent_smith"
}

$materializationStep = @($createDaily.steps | Where-Object { [string]$_.id -eq "run_materialization_skill" }) | Select-Object -First 1
if ($null -eq $materializationStep) {
    $violations += "workflow_missing_run_materialization_skill_step"
} else {
    if ([string]$materializationStep.action -ne "invoke_skill") {
        $violations += "workflow_run_materialization_skill_action_not_invoke_skill"
    }
    if ([string]$materializationStep.targetAgent -ne "agent-smith") {
        $violations += "workflow_run_materialization_skill_target_not_agent_smith"
    }
    if ([string]$materializationStep.skillId -ne "agent-smith-daily-user-materialization") {
        $violations += "workflow_run_materialization_skill_skillid_mismatch"
    }
}

$reviewRuleText = (@($createDaily.steps | Where-Object { [string]$_.id -eq "build_review_record" } | Select-Object -First 1).rules) -join " | "
if (-not $reviewRuleText.Contains("flow.startedBy = agent-smith")) {
    $violations += "workflow_review_flow_startedby_not_agent_smith"
}
if (-not $reviewRuleText.Contains("flow.handledBy = agent-smith")) {
    $violations += "workflow_review_flow_handledby_not_agent_smith"
}

$auditRuleText = (@($createDaily.steps | Where-Object { [string]$_.id -eq "build_user_provision_audit_record" } | Select-Object -First 1).rules) -join " | "
if (-not $auditRuleText.Contains("owner = agent-smith")) {
    $violations += "workflow_user_provision_audit_owner_not_agent_smith"
}

$skillCatalogRecord = @($skillsCatalog.skills | Where-Object { [string]$_.skillId -eq "agent-smith-daily-user-materialization" }) | Select-Object -First 1
if ($null -eq $skillCatalogRecord) {
    $violations += "skill_catalog_missing_agent_smith_daily_user_materialization"
} else {
    if ([string]$skillCatalogRecord.owner -ne "agent-smith") {
        $violations += "skill_catalog_owner_mismatch"
    }
    if ([string]$skillCatalogRecord.status -ne "active") {
        $violations += "skill_catalog_status_not_active"
    }
}

if ([string]$skillJson.skillId -ne "agent-smith-daily-user-materialization") {
    $violations += "skill_json_skillid_mismatch"
}
if ([string]$skillJson.owner -ne "agent-smith") {
    $violations += "skill_json_owner_not_agent_smith"
}
if ([string]$skillJson.entrypoint -ne "materialize_daily_user_runtime") {
    $violations += "skill_json_entrypoint_mismatch"
}
if ([string]$skillJson.status -ne "active") {
    $violations += "skill_json_status_not_active"
}
if (-not (Test-Path $skillMdPath)) {
    $violations += "skill_markdown_missing"
}

$knownAgents = New-Object "System.Collections.Generic.HashSet[string]" ([System.StringComparer]::OrdinalIgnoreCase)
foreach ($agent in @($agentsCatalog.agents)) {
    [void]$knownAgents.Add([string]$agent.agentId)
}
foreach ($wfPath in @(Get-ChildItem -Path (Join-Path $RepoRoot "workflows") -Recurse -Filter *.json)) {
    $wf = Get-Content -Path $wfPath.FullName -Raw | ConvertFrom-Json
    $owner = [string]$wf.owner
    if ([string]::IsNullOrWhiteSpace($owner)) {
        $violations += "workflow_owner_missing:$($wfPath.FullName)"
        continue
    }
    if (-not $knownAgents.Contains($owner)) {
        $violations += "workflow_owner_not_registered_agent:$($wf.workflowId):$owner"
    }
}

# All skill lifecycle contracts must be explicitly machine-readable.
if (-not (Test-Path $createSkillPath)) {
    $violations += "workflow_create_skill_missing"
}
if (-not (Test-Path $applySkillReviewPath)) {
    $violations += "workflow_apply_skill_review_missing"
}

$catalogSkillIdSet = New-Object "System.Collections.Generic.HashSet[string]" ([System.StringComparer]::OrdinalIgnoreCase)
foreach ($skill in @($skillsCatalog.skills)) {
    $skillId = [string]$skill.skillId
    if ([string]::IsNullOrWhiteSpace($skillId)) {
        $violations += "skill_catalog_skillid_missing"
        continue
    }
    [void]$catalogSkillIdSet.Add($skillId)

    if ([string]::IsNullOrWhiteSpace([string]$skill.owner)) {
        $violations += "skill_catalog_owner_missing:$skillId"
    } elseif (-not $knownAgents.Contains([string]$skill.owner)) {
        $violations += "skill_catalog_owner_not_registered_agent:${skillId}:$([string]$skill.owner)"
    }

    if ([string]::IsNullOrWhiteSpace([string]$skill.contractPath)) {
        $violations += "skill_catalog_contract_path_missing:$skillId"
        continue
    }

    $contractAbs = Join-Path $RepoRoot ([string]$skill.contractPath -replace "/", "\")
    if (-not (Test-Path $contractAbs)) {
        $violations += "skill_contract_path_not_found:${skillId}:$([string]$skill.contractPath)"
        continue
    }

    $skillContract = Get-Content -Path $contractAbs -Raw | ConvertFrom-Json
    if ([string]$skillContract.skillId -ne $skillId) {
        $violations += "skill_contract_skillid_mismatch:${skillId}:$([string]$skillContract.skillId)"
    }
    if ([string]$skillContract.owner -ne [string]$skill.owner) {
        $violations += "skill_contract_owner_mismatch:$skillId"
    }

    $skillDirAbs = Split-Path -Path $contractAbs -Parent
    $skillMdAbs = Join-Path $skillDirAbs "SKILL.md"
    if (-not (Test-Path $skillMdAbs)) {
        $violations += "skill_markdown_missing:$skillId"
    }

    $catalogSubmit = [string]$skill.reviewPath.submitWorkflow
    $catalogApply = [string]$skill.reviewPath.applyWorkflow
    if ([string]::IsNullOrWhiteSpace($catalogSubmit) -or [string]::IsNullOrWhiteSpace($catalogApply)) {
        $violations += "skill_catalog_review_path_missing:$skillId"
    } else {
        $catalogSubmitAbs = Join-Path $RepoRoot ($catalogSubmit -replace "/", "\")
        $catalogApplyAbs = Join-Path $RepoRoot ($catalogApply -replace "/", "\")
        if (-not (Test-Path $catalogSubmitAbs)) {
            $violations += "skill_catalog_submit_workflow_not_found:${skillId}:$catalogSubmit"
        }
        if (-not (Test-Path $catalogApplyAbs)) {
            $violations += "skill_catalog_apply_workflow_not_found:${skillId}:$catalogApply"
        }
    }

    $contractSubmit = [string]$skillContract.reviewPath.submitWorkflow
    $contractApply = [string]$skillContract.reviewPath.applyWorkflow
    if ([string]::IsNullOrWhiteSpace($contractSubmit) -or [string]::IsNullOrWhiteSpace($contractApply)) {
        $violations += "skill_contract_review_path_missing:$skillId"
    } else {
        $contractSubmitAbs = Join-Path $RepoRoot ($contractSubmit -replace "/", "\")
        $contractApplyAbs = Join-Path $RepoRoot ($contractApply -replace "/", "\")
        if (-not (Test-Path $contractSubmitAbs)) {
            $violations += "skill_contract_submit_workflow_not_found:${skillId}:$contractSubmit"
        }
        if (-not (Test-Path $contractApplyAbs)) {
            $violations += "skill_contract_apply_workflow_not_found:${skillId}:$contractApply"
        }
    }
}

$skillDirs = @(Get-ChildItem -Path (Join-Path $RepoRoot "skills") -Directory)
foreach ($dir in $skillDirs) {
    $skillJsonCandidate = Join-Path $dir.FullName "skill.json"
    $skillMdCandidate = Join-Path $dir.FullName "SKILL.md"
    if (-not (Test-Path $skillJsonCandidate) -and -not (Test-Path $skillMdCandidate)) {
        continue
    }
    if (-not (Test-Path $skillJsonCandidate)) {
        $violations += "skill_dir_missing_contract_json:$($dir.Name)"
        continue
    }
    $localSkill = Get-Content -Path $skillJsonCandidate -Raw | ConvertFrom-Json
    $localSkillId = [string]$localSkill.skillId
    if ([string]::IsNullOrWhiteSpace($localSkillId)) {
        $violations += "skill_contract_skillid_missing_in_dir:$($dir.Name)"
        continue
    }
    if (-not $catalogSkillIdSet.Contains($localSkillId)) {
        $violations += "skill_contract_not_registered_in_catalog:$localSkillId"
    }
}

$requiredWorkspaceFiles = @(
    "AGENTS.md",
    "SOUL.md",
    "USER.md",
    "IDENTITY.md",
    "TOOLS.md",
    "HEARTBEAT.md",
    "BOOT.md",
    "BOOTSTRAP.md",
    "MEMORY.md"
)
foreach ($file in $requiredWorkspaceFiles) {
    $abs = Join-Path $agentSmithWorkspace $file
    if (-not (Test-Path $abs)) {
        $violations += "workspace_agent_smith_missing_required_file:$file"
    }
}

$result = [ordered]@{
    repoRoot = $RepoRoot
    checks = [ordered]@{
        routingPolicy = $routingPath
        createDailyWorkflow = $createDailyPath
        createSkillWorkflow = $createSkillPath
        applySkillReviewWorkflow = $applySkillReviewPath
        skillCatalog = $skillsCatalogPath
        skillPackage = $skillDir
        agentsCatalog = $agentsCatalogPath
    }
    counts = [ordered]@{
        workflowCount = @((Get-ChildItem -Path (Join-Path $RepoRoot "workflows") -Recurse -Filter *.json)).Count
        registeredAgentCount = @($agentsCatalog.agents).Count
        registeredSkillCount = @($skillsCatalog.skills).Count
        violations = @($violations).Count
        skillDirectoryCount = @($skillDirs).Count
    }
    violations = @($violations)
    passed = (@($violations).Count -eq 0)
    timestamp = (Get-Date).ToString("o")
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 10
    exit 0
}

Write-Host "Agent/Workflow/Skill foundation validation"
Write-Host "Workflow count: $($result.counts.workflowCount)"
Write-Host "Registered agent count: $($result.counts.registeredAgentCount)"
Write-Host "Registered skill count: $($result.counts.registeredSkillCount)"
Write-Host "Skill directory count: $($result.counts.skillDirectoryCount)"
Write-Host "Violations: $($result.counts.violations)"
Write-Host "PASSED: $($result.passed)"
if (@($violations).Count -gt 0) {
    Write-Host "Violation details:"
    foreach ($v in @($violations)) { Write-Host " - $v" }
}
