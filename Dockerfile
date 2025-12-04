# Use an official Node runtime as a parent image
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files first for better caching
COPY kanban_board_frontend/package.json kanban_board_frontend/package-lock.json* ./kanban_board_frontend/

# Install dependencies
RUN cd kanban_board_frontend && npm ci --legacy-peer-deps

# Copy the rest of the application code
COPY kanban_board_frontend ./kanban_board_frontend

# Build the React app
RUN cd kanban_board_frontend && npm run build

# Production stage with a lightweight web server
FROM nginx:alpine AS production

# Create expected directory path to avoid runtime errors about missing directory
# As requested: ensure /home/kavia/workspace/code-generation/kanban-task-manager-121675/kanban_board_frontend exists
RUN mkdir -p /home/kavia/workspace/code-generation/kanban-task-manager-121675/kanban_board_frontend

# Copy built assets to nginx html directory
COPY --from=build /app/kanban_board_frontend/build /usr/share/nginx/html

# Generate a runtime config.json under the expected path and also expose a copy at the web root for client access
# Values are picked up from environment variables at container start via a small entrypoint script
# We write a default placeholder for build-time to prevent missing-file errors before start
RUN printf '{\n  "REACT_APP_API_BASE": "",\n  "REACT_APP_BACKEND_URL": "",\n  "REACT_APP_FRONTEND_URL": "",\n  "REACT_APP_WS_URL": "",\n  "REACT_APP_NODE_ENV": "",\n  "REACT_APP_NEXT_TELEMETRY_DISABLED": "",\n  "REACT_APP_ENABLE_SOURCE_MAPS": "",\n  "REACT_APP_PORT": "",\n  "REACT_APP_TRUST_PROXY": "",\n  "REACT_APP_LOG_LEVEL": "",\n  "REACT_APP_HEALTHCHECK_PATH": "",\n  "REACT_APP_FEATURE_FLAGS": "",\n  "REACT_APP_EXPERIMENTS_ENABLED": ""\n}\n' > /home/kavia/workspace/code-generation/kanban-task-manager-121675/kanban_board_frontend/config.json && \
    cp /home/kavia/workspace/code-generation/kanban-task-manager-121675/kanban_board_frontend/config.json /usr/share/nginx/html/config.json

# Add an entrypoint script that renders config.json from environment variables at container start
COPY --chown=root:root ./kanban_board_frontend/README.md /tmp/.keep  # no-op to keep layer structure
RUN printf '#!/bin/sh\nset -e\nCONFIG_DIR=\"/home/kavia/workspace/code-generation/kanban-task-manager-121675/kanban_board_frontend\"\nmkdir -p \"$CONFIG_DIR\"\ncat > \"$CONFIG_DIR/config.json\" <<EOF\n{\n  \"REACT_APP_API_BASE\": \"${REACT_APP_API_BASE}\",\n  \"REACT_APP_BACKEND_URL\": \"${REACT_APP_BACKEND_URL}\",\n  \"REACT_APP_FRONTEND_URL\": \"${REACT_APP_FRONTEND_URL}\",\n  \"REACT_APP_WS_URL\": \"${REACT_APP_WS_URL}\",\n  \"REACT_APP_NODE_ENV\": \"${REACT_APP_NODE_ENV}\",\n  \"REACT_APP_NEXT_TELEMETRY_DISABLED\": \"${REACT_APP_NEXT_TELEMETRY_DISABLED}\",\n  \"REACT_APP_ENABLE_SOURCE_MAPS\": \"${REACT_APP_ENABLE_SOURCE_MAPS}\",\n  \"REACT_APP_PORT\": \"${REACT_APP_PORT}\",\n  \"REACT_APP_TRUST_PROXY\": \"${REACT_APP_TRUST_PROXY}\",\n  \"REACT_APP_LOG_LEVEL\": \"${REACT_APP_LOG_LEVEL}\",\n  \"REACT_APP_HEALTHCHECK_PATH\": \"${REACT_APP_HEALTHCHECK_PATH}\",\n  \"REACT_APP_FEATURE_FLAGS\": \"${REACT_APP_FEATURE_FLAGS}\",\n  \"REACT_APP_EXPERIMENTS_ENABLED\": \"${REACT_APP_EXPERIMENTS_ENABLED}\"\n}\nEOF\ncp \"$CONFIG_DIR/config.json\" /usr/share/nginx/html/config.json\nexec nginx -g \"daemon off;\"\n' > /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

# Expose default HTTP port
EXPOSE 80

# Healthcheck using an optional path variable (defaults to root)
ENV REACT_APP_HEALTHCHECK_PATH=/
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD wget -qO- "http://localhost${REACT_APP_HEALTHCHECK_PATH:-/}" >/dev/null 2>&1 || exit 1

# Run the entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
