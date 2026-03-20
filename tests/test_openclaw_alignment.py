import json
from pathlib import Path
import unittest

PROJECT_ROOT = Path(__file__).resolve().parents[1]


class OpenClawAgentAlignmentTests(unittest.TestCase):
    def setUp(self):
        self.config_path = PROJECT_ROOT / "openclaw.json"
        with self.config_path.open("r", encoding="utf-8") as fh:
            self.config = json.load(fh)

    def _resolve_config_path(self, raw_value):
        prefix = "~/.openclaw/"
        if raw_value.startswith(prefix):
            rel = raw_value[len(prefix) :]
        elif raw_value.startswith("~/"):
            rel = raw_value[2:]
        else:
            rel = raw_value
        rel = rel.lstrip("\\/")
        return PROJECT_ROOT / rel

    def test_each_agent_has_workspace_dir(self):
        for agent in self.config.get("agents", {}).get("list", []):
            workspace_path = self._resolve_config_path(agent.get("workspace", ""))
            self.assertTrue(
                workspace_path.is_dir(),
                f"Expected workspace directory for {agent.get('id')} at {workspace_path}",
            )

    def test_each_agent_dir_exists(self):
        for agent in self.config.get("agents", {}).get("list", []):
            agent_dir = self._resolve_config_path(agent.get("agentDir", ""))
            self.assertTrue(
                agent_dir.is_dir(),
                f"Agent directory missing for {agent.get('id')} at {agent_dir}",
            )
