import json
import subprocess
from pathlib import Path
import unittest

PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPT_PATH = PROJECT_ROOT / "hooks" / "ops-action-guard" / "validate-allowlist.js"


def run_allowlist(action, scope):
    result = subprocess.run(
        ["node", str(SCRIPT_PATH), action, scope],
        capture_output=True,
        text=True,
        check=False,
    )
    payload = json.loads(result.stdout.strip())
    return result.returncode, payload


class HooksAllowlistTests(unittest.TestCase):
    def test_allow_known_action(self):
        code, payload = run_allowlist("read_logs", "~/.openclaw/logs")
        self.assertEqual(code, 0)
        self.assertEqual(payload["decision"], "allow")
        self.assertEqual(payload["ruleId"], "ops-read-logs")

    def test_wildcard_scope_matches(self):
        code, payload = run_allowlist("manage_generic_agent_instance", "workspace-orchestrator")
        self.assertEqual(code, 0)
        self.assertEqual(payload["decision"], "allow")
        self.assertEqual(payload["ruleId"], "ops-generic-agent-provisioning")

    def test_unknown_action_is_denied(self):
        code, payload = run_allowlist("unknown_action", "workspace-orchestrator")
        self.assertNotEqual(code, 0)
        self.assertEqual(payload["decision"], "deny")
        self.assertIsNone(payload["ruleId"])
