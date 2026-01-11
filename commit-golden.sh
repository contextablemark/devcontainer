#!/bin/bash
set -e

SOURCE_CONTAINER="${1:-dev-environment}"
GOLDEN_IMAGE="dev-environment-golden"

# Check container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "^${SOURCE_CONTAINER}$"; then
    echo "Error: Container '$SOURCE_CONTAINER' does not exist."
    echo "Usage: ./commit-golden.sh [container-name]"
    exit 1
fi

# Check container is running (needed to exec into it)
if ! docker ps --format '{{.Names}}' | grep -q "^${SOURCE_CONTAINER}$"; then
    echo "Error: Container '$SOURCE_CONTAINER' is not running."
    echo "Start it first, then run this script."
    exit 1
fi

# Clean user and project data before committing golden image
# NOTE: We do NOT clean ~/workspaces because it may be bind-mounted from host!
echo "Cleaning user data..."

# VS Code server (all state and extensions)
docker exec "$SOURCE_CONTAINER" sh -c 'rm -rf ~/.vscode-server/data/User 2>/dev/null || true'
docker exec "$SOURCE_CONTAINER" sh -c 'rm -rf ~/.vscode-server/data/Machine 2>/dev/null || true'
docker exec "$SOURCE_CONTAINER" sh -c 'rm -rf ~/.vscode-server/extensions 2>/dev/null || true'

# Claude auth data (keeps ~/.claude.json MCP config, removes ~/.claude/ user data)
docker exec "$SOURCE_CONTAINER" sh -c 'rm -rf ~/.claude 2>/dev/null || true'

# GitHub CLI auth
docker exec "$SOURCE_CONTAINER" sh -c 'rm -rf ~/.config/gh 2>/dev/null || true'

# Git config and credentials
docker exec "$SOURCE_CONTAINER" sh -c 'rm -f ~/.gitconfig ~/.git-credentials 2>/dev/null || true'
docker exec "$SOURCE_CONTAINER" sh -c 'rm -rf ~/.config/git 2>/dev/null || true'

# Shell history
docker exec "$SOURCE_CONTAINER" sh -c 'rm -f ~/.zsh_history ~/.bash_history 2>/dev/null || true'

# Package manager caches
docker exec "$SOURCE_CONTAINER" sh -c 'rm -rf ~/.npm ~/.pnpm-store ~/.cache ~/.local 2>/dev/null || true'

echo "Stopping container..."
docker stop "$SOURCE_CONTAINER"

# Wait for container to fully stop
while docker ps --format '{{.Names}}' | grep -q "^${SOURCE_CONTAINER}$"; do
    echo "Waiting for container to stop..."
    sleep 1
done

echo "Committing container '$SOURCE_CONTAINER' as golden image '$GOLDEN_IMAGE'..."
docker commit "$SOURCE_CONTAINER" "$GOLDEN_IMAGE"

echo ""
echo "Done. Golden image '$GOLDEN_IMAGE' created."
echo ""
echo "You can now launch new containers from this image:"
echo "  ./launch.sh my-project"
