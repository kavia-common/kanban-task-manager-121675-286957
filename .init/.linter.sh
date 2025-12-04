#!/bin/bash
# Ensure we run the build in the correct frontend directory for this container/workspace.
set -euo pipefail

# Resolve script directory and repo root reliably
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Candidate directories to locate the frontend:
# 1) Path relative to repo root where this script lives
# 2) Path relative to current PWD (runner might invoke from base directory)
# 3) Path relative to parent of PWD (runner may be at base_directory and repo is a subfolder)
# 4) Image-internal path used in Dockerfile
CANDIDATES=(
  "${REPO_ROOT}/kanban_board_frontend"
  "${PWD}/kanban_board_frontend"
  "${PWD}/kanban-task-manager-121675-286957/kanban_board_frontend"
  "/app/kanban_board_frontend"
)

TARGET_DIR=""
for d in "${CANDIDATES[@]}"; do
  if [ -d "$d" ]; then
    TARGET_DIR="$d"
    break
  fi
done

if [ -z "${TARGET_DIR}" ]; then
  echo "Error: Could not find frontend directory in any of the expected locations:" >&2
  for d in "${CANDIDATES[@]}"; do echo "  - $d" >&2; done
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
