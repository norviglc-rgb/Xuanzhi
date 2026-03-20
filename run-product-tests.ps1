Set-StrictMode -Version Latest
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$enableDockerE2E = $false
if ($env:RUN_PRODUCT_TESTS_DOCKER_OPENROUTER_E2E) {
    if ($env:RUN_PRODUCT_TESTS_DOCKER_OPENROUTER_E2E -match "^(1|true|yes|on)$") {
        $enableDockerE2E = $true
    }
}
if ($enableDockerE2E) {
    Write-Host "Enabling Docker OpenRouter E2E tests."
    $env:RUN_OPENROUTER_DOCKER_E2E = "1"
}
Push-Location $root
try {
    python -m unittest discover -s tests -p "*.py"
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
finally {
    Pop-Location
}
