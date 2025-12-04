#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRONTEND_DIR="$ROOT_DIR/kanban_board_frontend"

# Ensure expected directory exists for tooling that checks it
mkdir -p "$FRONTEND_DIR"

if [ -f "$FRONTEND_DIR/package.json" ]; then
  echo "Installing dependencies and building frontend..."
  cd "$FRONTEND_DIR"
  npm ci --legacy-peer-deps
  if npm run | grep -qE '^  build'; then
    npm run build
  else
    echo "No build script found; skipping build."
  fi
else
  echo "No package.json in $FRONTEND_DIR; skipping build."
fi
