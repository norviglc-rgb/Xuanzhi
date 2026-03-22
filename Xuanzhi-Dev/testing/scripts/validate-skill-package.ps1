param(
    [Parameter(Mandatory = $true)]
    [string]$SkillPath,
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$resolvedSkillPath = Resolve-Path -Path $SkillPath -ErrorAction Stop
$skillDir = $resolvedSkillPath.Path
$skillMdPath = Join-Path $skillDir "SKILL.md"

$result = [ordered]@{
    skillPath = $skillDir
    checks = [ordered]@{
        skillPathExists = $true
        skillMdExists = $false
        frontmatterName = $false
        frontmatterDescription = $false
        hasJsonGovernanceFile = $false
    }
    files = [ordered]@{
        jsonFiles = @()
    }
    passed = $false
}

if (Test-Path $skillMdPath) {
    $result.checks.skillMdExists = $true
    $skillMd = Get-Content -Path $skillMdPath -Raw
    $result.checks.frontmatterName = ($skillMd -match "(?m)^name:\s*.+$")
    $result.checks.frontmatterDescription = ($skillMd -match "(?m)^description:\s*.+$")
}

$jsonFiles = Get-ChildItem -Path $skillDir -Filter *.json -File -ErrorAction SilentlyContinue | ForEach-Object { $_.Name }
$result.files.jsonFiles = @($jsonFiles)
$result.checks.hasJsonGovernanceFile = ($result.files.jsonFiles.Count -gt 0)

$result.passed = (
    $result.checks.skillPathExists -and
    $result.checks.skillMdExists -and
    $result.checks.frontmatterName -and
    $result.checks.frontmatterDescription
)

if ($AsJson) {
    $result | ConvertTo-Json -Depth 8
    exit 0
}

Write-Host "Skill path: $($result.skillPath)"
Write-Host "SKILL.md exists: $($result.checks.skillMdExists)"
Write-Host "Frontmatter name: $($result.checks.frontmatterName)"
Write-Host "Frontmatter description: $($result.checks.frontmatterDescription)"
Write-Host "JSON governance files: $($result.files.jsonFiles.Count)"
if ($result.files.jsonFiles.Count -gt 0) {
    Write-Host (" - " + ($result.files.jsonFiles -join ", "))
}
Write-Host "PASSED: $($result.passed)"
