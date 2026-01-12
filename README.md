# Universal Dev Container

A self-contained development environment for OSS development. Everything lives inside the container—workspaces, Claude Code context, git config, gh auth—so you can pick up where you left off or move the container to another machine.

## What's Included

- **Python 3.12** with pip
- **Node.js 20.x LTS** with npm
- **pnpm** - Fast Node package manager
- **uv** - Fast Python package manager
- **pytest** - Python testing framework
- **Claude Code CLI** - Anthropic's AI coding assistant (with deepwiki MCP server preconfigured)
- **GitHub CLI (gh)** - GitHub from the command line
- **Zsh** - Shell
- **Common build tools** - build-essential, libssl-dev, etc.

## What's Bind-Mounted from Host

- `~/.ssh` (readonly) - Your SSH keys

## Pre-built Golden Image

A ready-to-use golden image is available at:
```
contextable/dev-environment-golden
```

Pull it and skip the build steps:
```bash
docker pull contextable/dev-environment-golden
docker tag contextable/dev-environment-golden dev-environment-golden
./launch.sh my-project
```

## Quick Start

### First-time setup: Create the golden image

1. Build the base image:
   ```bash
   ./build.sh
   ```

2. Open this folder in VS Code

3. Select "Reopen in Container" (or "Rebuild and Reopen in Container")

4. Once VS Code is connected and the Dockerfile has executed, close VS Code and commit the golden image:
   ```bash
   ./commit-golden.sh
   ```

### Launch project containers

Once you have a golden image, launch containers for your projects:

```bash
./launch.sh              # uses default name "dev-environment"
./launch.sh my-project   # or specify a custom name
```

Connect with VS Code:
- Command Palette → `Dev Containers: Attach to Running Container...`
- Select your container

First-time setup inside the container:
```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
gh auth login
claude
```

Clone repos and start working:
```bash
cd ~/workspaces
git clone git@github.com:your-org/your-repo.git
```

## Helper Scripts

| Script | Description |
|--------|-------------|
| `./build.sh` | Build the `dev-environment` base Docker image |
| `./launch.sh [name]` | Launch a container from the golden image (required) |
| `./stop.sh [name]` | Stop a container (preserves state) |
| `./commit-golden.sh [name]` | Commit a container as the golden image (cleans user data first) |

## Golden Images

The golden image (`dev-environment-golden`) contains the base image plus VS Code server fully configured. This is required for `launch.sh` to work.

The `commit-golden.sh` script automatically cleans user data before committing:
- VS Code server state and extensions
- Claude auth data
- GitHub CLI auth
- Git config
- Shell history
- Package manager caches

New containers will prompt you to set up git, gh, and claude on first use.

To rebuild the golden image after Dockerfile changes:

```bash
./build.sh
# Open in VS Code → "Rebuild and Reopen in Container"
# Close VS Code when done
./commit-golden.sh
```

## Key Behaviors

- **Container persists**: Containers keep running when you close VS Code (`shutdownAction: none`)
- **Named containers**: Each container has a unique name so you can run multiple environments
- **Everything inside**: Workspaces, Claude context, git config all live in the container

## Reconnecting

Using VS Code:
- `Dev Containers: Attach to Running Container...` → select your container

Or via command line:
```bash
docker exec -it dev-environment zsh
```

## Moving to Another Machine

Export the container with all its state:
```bash
docker commit dev-environment my-dev-env:latest
docker save my-dev-env:latest | gzip > my-dev-env.tar.gz
```

On the target machine:
```bash
gunzip -c my-dev-env.tar.gz | docker load
docker run -d --name dev-environment --entrypoint "" my-dev-env:latest /bin/sh -c "sleep infinity"
```

Then attach VS Code to it.

## Customization

- Add tools: Edit `.devcontainer/Dockerfile`
- Change forwarded ports: Edit `.devcontainer/devcontainer.json` → `forwardPorts`
- Add VS Code extensions: Install them in the container, then commit a golden image
