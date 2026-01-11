#!/bin/bash
set -e

SOURCE_CONTAINER="${1:-dev-environment}"
GOLDEN_IMAGE="dev-environment-golden"

if ! docker ps -a --format '{{.Names}}' | grep -q "^${SOURCE_CONTAINER}$"; then
    echo "Error: Container '$SOURCE_CONTAINER' does not exist."
    echo "Usage: ./commit-golden.sh [container-name]"
    exit 1
fi

echo "Committing container '$SOURCE_CONTAINER' as golden image '$GOLDEN_IMAGE'..."
docker commit "$SOURCE_CONTAINER" "$GOLDEN_IMAGE"

echo ""
echo "Done. Golden image '$GOLDEN_IMAGE' created."
echo ""
echo "You can now launch new containers from this image:"
echo "  ./launch.sh my-project"
