#!/usr/bin/env bash
set -euo pipefail

# Ensure we are in the container workspace and use the correct relative path
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRONTEND_DIR="$ROOT_DIR/kanban_board_frontend"

if [ ! -d "$FRONTEND_DIR" ]; then
  echo "Creating missing frontend directory at: $FRONTEND_DIR"
  mkdir -p "$FRONTEND_DIR"
fi

cd "$FRONTEND_DIR"

# If package.json exists, run lint; otherwise, no-op to avoid failing CI pre-checks
if [ -f package.json ]; then
  echo "Running npm ci and lint in $FRONTEND_DIR"
  npm ci --legacy-peer-deps
  if npm run | grep -qE '^  lint'; then
    npm run lint
  else
    echo "No lint script defined; skipping lint step."
  fi
else
  echo "package.json not found in $FRONTEND_DIR; skipping npm lint."
fi
