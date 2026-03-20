import json
from pathlib import Path
import unittest

PROJECT_ROOT = Path(__file__).resolve().parents[1]
SKILL_PATH = PROJECT_ROOT / "skills" / "xuanzhi-control"


class SkillsGovernanceIntegrityTests(unittest.TestCase):
    def _load(self, filename):
        with (SKILL_PATH / filename).open("r", encoding="utf-8") as fh:
            return json.load(fh)

    def test_control_model_has_expected_sections(self):
        control = self._load("control-model.json")
        for key in ("version", "hardControls", "softControls", "warnings"):
            self.assertIn(key, control)
        self.assertGreater(len(control["hardControls"]), 0)

    def test_memory_policy_defines_review(self):
        memory = self._load("memory-policy.json")
        self.assertIn("review", memory)
        review = memory["review"]
        self.assertEqual(review.get("reviewer"), "critic")
        self.assertTrue(review.get("allow_workflow_promotion"))

    def test_routing_policy_routes_to_critic(self):
        routing = self._load("routing-policy.json")
        task_routes = routing.get("task_routes", [])
        self.assertTrue(
            any(route.get("target") == "critic" for route in task_routes),
            "No critic route found in binding policy",
        )
        handoff = routing.get("complexity_upgrade", {})
        self.assertTrue(
            isinstance(handoff.get("handoff_required"), list)
            and "PLAN.md" in handoff.get("handoff_required", []),
            "complexity upgrade should require PLAN.md",
        )

    def test_tool_policy_matrix_defines_restrictions(self):
        matrix = self._load("tool-policy-matrix.json")
        agents = matrix.get("agents", {})
        critic = agents.get("critic", {})
        self.assertIn("deny", critic)
        self.assertIn("exec", critic["deny"])
        self.assertIn("read", critic.get("allow", []))

    def test_workflow_placement_notes_use_and_avoid(self):
        placement = self._load("workflow-placement.json")
        internal = placement.get("openclawInternal", {})
        self.assertTrue(
            "startup integrity checks and local audit logs" in internal.get("useFor", []),
            "OpenClaw internal placement missing integrity log note",
        )
        fastgpt = placement.get("fastgpt", {})
        self.assertTrue(
            "host command execution" in fastgpt.get("avoidFor", []),
            "FastGPT placement should avoid host command execution",
        )
