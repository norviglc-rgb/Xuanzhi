import os
import json
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
    @staticmethod
    def _is_external_openrouter_failure(text: str) -> bool:
        patterns = (
            "api rate limit reached",
            "too many requests",
            "no endpoints available matching your guardrail restrictions",
            "data policy",
            "spend limit",
        )
        lowered = text.lower()
        return any(p in lowered for p in patterns)

    @staticmethod
    def _has_hard_auth_failure(text: str) -> bool:
        lowered = text.lower()
        return "no api key found for provider \"openrouter\"" in lowered

    @staticmethod
    def _has_recent_docker_audit_event(audit_path: Path) -> bool:
        if not audit_path.exists():
            return False
        try:
            lines = audit_path.read_text(encoding="utf-8", errors="replace").splitlines()
        except OSError:
            return False
        for raw in reversed(lines[-120:]):
            raw = raw.strip()
            if not raw:
                continue
            try:
                payload = json.loads(raw)
            except json.JSONDecodeError:
                continue
            if payload.get("source") == "docker-openrouter-e2e":
                return True
        return False

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

        combined = f"{proc.stdout}\n{proc.stderr}"
        if self._has_hard_auth_failure(combined):
            self.fail(
                "Docker OpenRouter e2e hard-failed due to missing OpenRouter auth.\n"
                f"stdout:\n{proc.stdout}\n"
                f"stderr:\n{proc.stderr}"
            )

        audit_path = Path(__file__).resolve().parents[1] / "logs" / "audit" / "model-failover.jsonl"
        has_audit = self._has_recent_docker_audit_event(audit_path)
        has_switch_signal = "[model-fallback/decision]" in proc.stdout

        if proc.returncode == 0:
            self.assertTrue(has_audit, "Expected docker-openrouter-e2e audit events in model-failover.jsonl.")
            return

        if self._is_external_openrouter_failure(combined) and has_audit and has_switch_signal:
            # External quota/privacy/guardrail constraints are acceptable for this live E2E,
            # as long as model switch events and unified audit logging are both observed.
            return

        self.fail(
            "Docker OpenRouter e2e script failed unexpectedly.\n"
            f"stdout:\n{proc.stdout}\n"
            f"stderr:\n{proc.stderr}"
        )
