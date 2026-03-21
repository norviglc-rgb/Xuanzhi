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

  const allowlistPresent = fs.existsSync(allowlistPath);
  let allowlistValid = false;
  let ruleCount = 0;
  let validationError: string | null = null;

  if (allowlistPresent) {
    try {
      const raw = fs.readFileSync(allowlistPath, "utf8");
      const parsed = JSON.parse(raw) as { rules?: unknown[] };
      ruleCount = Array.isArray(parsed.rules) ? parsed.rules.length : 0;
      allowlistValid = ruleCount > 0;
      if (!allowlistValid) {
        validationError = "allowlist_rules_empty_or_missing";
      }
    } catch (error) {
      validationError = error instanceof Error ? error.message : "allowlist_parse_error";
    }
  } else {
    validationError = "allowlist_missing";
  }

  const payload = {
    requestId: null,
    source: "gateway",
    target: "hooks/ops-action-guard/allowlist.json",
    action: "gateway_startup_guard_check",
    decision: allowlistPresent && allowlistValid ? "allow" : "deny",
    timestamp: new Date().toISOString(),
    hook: "ops-action-guard",
    allowlistPresent,
    allowlistValid,
    allowlistRuleCount: ruleCount,
    allowlistPath,
    validationError
  };

  fs.appendFileSync(logPath, JSON.stringify(payload) + "\n", "utf8");
}
