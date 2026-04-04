# debian-node-bun

A minimal Debian 12 base image with Node.js 22+ and Bun pre-installed.

## What's included

- `debian:12-slim` base
- Node.js 22 (via [NodeSource](https://github.com/nodesource/distributions))
- [Bun](https://bun.sh) (latest, installed to `/usr/local/bin`)
- Common utilities: `curl`, `git`, `wget`, `jq`, `unzip`, `openssh-client`, `procps`

## Tag behavior

The published image includes a moving `latest` tag, a moving `node22` tag, and versioned tags like `node22.19.0-bun1.2.8`.

The GitHub Actions workflow checks weekly for the latest Node 22 package from NodeSource and the latest Bun release, but it only publishes a fresh image when one of those versions changes. That keeps `latest` current without creating a new image digest every week when nothing upstream has moved. Pushes to `main` or `master` and manual runs still publish normally.

## Use as a base image

Build your own container on top of this when you want a Debian-based environment with Node, Bun, and common CLI tools already available.

```dockerfile
FROM ghcr.io/nweii/debian-node-bun:latest

# Add your user and working directory, then install or run your own tools.
RUN echo "appuser:x:1000:1000::/workspace:/bin/bash" >> /etc/passwd
USER 1000:1000
WORKDIR /workspace

CMD ["bash"]
```

Or in a [Compose file](https://docs.docker.com/compose/):

```yaml
services:
  my-service:
    image: ghcr.io/nweii/debian-node-bun:latest
    user: "1000:1000"
```

If you want a predictable base, pin a versioned tag instead of `latest`.

You can use that published image as above, or fork this repo and enable GitHub Actions to build and push to your own namespace (`ghcr.io/<your-github-user-or-org>/debian-node-bun:latest`).

## Building locally

```bash
docker build -t debian-node-bun:latest .
```

## Purpose and when to use this image

This image is good for **homelab and self-hosted** setups where you want **Node.js and Bun** on a **normal Debian 12 userspace** without the full `node:*` image stack. It is meant for the kind of Docker workloads where you want command-line tooling available inside the container, such as **[Claude Code](https://docs.claude.com/en/docs/claude-code/overview)**, Codex CLI, vault sync tooling, and similar agent or automation processes.

**Synology NAS:** DSM is not where you typically install current Node or Bun directly. Running this image in Docker (Container Manager or Portainer) gives you a predictable Debian 12 environment with both runtimes ready to use. Other NAS platforms that lean on containers work the same way.

Before you run **coding agents** on top of this image, **confirm the server has enough RAM** for those workloads plus the OS and your other services.

**Good fits**

- **Agents and CLI automation** — persistent containers (including on a NAS) for tools like Claude Code, Codex CLI, or Obsidian vault sync workflows that need Node, Bun, git, and a shell together.
- **A reusable `FROM`** — homelab, VPS, or CI images where you would otherwise copy the same NodeSource + Bun + utility setup into every Dockerfile.
- **Node and Bun in one place** — monorepos or tooling split across both runtimes.

**Compared to**

- **[`imbios/bun-node`](https://hub.docker.com/r/imbios/bun-node)** — Node + Bun on top of `node:*-bookworm` (larger stack). Here you start from `debian:12-slim` and add only what is listed above.
- **`node:bookworm`** — Node only; Bun is an extra install this Dockerfile already covers.

If you **do not need Bun**, other bases (for example the official Node images) may be a simpler fit—compare options for your own stack. This image is for when you want **Debian + Node + Bun + light tooling** in one place.
