#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="dev-environment"

echo "Building dev-environment image..."
docker build -t "$IMAGE_NAME" -f "$SCRIPT_DIR/.devcontainer/Dockerfile" "$SCRIPT_DIR/.devcontainer"

echo ""
echo "Done. Image '$IMAGE_NAME' is ready."
echo ""
echo "Next steps to create the golden image:"
echo "  1. Open this folder in VS Code"
echo "  2. Select 'Rebuild and Reopen in Container'"
echo "  3. Close VS Code and run ./commit-golden.sh"
