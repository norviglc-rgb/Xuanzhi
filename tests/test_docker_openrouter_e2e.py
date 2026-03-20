import os
import shutil
import subprocess
import unittest
from pathlib import Path
from typing import Optional


def _env_truthy(value: Optional[str]) -> bool:
    if not value:
        return False
    return value.lower() in {"1", "true", "yes", "on"}


class DockerOpenRouterE2ETest(unittest.TestCase):
    def test_docker_openrouter_e2e(self):
        if not _env_truthy(os.environ.get("RUN_OPENROUTER_DOCKER_E2E")):
            self.skipTest("Docker OpenRouter E2E disabled (set RUN_OPENROUTER_DOCKER_E2E=1 to enable).")

        if _env_truthy(os.environ.get("SKIP_DOCKER_OPENROUTER_E2E")):
            self.skipTest("Docker OpenRouter E2E explicitly skipped via SKIP_DOCKER_OPENROUTER_E2E.")

        if shutil.which("docker") is None:
            self.skipTest("Docker CLI is not installed.")

        if shutil.which("pwsh") is None and shutil.which("powershell") is None:
            self.skipTest("PowerShell is required to run the PS script.")

        if not os.environ.get("OPENROUTER_API_KEY"):
            self.skipTest("OPENROUTER_API_KEY is not set.")

        script = Path(__file__).resolve().parents[1] / "scripts" / "docker-openrouter-e2e.ps1"
        if not script.exists():
            self.skipTest(f"Missing script: {script}")

        pwsh = shutil.which("pwsh") or shutil.which("powershell")
        if not pwsh:
            self.skipTest("Cannot find PowerShell executable.")

        cmd = [pwsh, "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", str(script)]
        try:
            proc = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
                timeout=600,
            )
        except subprocess.TimeoutExpired as exc:
            self.fail(f"Docker OpenRouter e2e script timed out after {exc.timeout} seconds.")

        if proc.returncode != 0:
            self.fail(
                "Docker OpenRouter e2e script failed.\n"
                f"stdout:\n{proc.stdout}\n"
                f"stderr:\n{proc.stderr}"
            )
