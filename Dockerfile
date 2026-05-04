FROM debian:12-slim

ARG NODE_VERSION=unknown
ARG NODE_PACKAGE_VERSION
ARG BUN_VERSION=unknown

LABEL io.github.nweii.node.version="${NODE_VERSION}" \
      io.github.nweii.bun.version="${BUN_VERSION}" \
      org.opencontainers.image.version="node${NODE_VERSION}-bun${BUN_VERSION}"

# Install system utilities
RUN apt-get update -qq && apt-get install -y -qq \
    curl \
    ca-certificates \
    unzip \
    git \
    wget \
    jq \
    openssh-client \
    openssh-server \
    procps \
    gh \
    && rm -rf /var/lib/apt/lists/*

# sshd runtime layout. The server is installed but no service is started by
# this image — downstream consumers opt in by running /usr/sbin/sshd from
# their own entrypoint. /run/sshd is required by sshd; /var/empty is its
# default privsep chroot. Both must exist before sshd is invoked.
RUN mkdir -p /run/sshd /var/empty && \
    chmod 0755 /run/sshd /var/empty

# Install Node.js 22 from NodeSource (cleaner than Debian's apt package)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    if [ -n "${NODE_PACKAGE_VERSION}" ]; then \
        apt-get install -y "nodejs=${NODE_PACKAGE_VERSION}"; \
    else \
        apt-get install -y nodejs; \
    fi && \
    rm -rf /var/lib/apt/lists/*

# Install Bun to /usr/local so it's available system-wide in PATH
RUN if [ "${BUN_VERSION}" = "unknown" ]; then \
        bun_url="https://github.com/oven-sh/bun/releases/latest/download/bun-linux-x64-baseline.zip"; \
    else \
        bun_url="https://github.com/oven-sh/bun/releases/download/bun-v${BUN_VERSION}/bun-linux-x64-baseline.zip"; \
    fi && \
curl -fsSL "${bun_url}" -o /tmp/bun.zip && \
unzip /tmp/bun.zip -d /tmp && \
mv /tmp/bun-linux-x64-baseline/bun /usr/local/bin/bun && \
chmod +x /usr/local/bin/bun && \
ln -sf /usr/local/bin/bun /usr/local/bin/bunx && \
rm -rf /tmp/bun.zip /tmp/bun-linux-x64-baseline

# Install GitHub CLI (requires its own apt repo)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \ 
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \ 
apt-get update -qq && apt-get install -y -qq gh && \ 
rm -rf /var/lib/apt/lists/*

# Set a default prompt that shows UID instead of 'I have no name!' when
# running as an unlisted user. Override PS1 in your own .bashrc as needed.
ENV PS1='\u@\h:\w\$ '
