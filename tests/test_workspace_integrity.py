import json
from pathlib import Path
import unittest

PROJECT_ROOT = Path(__file__).resolve().parents[1]


class WorkspaceIntegrityPolicyTests(unittest.TestCase):
    def setUp(self):
        policy_path = PROJECT_ROOT / "hooks" / "workspace-integrity" / "control-policy.json"
        with policy_path.open("r", encoding="utf-8") as fh:
            self.policy = json.load(fh)

    def test_managed_workspaces_exist(self):
        for workspace in self.policy.get("managedWorkspaces", []):
            workspace_dir = PROJECT_ROOT / workspace
            self.assertTrue(
                workspace_dir.is_dir(),
                f"Managed workspace missing: {workspace_dir}",
            )

    def test_required_files_and_dirs_present(self):
        required_files = self.policy.get("requiredFiles", [])
        required_dirs = self.policy.get("requiredDirs", [])
        for workspace in self.policy.get("managedWorkspaces", []):
            workspace_dir = PROJECT_ROOT / workspace
            for filename in required_files:
                self.assertTrue(
                    (workspace_dir / filename).is_file(),
                    f"Missing {filename} in {workspace}",
                )
            for dirname in required_dirs:
                self.assertTrue(
                    (workspace_dir / dirname).is_dir(),
                    f"Missing directory {dirname} in {workspace}",
                )
