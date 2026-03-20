import json
from datetime import datetime, timezone
from pathlib import Path

root = Path("/proof/.openclaw")
uid = "test-user-001"
daily_id = f"daily-{uid}"
ws_id = f"workspace-daily-{uid}"
request_id = "m5-docker-001"
now = datetime.now(timezone.utc).isoformat()

# minimal runtime tree
(root / "workspaces").mkdir(parents=True, exist_ok=True)
(root / "agents").mkdir(parents=True, exist_ok=True)
(root / "state" / "users").mkdir(parents=True, exist_ok=True)
(root / "state" / "audit").mkdir(parents=True, exist_ok=True)

# base config
config_path = root / "openclaw.json"
if not config_path.exists():
    config = {"agents": {"list": []}}
else:
    config = json.loads(config_path.read_text(encoding="utf-8"))

# workspace + profile
workspace = root / "workspaces" / ws_id
workspace.mkdir(parents=True, exist_ok=True)
profile = {
    "userId": uid,
    "dailyAgentId": daily_id,
    "workspaceId": ws_id,
    "status": "pending_review",
    "requestId": request_id,
    "updatedAt": now,
}
(workspace / "profile.json").write_text(
    json.dumps(profile, ensure_ascii=False, indent=2), encoding="utf-8"
)

# agent runtime surface
agent_root = root / "agents" / daily_id
(agent_root / "agent").mkdir(parents=True, exist_ok=True)
(agent_root / "sessions").mkdir(parents=True, exist_ok=True)
(agent_root / "agent" / "models.json").write_text("[]\n", encoding="utf-8")
(agent_root / "sessions" / "sessions.json").write_text(
    '{"version":"v1","sessions":[]}\n', encoding="utf-8"
)

# register agent
agent_list = config.setdefault("agents", {}).setdefault("list", [])
if not any(a.get("id") == daily_id for a in agent_list):
    agent_list.append({"id": daily_id, "workspace": f"~/.openclaw/workspaces/{ws_id}"})
config_path.write_text(json.dumps(config, ensure_ascii=False, indent=2), encoding="utf-8")

# users index
users_path = root / "state" / "users" / "index.json"
if users_path.exists():
    users = json.loads(users_path.read_text(encoding="utf-8"))
else:
    users = {"version": "v1", "users": []}
users["users"] = [u for u in users.get("users", []) if u.get("userId") != uid]
users["users"].append(
    {
        "userId": uid,
        "dailyAgentId": daily_id,
        "workspaceId": ws_id,
        "status": "pending_review",
        "requestId": request_id,
        "updatedAt": now,
    }
)
users_path.write_text(json.dumps(users, ensure_ascii=False, indent=2), encoding="utf-8")

# audit chain
audit_path = root / "state" / "audit" / "user-provision.jsonl"
events = [
    "provision_requested",
    "workspace_materialized",
    "runtime_registered",
    "state_marked_pending_review",
    "review_handoff_created",
]
with audit_path.open("a", encoding="utf-8") as f:
    for event in events:
        rec = {
            "stream": "user-provision",
            "timestamp": now,
            "event": event,
            "userId": uid,
            "dailyAgentId": daily_id,
            "workspaceId": ws_id,
            "requestId": request_id,
            "status": "ok",
        }
        f.write(json.dumps(rec, ensure_ascii=False) + "\n")

print("OK", daily_id, ws_id, request_id)
