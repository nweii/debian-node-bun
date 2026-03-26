FROM debian:12-slim

# Install system utilities
RUN apt-get update -qq && apt-get install -y -qq \
    curl \
    ca-certificates \
    unzip \
    git \
    wget \
    jq \
    openssh-client \
    procps \
    gh \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 from NodeSource (cleaner than Debian's apt package)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Bun to /usr/local so it's available system-wide in PATH
RUN curl -fsSL https://github.com/oven-sh/bun/releases/latest/download/bun-linux-x64-baseline.zip -o /tmp/bun.zip && \
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
