# M4 Docker OpenClaw Proof

Date: 2026-03-20
Milestone: `m4`
Step: `s3` (`完成 Docker 内 OpenClaw 最小验证`)

## Doc Basis

Installed and validated using local OpenClaw docs under:

- `Xuanzhi-Dev/reference/openclaw/install/docker.md`
- `Xuanzhi-Dev/reference/openclaw/install/docker-vm-runtime.md`

The chosen path follows the documented remote image flow (`ghcr.io/openclaw/openclaw`), using an isolated throwaway container run.

## Commands

```bash
docker run --rm ghcr.io/openclaw/openclaw:latest openclaw --version
docker image inspect ghcr.io/openclaw/openclaw:latest --format "{{.RepoDigests}}|{{.Os}}/{{.Architecture}}"
```

## Results

- OpenClaw version output: `OpenClaw 2026.3.13`
- Pulled image digest:
  - `ghcr.io/openclaw/openclaw@sha256:a5a4c83b773aca85a8ba99cf155f09afa33946c0aa5cc6a9ccb6162738b5da02`
- Image platform:
  - `linux/amd64`

## Conclusion

`m4/s3` is passed.
Docker-based OpenClaw minimum verification is complete with reproducible image evidence.

## Next

Proceed to `m4/s4`: clean and use real equivalent environment `lc@10.0.1.70` for verification.
