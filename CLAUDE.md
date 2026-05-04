# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A minimal Docker base image built on `debian:12-slim` with Node.js 22 (via NodeSource) and Bun installed system-wide. The entire project is essentially one `Dockerfile` and a GitHub Actions workflow.

## Building locally

```bash
docker build -t debian-node-bun:latest .
```

## CI/CD

The GitHub Actions workflow (`.github/workflows/build.yml`) builds and pushes to `ghcr.io/<repository_owner>/debian-node-bun:latest` on:
- Push to `main`
- Weekly schedule (Mondays at 06:00 UTC) to pick up new Node/Bun releases
- Manual `workflow_dispatch`

## Key design decisions

- Based on `debian:12-slim` rather than `node:bookworm` to keep the image smaller and more explicit about what's included.
- Node.js installed via NodeSource (not Debian's apt package) for a more current release.
- Bun installed to `/usr/local` so it's on PATH for all users, including unlisted UIDs. Uses `--baseline` flag to force the AVX2-free build for more flexibility.
- GitHub CLI (`gh`) installed from the official GitHub apt repo, since it's not in Debian's default repositories.
- `PS1` env var set to show UID instead of `I have no name!` when running as an unlisted user — downstream users can override in their own `.bashrc`.
- `openssh-server` is installed but no service is started; `/run/sshd` and `/var/empty` are pre-created so a downstream entrypoint can launch `sshd -D` rootlessly. The image deliberately does not add a non-root user to `/etc/passwd` — keeping that downstream-defined preserves support for arbitrary uids. SSH logins do require a passwd entry for the target uid, so downstream images need to add one (typically by appending to `/etc/passwd` at build time or bind-mounting a replacement at runtime).
