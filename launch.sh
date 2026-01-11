#!/bin/bash
set -e

IMAGE_NAME="dev-environment"
DEFAULT_NAME="dev-environment"

# Get container name from argument or prompt
if [ -n "$1" ]; then
    CONTAINER_NAME="$1"
else
    read -p "Container name [$DEFAULT_NAME]: " CONTAINER_NAME
    CONTAINER_NAME="${CONTAINER_NAME:-$DEFAULT_NAME}"
fi

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
    echo "Creating and starting container '$CONTAINER_NAME'..."
    docker run -d \
        --name "$CONTAINER_NAME" \
        --hostname "$CONTAINER_NAME" \
        -v "$HOME/.ssh:/home/developer/.ssh:ro" \
        -v vscode-server-$CONTAINER_NAME:/home/developer/.vscode-server \
        "$IMAGE_NAME" \
        sleep infinity
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
