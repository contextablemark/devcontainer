#!/bin/bash

CONTAINER_NAME="${1:-dev-environment}"

if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping container '$CONTAINER_NAME'..."
    docker stop "$CONTAINER_NAME"
    echo "Done. Container stopped but preserved."
    echo "Run ./launch.sh to start it again."
else
    echo "Container '$CONTAINER_NAME' is not running."
fi
