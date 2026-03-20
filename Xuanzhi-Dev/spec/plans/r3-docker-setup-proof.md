# R3 Docker Setup Proof

Date: 2026-03-20
Milestone: `r3`

## Doc Basis

- Follow local OpenClaw Docker references:
  - `Xuanzhi-Dev/reference/openclaw/install/docker.md`
  - `Xuanzhi-Dev/reference/openclaw/install/docker-vm-runtime.md`
- Verification target: install/run OpenClaw in container, copy runtime directly into `~/.openclaw`, then validate core runtime artifacts.

## Executed Commands

```bash
docker pull ghcr.io/openclaw/openclaw:latest
docker run -d --name xuanzhi-r3-test --entrypoint sh ghcr.io/openclaw/openclaw:latest -c "tail -f /dev/null"
docker image inspect ghcr.io/openclaw/openclaw:latest --format "{{.RepoDigests}}|{{.Os}}/{{.Architecture}}"
docker inspect xuanzhi-r3-test --format "{{.Id}}|{{.Config.Image}}|{{.Config.User}}|{{.State.Status}}"
docker exec xuanzhi-r3-test openclaw --version
docker exec xuanzhi-r3-test sh -lc "rm -rf /home/node/.openclaw && mkdir -p /home/node/.openclaw"
docker cp openclaw.json xuanzhi-r3-test:/home/node/.openclaw/
docker cp agents hooks skills logs credentials cron xuanzhi-r3-test:/home/node/.openclaw/
# plus docker cp for all workspace-* directories
docker exec -u 0 xuanzhi-r3-test sh -lc "chown -R node:node /home/node/.openclaw"
```

## Setup Results

- Image digest verified:
  - `ghcr.io/openclaw/openclaw@sha256:a5a4c83b773aca85a8ba99cf155f09afa33946c0aa5cc6a9ccb6162738b5da02`
- Container created and running:
  - `xuanzhi-r3-test` on `ghcr.io/openclaw/openclaw:latest`
  - default image user: `node`
- Runtime copy under `/home/node/.openclaw` completed for:
  - `openclaw.json`
  - `agents/`, `hooks/`, `skills/`, `logs/`, `credentials/`, `cron/`
  - all `workspace-*`
- OpenClaw CLI verification:
  - `OpenClaw 2026.3.13`

## Facts Observed During Copy

- Running `chown -R node:node /home/node/.openclaw` as default container user failed with many `Operation not permitted`.
- Running the same command as root (`docker exec -u 0 ...`) succeeded and normalized ownership.
- Conclusion:
  - direct host copy is feasible and matches user要求；
  - but reproducible automation should include an explicit ownership-fix step.

## Conclusion

`r3/s2` passed.
Docker setup, OpenClaw availability, and direct runtime copy to `~/.openclaw` are all verified with executable evidence.
