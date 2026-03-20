import json
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
HELPER_SCRIPT = PROJECT_ROOT / "scripts" / "model-failover-audit.ps1"


def _escape_value(value: str) -> str:
    return value.replace("'", "''")


class ModelFailoverAuditTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = Path(tempfile.mkdtemp(prefix="audit-test-"))
        self.log_path = self.temp_dir / "model-failover.jsonl"

    def tearDown(self):
        if self.temp_dir.exists():
            shutil.rmtree(self.temp_dir)

    def _write_entry(self, **kwargs):
        args = []
        for name, value in kwargs.items():
            args.append(f"-{name} '{_escape_value(str(value))}'")
        command = f". '{HELPER_SCRIPT}' ; Write-ModelFailoverAuditEvent {' '.join(args)}"
        subprocess.run(
            ["pwsh", "-NoProfile", "-NonInteractive", "-Command", command],
            capture_output=True,
            text=True,
            check=True,
        )

    def test_audit_entries_include_required_fields(self):
        self._write_entry(
            Source="unit-test",
            Target="openrouter/test-model:free",
            Action="probe",
            Decision="success",
            Model="openrouter/test-model",
            Reason="probe-ok",
            LogPath=str(self.log_path),
        )
        self._write_entry(
            Source="unit-test",
            Target="openrouter/test-model:free",
            Action="probe",
            Decision="failure",
            Model="openrouter/test-model",
            Reason="rate-limited",
            ErrorCode="RATE_LIMITED",
            LogPath=str(self.log_path),
        )

        entries = []
        with self.log_path.open("r", encoding="utf-8") as fh:
            for line in fh:
                stripped = line.strip()
                if not stripped:
                    continue
                entries.append(json.loads(stripped))

        self.assertEqual(len(entries), 2)
        success, failure = entries
        for entry in entries:
            self.assertIn("requestId", entry)
            self.assertIn("source", entry)
            self.assertIn("target", entry)
            self.assertIn("action", entry)
            self.assertIn("decision", entry)
            self.assertIn("timestamp", entry)
            self.assertIn("model", entry)
        self.assertEqual(success["decision"], "success")
        self.assertEqual(success["reason"], "probe-ok")
        self.assertEqual(failure["decision"], "failure")
        self.assertEqual(failure["reason"], "rate-limited")
        self.assertEqual(failure["errorCode"], "RATE_LIMITED")
