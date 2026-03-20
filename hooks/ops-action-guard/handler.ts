import fs from "node:fs";
import path from "node:path";
import os from "node:os";

type HookEvent = {
  type: string;
  action: string;
};

export default async function opsActionGuard(event: HookEvent) {
  if (!(event.type === "gateway" && event.action === "startup")) return;

  const root = path.join(os.homedir(), ".openclaw");
  const allowlistPath = path.join(root, "hooks", "ops-action-guard", "allowlist.json");
  const logPath = path.join(root, "logs", "ops-guard.jsonl");
  fs.mkdirSync(path.dirname(logPath), { recursive: true });

  const payload = {
    timestamp: new Date().toISOString(),
    hook: "ops-action-guard",
    allowlistPresent: fs.existsSync(allowlistPath),
    allowlistPath
  };

  fs.appendFileSync(logPath, JSON.stringify(payload) + "\n", "utf8");
}
