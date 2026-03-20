#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");

function usage() {
  const message = 'usage: node validate-allowlist.js <action> <scope>';
  return message;
}

function globToRegExp(pattern) {
  const escaped = pattern.replace(/[.+^${}()|[\]\\]/g, "\\$&");
  const regex = "^" + escaped.replace(/\*/g, ".*").replace(/\?/g, ".") + "$";
  return new RegExp(regex);
}

function matchesScope(ruleScopes, inputScope) {
  return ruleScopes.some((scopePattern) => globToRegExp(scopePattern).test(inputScope));
}

function validate(action, scope) {
  const allowlistPath = path.join(__dirname, "allowlist.json");
  const allowlist = JSON.parse(fs.readFileSync(allowlistPath, "utf8"));
  const rules = Array.isArray(allowlist.rules) ? allowlist.rules : [];

  for (const rule of rules) {
    if (rule.action !== action) continue;
    if (!Array.isArray(rule.scope)) continue;
    if (!matchesScope(rule.scope, scope)) continue;

    return {
      decision: "allow",
      ruleId: rule.id,
      action,
      scope
    };
  }

  return {
    decision: "deny",
    ruleId: null,
    action,
    scope
  };
}

const [action, scope] = process.argv.slice(2);

if (!action || !scope) {
  console.log(JSON.stringify({ decision: "deny", ruleId: null, error: usage() }));
  process.exit(2);
}

const result = validate(action, scope);
console.log(JSON.stringify(result));
process.exit(result.decision === "allow" ? 0 : 1);
