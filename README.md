# debian-node-bun

A minimal Debian 12 base image with Node.js 22+ and Bun pre-installed.

## What's included

- `debian:12-slim` base
- Node.js 22 (via [NodeSource](https://github.com/nodesource/distributions))
- [Bun](https://bun.sh) (latest, installed to `/usr/local/bin`)
- Common utilities: `curl`, `git`, `wget`, `jq`, `unzip`, `openssh-client`, `procps`

## Usage

```dockerfile
FROM ghcr.io/nweii/debian-node-bun:latest

# Add your user, set working directory, etc.
RUN echo "myuser:x:1000:1000::/workspace:/bin/bash" >> /etc/passwd
USER 1000:1000
```

Or in a compose file:

```yaml
services:
  my-service:
    image: ghcr.io/nweii/debian-node-bun:latest
    user: "1000:1000"
```

You can use that published image as above, or fork this repo and enable GitHub Actions to build and push to your own namespace (`ghcr.io/<your-github-user-or-org>/debian-node-bun:latest`).

## Building locally

```bash
docker build -t debian-node-bun:latest .
```

## My use case

I run a Synology NAS as a home server and use this as the base image for containerized personal automation (a persistent Claude Code session with vault access, an Obsidian Sync daemon, and similar lightweight background processes). I needed a clean Debian base with Node and Bun available system-wide, plus common dev utilities, without the overhead of the full `node:bookworm` image.

## Why not `imbios/bun-node`?

`imbios/bun-node` is based on `node:22-bookworm` (the full Node image) and doesn't include git or other common utilities. This image starts from `debian:12-slim` and adds only what's needed, keeping the image smaller and more explicit.
