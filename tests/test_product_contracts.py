import json
import pathlib
import subprocess
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]


def load_json(path: pathlib.Path):
    return json.loads(path.read_text(encoding="utf-8"))


class TestProductContracts(unittest.TestCase):
    def test_orch_01_agent_registry_and_runtime_alignment(self):
        config = load_json(ROOT / "openclaw.json")
        agents = config["agents"]["list"]
        self.assertGreaterEqual(len(agents), 7)

        for item in agents:
            agent_id = item["id"]
            self.assertTrue((ROOT / f"workspace-{agent_id}").is_dir(), f"missing workspace for {agent_id}")
            self.assertTrue((ROOT / "agents" / agent_id / "agent").is_dir(), f"missing agent dir for {agent_id}")
            self.assertTrue((ROOT / "agents" / agent_id / "sessions").is_dir(), f"missing sessions dir for {agent_id}")

            expected_workspace = f"~/.openclaw/workspace-{agent_id}"
            self.assertEqual(item["workspace"], expected_workspace)
            expected_agent_dir = f"~/.openclaw/agents/{agent_id}/agent"
            self.assertEqual(item["agentDir"], expected_agent_dir)

    def test_orch_02_handoff_chain_contract(self):
        hop1 = load_json(ROOT / "Xuanzhi-Dev" / "generated" / "m6-dry-run" / "chain-001" / "orchestrator-to-architect.json")
        hop2 = load_json(ROOT / "Xuanzhi-Dev" / "generated" / "m6-dry-run" / "chain-001" / "architect-to-claude-code.json")

        self.assertEqual(hop1["requestId"], hop2["requestId"])
        self.assertEqual(hop1["sourceRole"], "orchestrator")
        self.assertEqual(hop1["targetRole"], "architect")
        self.assertEqual(hop2["sourceRole"], "architect")
        self.assertEqual(hop2["targetRole"], "claude-code")
        self.assertTrue(hop1.get("routeReason"))
        self.assertTrue(hop2.get("routeReason"))
        self.assertGreaterEqual(len(hop1.get("acceptanceCriteria", [])), 1)
        self.assertGreaterEqual(len(hop2.get("acceptanceCriteria", [])), 1)

    def test_ops_01_allowlist_allow_case(self):
        script = ROOT / "hooks" / "ops-action-guard" / "validate-allowlist.js"
        result = subprocess.run(
            ["node", str(script), "install_package", "approved-package-list"],
            cwd=ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        payload = json.loads(result.stdout.strip())
        self.assertEqual(payload["decision"], "allow")
        self.assertEqual(payload["ruleId"], "ops-package-install")

    def test_ops_02_allowlist_deny_case(self):
        script = ROOT / "hooks" / "ops-action-guard" / "validate-allowlist.js"
        result = subprocess.run(
            ["node", str(script), "dangerous_action", "workspace-any"],
            cwd=ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertNotEqual(result.returncode, 0)
        payload = json.loads(result.stdout.strip())
        self.assertEqual(payload["decision"], "deny")
        self.assertIsNone(payload["ruleId"])

    def test_ops_03_workspace_integrity_contract(self):
        policy = load_json(ROOT / "hooks" / "workspace-integrity" / "control-policy.json")
        required_files = policy["requiredFiles"]
        required_dirs = policy["requiredDirs"]

        for workspace_name in policy["managedWorkspaces"]:
            workspace = ROOT / workspace_name
            self.assertTrue(workspace.is_dir(), f"missing workspace: {workspace_name}")
            for name in required_files:
                self.assertTrue((workspace / name).is_file(), f"{workspace_name} missing file {name}")
            for name in required_dirs:
                self.assertTrue((workspace / name).is_dir(), f"{workspace_name} missing dir {name}")

    def test_smith_01_skill_bundle_integrity(self):
        skill_root = ROOT / "skills" / "xuanzhi-control"
        required = [
            "SKILL.md",
            "control-model.json",
            "memory-policy.json",
            "routing-policy.json",
            "tool-policy-matrix.json",
            "review.schema.json",
            "workflow-placement.json",
        ]
        for name in required:
            path = skill_root / name
            self.assertTrue(path.exists(), f"missing skill file: {name}")
            if name.endswith(".json"):
                load_json(path)

    def test_smith_02_skill_enabled_and_auto_call_precondition(self):
        config = load_json(ROOT / "openclaw.json")
        entries = config["skills"]["entries"]
        self.assertIn("xuanzhi-control", entries)
        self.assertTrue(entries["xuanzhi-control"]["enabled"])

        hooks = config["hooks"]["internal"]["entries"]
        # 自动调用前置：hook 与 skill 都要可用，系统才能形成自动执行链路。
        self.assertTrue(hooks["ops-action-guard"]["enabled"])
        self.assertTrue(hooks["workspace-integrity"]["enabled"])

    def test_workflow_01_materialize_core_agents_contract(self):
        wf = load_json(ROOT / "Xuanzhi-Dev" / "legacy-root" / "workflows" / "system" / "materialize-core-agents.json")
        self.assertEqual(wf["workflowId"], "materialize-core-agents")
        self.assertEqual(wf["owner"], "ops")
        self.assertIn("steps", wf)
        self.assertGreaterEqual(len(wf["steps"]), 5)

    def test_workflow_02_create_daily_user_contract(self):
        wf = load_json(ROOT / "Xuanzhi-Dev" / "legacy-root" / "workflows" / "users" / "create-daily-user.json")
        self.assertEqual(wf["workflowId"], "create-daily-user")
        self.assertEqual(wf["owner"], "ops")
        step_ids = [s["id"] for s in wf["steps"]]
        self.assertIn("update_bindings", step_ids)
        self.assertIn("submit_for_review", step_ids)

    def test_workflow_03_memory_promote_contract(self):
        wf = load_json(ROOT / "Xuanzhi-Dev" / "legacy-root" / "workflows" / "memory" / "promote.json")
        self.assertEqual(wf["workflowId"], "memory-promote")
        self.assertEqual(wf["owner"], "critic")
        step_ids = [s["id"] for s in wf["steps"]]
        self.assertIn("write_audit_record", step_ids)
        self.assertIn("create_review_record", step_ids)

    def test_state_01_plan_consistency(self):
        release_plan = load_json(ROOT / "Xuanzhi-Dev" / "spec" / "plans" / "release-readiness-master-plan.json")
        short_plan = load_json(ROOT / "Xuanzhi-Dev" / "spec" / "plans" / "active-short-term-plan.json")

        active_milestones = [m for m in release_plan["milestones"] if m["status"] == "active"]
        self.assertEqual(len(active_milestones), 1)
        active = active_milestones[0]
        self.assertEqual(active["id"], "r4")
        self.assertEqual(short_plan["parent_milestone_id"], "r4")
        self.assertEqual(short_plan["status"], "active")

    def test_critic_01_release_gate_blockers_visible(self):
        verdict = (ROOT / "Xuanzhi-Dev" / "spec" / "plans" / "release-verdict.md").read_text(encoding="utf-8")
        self.assertIn("NO-GO", verdict)
        self.assertIn("RG-01", verdict)
        self.assertIn("RG-02", verdict)


if __name__ == "__main__":
    unittest.main(verbosity=2)
