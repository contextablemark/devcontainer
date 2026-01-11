#!/bin/bash
set -e

CONTAINER_NAME="dev-environment"
IMAGE_NAME="dev-environment"

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
        --hostname dev \
        -v "$HOME/.ssh:/home/developer/.ssh:ro" \
        -v "$HOME/.vscode-server:/home/developer/.vscode-server" \
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
