import json
from pathlib import Path
import unittest

PROJECT_ROOT = Path(__file__).resolve().parents[1]

WORKFLOW_PATH = (
    PROJECT_ROOT
    / "Xuanzhi-Dev"
    / "generated"
    / "workspaces"
    / "workspace-agent-smith"
    / "workflows"
    / "users"
    / "create-daily-user.json"
)


class WorkflowArtifactTests(unittest.TestCase):
    def setUp(self):
        with WORKFLOW_PATH.open("r", encoding="utf-8") as fh:
            self.workflow = json.load(fh)

    def test_required_fields_present(self):
        required_fields = [
            "version",
            "workflowId",
            "owner",
            "templateOwner",
            "trigger",
            "steps",
            "successState",
            "failureState",
        ]
        for field in required_fields:
            self.assertIn(field, self.workflow, f"Workflow missing {field}")

    def test_steps_have_id_and_action(self):
        steps = self.workflow.get("steps", [])
        self.assertIsInstance(steps, list)
        for step in steps:
            self.assertIn("id", step, f"Step missing id: {step}")
            self.assertIn("action", step, f"Step missing action: {step}")

    def test_critic_review_step_declared(self):
        review_steps = [
            step
            for step in self.workflow.get("steps", [])
            if step.get("action") == "create_review_record"
        ]
        self.assertTrue(review_steps, "Expected a create_review_record step")
        self.assertTrue(
            any(step.get("reviewer") == "critic" for step in review_steps),
            "create_review_record step should designate critic reviewer",
        )
