# k8s-dev-image

A container image intended to be used as a **devcontainer base** for working with Kubernetes clusters — with a particular focus on [Talos Linux](https://www.talos.dev/) and the CNCF ecosystem (Cilium, ArgoCD, cert-manager, KubeVirt, CloudNativePG).

Built on top of `mcr.microsoft.com/devcontainers/base:ubuntu-24.04`, the image comes preloaded with a curated set of CLIs, k9s plugins, shell completions, and Homebrew so you can spin up a ready-to-work Kubernetes environment inside VS Code (or any devcontainer-compatible tool) without installing anything on your host.

## Image

Published to GitHub Container Registry:

```
ghcr.io/flip-flop-foundry/k8s-dev-image:latest
```

Multi-arch (`linux/amd64`, `linux/arm64`).

## Usage in a devcontainer

```jsonc
{
  "name": "My Kubernetes Project",
  "image": "ghcr.io/flip-flop-foundry/k8s-dev-image:latest",
  "features": {
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {}
  },
  "remoteEnv": {
    "KUBECONFIG": "${containerWorkspaceFolder}/.vscode/current/kubeconfig",
    "TALOSCONFIG": "${containerWorkspaceFolder}/.vscode/current/talosconfig"
  }
}
```

## Included tooling

### Kubernetes & Talos CLIs

| Tool | Purpose |
| --- | --- |
| [`kubectl`](https://kubernetes.io/docs/reference/kubectl/) | Kubernetes CLI |
| [`talosctl`](https://www.talos.dev/latest/reference/cli/) | Talos Linux CLI |
| [`helm`](https://helm.sh/) | Kubernetes package manager |
| [`helm-diff`](https://github.com/databus23/helm-diff) | Helm plugin: preview upgrades as diffs |
| [`k9s`](https://k9scli.io/) | Terminal UI for Kubernetes |
| [`argocd`](https://argo-cd.readthedocs.io/) | ArgoCD CLI |
| [`cilium`](https://cilium.io/) | Cilium CNI CLI |
| [`cmctl`](https://cert-manager.io/docs/reference/cmctl/) | cert-manager CLI |
| [`virtctl`](https://kubevirt.io/) | KubeVirt VM management |
| [`kubectl-cnpg`](https://cloudnative-pg.io/) | CloudNativePG PostgreSQL operator plugin |

### AI / developer tooling

| Tool | Purpose |
| --- | --- |
| [`copilot`](https://github.com/github/copilot-cli) | GitHub Copilot CLI |
| [`claude`](https://claude.com/product/claude-code) | Anthropic Claude Code |

### Base utilities

| Tool | Purpose |
| --- | --- |
| `yq` (mikefarah) | YAML/JSON query & transform |
| `jq` | JSON query & transform |
| `envsubst` | Template variable substitution |
| `git`, `curl`, `rsync`, `unzip`, `gnupg` | Standard build & transfer tools |
| `dnsutils`, `iputils-ping`, `htop` | Diagnostics |
| `python3` + `pip` | Scripting / tool support |
| `docker.io` (CLI) | Docker CLI for docker-outside-of-docker |
| [Homebrew](https://brew.sh/) | Package manager for installing anything else you need |

### k9s plugins

Preinstalled under `~/.config/k9s/plugins/`:

- `argocd`
- `cert-manager`
- `helm-diff`
- `liveMigration`
- `cnpg`
- `kubevirt`

### Shell setup

- Bash & Zsh completions generated for all major CLIs
- Aliases: `k` → `kubectl`, `t` → `talosctl`
- Homebrew and `~/.bun/bin` on `PATH` (visible to the VS Code Server extension host)


### Exposed ports

- `5900/tcp` — VNC (KubeVirt live-migration / VM consoles)

## Versioning

Tool versions are pinned in [`repoBootstrapFiles/versions.env`](./repoBootstrapFiles/versions.env). This file is the single source of truth passed to `install-tools.sh` at image-build time.

Version bumps are automated with [Renovate](https://docs.renovatebot.com/) — see [`.github/renovate.json`](./.github/renovate.json). Renovate opens PRs against `versions.env` whenever new upstream releases are available.

## Build & release

- **CI**: [`.github/workflows/build-and-publish.yml`](./.github/workflows/build-and-publish.yml)
- **Trigger**: manual (`workflow_dispatch`) with an optional version override, or weekly (Sundays at 00:00 UTC)
- **Default version**: bumps the current latest published tag by one minor version
- **Architectures**: `linux/amd64` (on `ubuntu-latest`) and `linux/arm64` (on `ubuntu-24.04-arm`) — built natively, then combined into a single manifest

Local build (with cache):

```bash
docker build -t k8s-dev-image:local .
```

Or use the provided VS Code tasks (`Tasks: Run Task` → `Docker: Build (with cache)` / `Docker: Build (no cache)`).
