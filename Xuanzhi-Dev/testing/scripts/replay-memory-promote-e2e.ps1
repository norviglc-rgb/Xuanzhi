param(
    [string]$RequestId = ("req-" + (Get-Date -Format "yyyyMMddHHmmss")),
    [string]$WorkspaceId = "workspace-daily-demo",
    [string]$SourceEntryRef = "memory/2026-03-22.md#L1",
    [string]$Reason = "validated_user_preference",
    [ValidateSet("approved", "rejected", "needs_changes")]
    [string]$ReviewStatus = "approved",
    [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$memoryAuditPath = Join-Path $root "state/audit/memory-promotion.jsonl"
$reviewAuditPath = Join-Path $root "state/audit/review-gate.jsonl"

if (-not (Test-Path $memoryAuditPath)) {
    throw "Missing audit stream: $memoryAuditPath"
}
if (-not (Test-Path $reviewAuditPath)) {
    throw "Missing audit stream: $reviewAuditPath"
}

$now = (Get-Date).ToString("o")
$reviewId = "review-memory-promote-$RequestId"
$targetRef = "$WorkspaceId`:$SourceEntryRef"

$memoryEvents = @(
    [ordered]@{
        event = "requested"
        requestId = $RequestId
        workspaceId = $WorkspaceId
        sourceEntryRef = $SourceEntryRef
        reason = $Reason
        owner = "critic"
        createdAt = $now
        updatedAt = $now
    },
    [ordered]@{
        event = "validated"
        requestId = $RequestId
        workspaceId = $WorkspaceId
        sourceEntryRef = $SourceEntryRef
        owner = "critic"
        createdAt = $now
        updatedAt = $now
    },
    [ordered]@{
        event = "promoted"
        requestId = $RequestId
        workspaceId = $WorkspaceId
        sourceEntryRef = $SourceEntryRef
        owner = "critic"
        createdAt = $now
        updatedAt = $now
    },
    [ordered]@{
        event = "review_created"
        requestId = $RequestId
        workspaceId = $WorkspaceId
        sourceEntryRef = $SourceEntryRef
        reviewId = $reviewId
        owner = "critic"
        createdAt = $now
        updatedAt = $now
    },
    [ordered]@{
        event = "decision_applied"
        requestId = $RequestId
        workspaceId = $WorkspaceId
        sourceEntryRef = $SourceEntryRef
        reviewId = $reviewId
        status = $ReviewStatus
        owner = "critic"
        createdAt = $now
        updatedAt = $now
    }
)

$reviewEvents = @(
    [ordered]@{
        reviewId = $reviewId
        targetType = "memory_promotion"
        targetRef = $targetRef
        reviewer = "critic"
        status = "pending"
        lifecyclePhase = "submitted"
        flow = [ordered]@{
            startedBy = "critic"
            routedBy = "orchestrator"
            handledBy = "critic"
            closedBy = "apply-memory-promotion-review-outcome"
            nextStep = "wait_critic_review"
        }
        findings = @(
            [ordered]@{
                severity = "info"
                message = "memory_promotion_candidate_submitted"
                suggestedAction = $Reason
            }
        )
        createdAt = $now
        updatedAt = $now
    },
    [ordered]@{
        reviewId = $reviewId
        targetType = "memory_promotion"
        targetRef = $targetRef
        reviewer = "critic"
        status = $ReviewStatus
        lifecyclePhase = "decision"
        flow = [ordered]@{
            startedBy = "critic"
            routedBy = "orchestrator"
            handledBy = "critic"
            closedBy = "apply-memory-promotion-review-outcome"
            nextStep = $(if ($ReviewStatus -eq "needs_changes") { "revise_candidate_and_resubmit" } else { "none" })
        }
        findings = @(
            [ordered]@{
                severity = $(if ($ReviewStatus -eq "approved") { "info" } else { "warning" })
                message = "memory_promotion_review_outcome"
            }
        )
        createdAt = $now
        updatedAt = $now
    },
    [ordered]@{
        reviewId = $reviewId
        targetType = "memory_promotion"
        targetRef = $targetRef
        reviewer = "critic"
        status = $ReviewStatus
        lifecyclePhase = "closure"
        flow = [ordered]@{
            startedBy = "critic"
            routedBy = "orchestrator"
            handledBy = "critic"
            closedBy = "apply-memory-promotion-review-outcome"
            nextStep = $(if ($ReviewStatus -eq "needs_changes") { "revise_candidate_and_resubmit" } else { "none" })
        }
        createdAt = $now
        updatedAt = $now
    }
)

Write-Host "Replay requestId: $RequestId"
Write-Host "Mode: $(if ($Apply) { "apply" } else { "dry-run" })"
Write-Host "Memory event count: $($memoryEvents.Count)"
Write-Host "Review event count: $($reviewEvents.Count)"

if ($Apply) {
    foreach ($item in $memoryEvents) {
        ($item | ConvertTo-Json -Compress -Depth 8) | Add-Content -Path $memoryAuditPath -Encoding UTF8
    }
    foreach ($item in $reviewEvents) {
        ($item | ConvertTo-Json -Compress -Depth 8) | Add-Content -Path $reviewAuditPath -Encoding UTF8
    }
    Write-Host "Wrote memory audit: $memoryAuditPath"
    Write-Host "Wrote review audit: $reviewAuditPath"
} else {
    Write-Host "----- memory-promotion.jsonl preview -----"
    $memoryEvents | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 8 }
    Write-Host "----- review-gate.jsonl preview -----"
    $reviewEvents | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 8 }
}
