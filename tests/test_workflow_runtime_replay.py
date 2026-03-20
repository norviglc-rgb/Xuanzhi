import json
import pathlib
import subprocess
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPTS = [
    ("workflow-materialize-core-agents.ps1", "materialize-core-agents"),
    ("workflow-create-daily-user.ps1", "create-daily-user"),
    ("workflow-memory-promote.ps1", "memory-promote"),
]


class WorkflowRuntimeReplayTests(unittest.TestCase):
    def run_script(self, script_name: str) -> dict:
        script_path = ROOT / "scripts" / script_name
        result = subprocess.run(
            ["powershell", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", str(script_path)],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )
        self.assertEqual(result.returncode, 0, f"{script_name} failed:\n{result.stderr}")
        output = result.stdout.strip()
        self.assertTrue(output, f"{script_name} did not emit a JSON summary")
        try:
            return json.loads(output)
        except json.JSONDecodeError as exc:
            self.fail(f"Failed to parse JSON from {script_name}: {exc}\nOutput:\n{output}")

    def assert_audit_entry(self, workflow_id: str, request_id: str):
        audit_path = ROOT / "logs" / "audit" / f"{workflow_id}.jsonl"
        self.assertTrue(audit_path.exists(), f"audit log missing for {workflow_id}")
        lines = []
        for raw_line in audit_path.read_text(encoding="utf-8-sig").splitlines():
            trimmed = raw_line.strip()
            if trimmed:
                lines.append(trimmed.lstrip("\ufeff"))
        entries = [json.loads(line) for line in lines]
        matched = [entry for entry in entries if entry.get("requestId") == request_id]
        self.assertTrue(matched, f"No audit entry found for request {request_id}")
        audit_entry = matched[0]
        for key in ("requestId", "source", "target", "action", "decision", "timestamp"):
            self.assertIn(key, audit_entry, f"{workflow_id} audit entry missing {key}")

    def test_workflows_emit_state_and_audit(self):
        for script_name, workflow_id in SCRIPTS:
            summary = self.run_script(script_name)
            self.assertEqual(summary["workflowId"], workflow_id)
            state_path = ROOT / "state" / "workflows" / f"{workflow_id}.json"
            self.assertTrue(state_path.exists(), f"state file missing for {workflow_id}")
            state = json.loads(state_path.read_text(encoding="utf-8-sig"))
            self.assertEqual(state["workflowId"], workflow_id)
            self.assertEqual(state["requestId"], summary["requestId"])
            for field in ("lastAction", "lastDecision", "lastSource", "lastTarget", "lastTimestamp"):
                self.assertIn(field, state)
            self.assertEqual(state["stepCount"], summary["stepCount"])
            self.assertEqual(pathlib.Path(state["auditLog"]).name, f"{workflow_id}.jsonl")
            self.assert_audit_entry(workflow_id, summary["requestId"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
