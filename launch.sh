#!/bin/bash
set -e

BASE_IMAGE="dev-environment"
GOLDEN_IMAGE="dev-environment-golden"
DEFAULT_NAME="dev-environment"

# Get container name from argument or prompt
if [ -n "$1" ]; then
    CONTAINER_NAME="$1"
else
    read -p "Container name [$DEFAULT_NAME]: " CONTAINER_NAME
    CONTAINER_NAME="${CONTAINER_NAME:-$DEFAULT_NAME}"
fi

# Use golden image if it exists, otherwise base image
if docker image inspect "$GOLDEN_IMAGE" &> /dev/null; then
    IMAGE_NAME="$GOLDEN_IMAGE"
    echo "Using golden image: $GOLDEN_IMAGE"
else
    IMAGE_NAME="$BASE_IMAGE"
    echo "Using base image: $BASE_IMAGE (no golden image found)"
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
    # Use --entrypoint to override any entrypoint set during commit
echo "Creating container '$CONTAINER_NAME'..."
    docker run -d \
        --name "$CONTAINER_NAME" \
        --hostname "$CONTAINER_NAME" \
        --entrypoint "" \
        -v "$HOME/.ssh:/home/developer/.ssh:ro" \
        -v vscode:/vscode \
        "$IMAGE_NAME" \
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
