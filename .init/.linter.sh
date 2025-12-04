#!/bin/bash
# Ensure we run the build in the correct frontend directory for this container/workspace.
set -euo pipefail

TARGET_DIR="/home/kavia/workspace/code-generation/kanban-task-manager-121675-286957/kanban_board_frontend"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Expected frontend directory not found at: $TARGET_DIR" >&2
  exit 1
fi

cd "$TARGET_DIR"

# Install dependencies if node_modules is missing (CI environments may have a fresh workspace)
if [ ! -d "node_modules" ]; then
  if [ -f "yarn.lock" ]; then
    yarn install --frozen-lockfile
  elif [ -f "package-lock.json" ]; then
    npm ci
  else
    npm install
  fi
fi

npm run build
