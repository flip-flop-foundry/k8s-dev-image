FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04


# Kubevirt VNC
EXPOSE 5900/tcp

# Core packages: envsubst (gettext-base), rsync, jq, curl, git, bash-completion
# Also include docker-cli (docker-outside-of-docker from devcontainer.json)
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        gettext-base \
        rsync \
        jq \
        curl \
        git \
        bash-completion \
        dnsutils \
        iputils-ping \
        htop \
        ca-certificates \
        gnupg \
        unzip \
        python3 \
        python3-pip \
        docker.io \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY repoBootstrapFiles/ /repoBootstrapFiles/


RUN chown -R vscode:vscode /repoBootstrapFiles \
    && chmod +x /repoBootstrapFiles/*.sh

# Configure sudo for vscode user to run without password (required for Homebrew installer in QEMU/ARM64)
RUN echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vscode && chmod 0440 /etc/sudoers.d/vscode

USER vscode

# Install Homebrew as non-root user with sudo (works reliably with QEMU emulation in CI)
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Setup Homebrew in shell
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> /home/vscode/.bashrc \
    && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

# Add Homebrew + Bun global-bin to PATH.
# ~/.bun/bin is where `bun install -g` places binaries (e.g. context-mode). It
# must be on the container's ENV PATH — not just in ~/.zshrc — so the VS Code
# Server extension host (which does NOT source shell rc files) can find them.
ENV PATH="/home/vscode/.bun/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

RUN brew install rtk oven-sh/bun/bun claude-code


# Install context-mode globally via Bun. This makes the `context-mode` binary
# available on PATH for clients that reference it directly (e.g. VS Code Copilot
# via `.vscode/mcp.json`). Claude Code goes through the plugin instead — see below.
# https://github.com/mksglu/context-mode
RUN bun install -g context-mode

# Install context-mode as a Claude Code plugin. Bundles the MCP server, all hooks,
# skills, and slash commands into ~/.claude/plugins/, and adds the marketplace +
# enabled-plugin entries so Claude Code loads it automatically on next launch.
# `--yes` forces non-interactive confirmation (safe during image build).
RUN claude plugin marketplace add mksglu/context-mode \
    && claude plugin install context-mode@context-mode


RUN /repoBootstrapFiles/install-tools.sh /repoBootstrapFiles/versions.env