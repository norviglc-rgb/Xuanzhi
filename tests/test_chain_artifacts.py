import json
from pathlib import Path
import unittest

PROJECT_ROOT = Path(__file__).resolve().parents[1]

CHAIN_DIR = PROJECT_ROOT / "Xuanzhi-Dev" / "generated" / "m6-dry-run" / "chain-001"


class ChainArtifactContractTests(unittest.TestCase):
    def setUp(self):
        with (CHAIN_DIR / "orchestrator-to-architect.json").open("r", encoding="utf-8") as fh:
            self.orchestrator = json.load(fh)
        with (CHAIN_DIR / "architect-to-claude-code.json").open("r", encoding="utf-8") as fh:
            self.architect = json.load(fh)
        with (CHAIN_DIR / "replay-input.json").open("r", encoding="utf-8") as fh:
            self.replay_input = json.load(fh)

    def test_both_hop_artifacts_share_required_fields(self):
        required_fields = [
            "requestId",
            "sourceRole",
            "targetRole",
            "taskSummary",
            "acceptanceCriteria",
            "constraints",
            "artifactsIn",
            "artifactsOut",
            "routeReason",
            "riskNotes",
            "timestamp",
        ]
        for artifact in (self.orchestrator, self.architect):
            for field in required_fields:
                self.assertIn(field, artifact, f"{field} missing from {artifact.get('sourceRole')}")

    def test_request_ids_remain_consistent(self):
        request_id = self.orchestrator["requestId"]
        self.assertEqual(request_id, self.architect["requestId"])
        self.assertEqual(request_id, self.replay_input["requestId"])

    def test_replay_input_signals_critical_chain(self):
        expected_fields = ["replayId", "chainId", "requestId", "freshState", "sourceArtifacts"]
        for field in expected_fields:
            self.assertIn(field, self.replay_input)
        self.assertIn(
            "Xuanzhi-Dev/spec/plans/m6-handoff-artifacts-spec.md",
            self.replay_input["sourceArtifacts"],
        )

    def test_artifacts_out_reference_next_hop(self):
        expected_outcomes = {
            "architecture decision note for chain-001",
            "implementation sequencing notes for the next hop",
            "risk and rollback notes for the handoff boundary",
        }
        self.assertTrue(
            set(self.orchestrator["artifactsOut"]) >= expected_outcomes,
            "Orchestrator artifacts out do not describe the architect handoff",
        )
        self.assertIn(
            "Xuanzhi-Dev/generated/m6-dry-run/chain-001/orchestrator-to-architect.json",
            self.architect["artifactsIn"],
        )
        self.assertIn(
            "Xuanzhi-Dev/spec/plans/m6-execution-proof.md",
            self.architect["artifactsOut"],
        )
