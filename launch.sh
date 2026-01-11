#!/bin/bash
set -e

GOLDEN_IMAGE="dev-environment-golden"
DEFAULT_NAME="dev-environment"

# Get container name from argument or prompt
if [ -n "$1" ]; then
    CONTAINER_NAME="$1"
else
    read -p "Container name [$DEFAULT_NAME]: " CONTAINER_NAME
    CONTAINER_NAME="${CONTAINER_NAME:-$DEFAULT_NAME}"
fi

# Require golden image
if ! docker image inspect "$GOLDEN_IMAGE" &> /dev/null; then
    echo "Error: Golden image '$GOLDEN_IMAGE' not found."
    echo ""
    echo "To create the golden image:"
    echo "  1. Run ./build.sh to build the base image"
    echo "  2. Open this folder in VS Code"
    echo "  3. Select 'Reopen in Container' (or 'Rebuild and Reopen in Container')"
    echo "  4. Once VS Code is connected and the Dockerfile has executed,"
    echo "     close VS Code and run ./commit-golden.sh"
    exit 1
fi

echo "Using golden image: $GOLDEN_IMAGE"

# Check if container exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    # Container exists - check if running
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container '$CONTAINER_NAME' is already running."
    else
        echo "Starting existing container '$CONTAINER_NAME'..."
        docker start "$CONTAINER_NAME"
    fi
else
    # Container doesn't exist - create it
    echo "Creating container '$CONTAINER_NAME'..."
    docker run -d \
        --name "$CONTAINER_NAME" \
        --hostname "$CONTAINER_NAME" \
        --entrypoint "" \
        -v "$HOME/.ssh:/home/developer/.ssh:ro" \
        -v vscode:/vscode \
        "$GOLDEN_IMAGE" \
        /bin/sh -c "sleep infinity"
fi

echo ""
echo "Container '$CONTAINER_NAME' is running."
echo ""
echo "To connect with VS Code:"
echo "  1. Open VS Code"
echo "  2. Command Palette → 'Dev Containers: Attach to Running Container...'"
echo "  3. Select '/$CONTAINER_NAME'"
echo ""
echo "Or open a shell directly:"
echo "  docker exec -it $CONTAINER_NAME zsh"
