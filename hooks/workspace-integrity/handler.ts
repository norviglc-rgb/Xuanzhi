import fs from "node:fs";
import path from "node:path";
import os from "node:os";

type HookEvent = {
  type: string;
  action: string;
};

function expandHome(input: string) {
  return input.startsWith("~") ? path.join(os.homedir(), input.slice(1)) : input;
}

export default async function workspaceIntegrity(event: HookEvent) {
  if (!(event.type === "gateway" && event.action === "startup")) return;

  const root = path.join(os.homedir(), ".openclaw");
  const policyPath = path.join(root, "hooks", "workspace-integrity", "control-policy.json");
  if (!fs.existsSync(policyPath)) return;

  const policy = JSON.parse(fs.readFileSync(policyPath, "utf8")) as {
    managedWorkspaces: string[];
    requiredFiles: string[];
    requiredDirs: string[];
    logFile: string;
  };

  const results = policy.managedWorkspaces.map((workspaceName) => {
    const workspaceDir = path.join(root, workspaceName);
    const missingFiles = policy.requiredFiles.filter((name) => !fs.existsSync(path.join(workspaceDir, name)));
    const missingDirs = policy.requiredDirs.filter((name) => !fs.existsSync(path.join(workspaceDir, name)));
    return {
      timestamp: new Date().toISOString(),
      workspace: workspaceName,
      ok: missingFiles.length === 0 && missingDirs.length === 0,
      missingFiles,
      missingDirs
    };
  });

  const logPath = expandHome(policy.logFile);
  fs.mkdirSync(path.dirname(logPath), { recursive: true });
  fs.appendFileSync(logPath, results.map((item) => JSON.stringify(item)).join("\n") + "\n", "utf8");
}
