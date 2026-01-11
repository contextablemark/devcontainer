# Universal Dev Container

A self-contained development environment for OSS development. Everything lives inside the container—workspaces, Claude Code context, git config, gh auth—so you can pick up where you left off or move the container to another machine.

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

## Quick Start (Standalone Docker)

1. Build the base image:
   ```bash
   ./build.sh
   ```

2. Launch a container:
   ```bash
   ./launch.sh              # uses default name "dev-environment"
   ./launch.sh my-project   # or specify a custom name
   ```

3. Connect with VS Code:
   - Command Palette → `Dev Containers: Attach to Running Container...`
   - Select your container

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

## Alternative: VS Code Dev Container Workflow

You can also use the standard VS Code Dev Container workflow:

1. Open this folder in VS Code
2. When prompted, click "Reopen in Container" (or use Command Palette: `Dev Containers: Reopen in Container`)

## Helper Scripts

| Script | Description |
|--------|-------------|
| `./build.sh` | Build the `dev-environment` Docker image |
| `./launch.sh [name]` | Start or create a container (prompts for name if not provided) |
| `./stop.sh` | Stop the running container (preserves state) |

## Golden Images

Save your fully configured environment as a "golden image" to quickly spin up new containers with all your tools, extensions, and configurations pre-installed:

```bash
# Commit your configured container as a golden image
docker commit dev-environment dev-environment-golden
```

When `launch.sh` runs, it automatically uses `dev-environment-golden` if it exists, otherwise falls back to the base `dev-environment` image.

## Key Behaviors

- **Container persists**: Containers keep running when you close VS Code (`shutdownAction: none`)
- **Named containers**: Each container has a unique name so you can run multiple environments
- **Per-container extensions**: VS Code extensions are stored in a Docker volume, isolated per container
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
docker run -d --name dev-environment my-dev-env:latest sleep infinity
```

Then attach VS Code to it.

## Customization

- Add tools: Edit `.devcontainer/Dockerfile`
- Change forwarded ports: Edit `.devcontainer/devcontainer.json` → `forwardPorts`
- Add VS Code extensions: Install them in the container, then commit a golden image
