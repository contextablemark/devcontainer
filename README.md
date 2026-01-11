# Universal Dev Container

A self-contained VS Code Dev Container for OSS development. Everything lives inside the container—workspaces, Claude Code context, git config, gh auth—so you can pick up where you left off or move the container to another machine.

## What's Included

- **Python 3.12** with pip
- **Node.js 20.x LTS** with npm
- **pnpm** - Fast Node package manager
- **uv** - Fast Python package manager
- **Claude Code CLI** - Anthropic's AI coding assistant
- **GitHub CLI (gh)** - GitHub from the command line
- **Zsh + Oh My Zsh** - Better shell experience
- **Common build tools** - build-essential, libssl-dev, etc.

## What's Bind-Mounted from Host

- `~/.ssh` (readonly) - Your SSH keys
- `~/.vscode-server` - VS Code extensions (shared across containers)

## Setup

1. Ensure you have the directories on your host:
   ```bash
   mkdir -p ~/.vscode-server
   ```

2. Open this folder in VS Code

3. When prompted, click "Reopen in Container" (or use Command Palette: `Dev Containers: Reopen in Container`)

4. First-time authentication inside the container:
   ```bash
   gh auth login
   claude
   ```

5. Clone repos and start working:
   ```bash
   cd ~/workspaces
   git clone git@github.com:your-org/your-repo.git
   ```

## Key Behaviors

- **Container persists**: `shutdownAction: none` keeps it running when you close VS Code
- **Named container**: Uses `--name dev-environment` so you always reconnect to the same one
- **Everything inside**: Workspaces, Claude context, git config all live in the container

## Reconnecting

Just open VS Code and use:
- `Dev Containers: Attach to Running Container...` → select `dev-environment`

Or reopen this folder—it will reuse the existing container.

## Moving to Another Machine

Export the container with all its state:
```bash
docker commit dev-environment my-dev-env:latest
docker save my-dev-env:latest | gzip > my-dev-env.tar.gz
```

On the target machine:
```bash
gunzip -c my-dev-env.tar.gz | docker load
docker run -d --name dev-environment my-dev-env:latest sleep infinity
```

Then attach VS Code to it.

## Customization

- Add tools: Edit `Dockerfile`
- Add VS Code extensions: Edit `devcontainer.json` → `customizations.vscode.extensions`
- Change ports: Edit `devcontainer.json` → `forwardPorts`
