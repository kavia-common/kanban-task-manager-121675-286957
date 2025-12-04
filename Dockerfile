# syntax=docker/dockerfile:1

# Use official Node.js LTS image
FROM node:18-alpine AS base

# Create and set working directory explicitly to the requested path
# Ensures the directory exists inside the container
RUN mkdir -p /home/kavia/workspace/code-generation/kanban-task-manager-121675-286957/kanban_board_frontend

WORKDIR /home/kavia/workspace/code-generation/kanban-task-manager-121675-286957/kanban_board_frontend

# Install OS updates and utilities (optional but useful)
RUN apk add --no-cache tini

# Copy package manager files first to leverage Docker layer caching
COPY kanban_board_frontend/package.json ./package.json
COPY kanban_board_frontend/package-lock.json ./package-lock.json 2>/dev/null || true
COPY kanban_board_frontend/yarn.lock ./yarn.lock 2>/dev/null || true
COPY kanban_board_frontend/pnpm-lock.yaml ./pnpm-lock.yaml 2>/dev/null || true

# Install dependencies
RUN if [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
    elif [ -f package-lock.json ]; then npm ci; \
    else npm install; fi

# Copy the rest of the app source
COPY kanban_board_frontend/ .

# Expose port (align with CRA default and env-configurable port)
EXPOSE 3000

# Environment variables (read at runtime; default fallbacks)
# These can be overridden via docker run -e or docker-compose env
ENV PORT=3000
ENV HOST=0.0.0.0
ENV REACT_APP_API_BASE=""
ENV REACT_APP_BACKEND_URL=""
ENV REACT_APP_FRONTEND_URL=""
ENV REACT_APP_WS_URL=""
ENV REACT_APP_NODE_ENV="production"
ENV REACT_APP_NEXT_TELEMETRY_DISABLED="1"
ENV REACT_APP_ENABLE_SOURCE_MAPS="false"
ENV REACT_APP_PORT="3000"

# Use Tini as init to handle PID 1 and signals properly
ENTRYPOINT ["/sbin/tini", "--"]

# Start the React dev server (or serve build if you adjust to a multi-stage prod image)
# Ensure the dev server binds to 0.0.0.0 and respects PORT
CMD [ "sh", "-lc", "echo Using WORKDIR: $(pwd) && PORT=${REACT_APP_PORT:-$PORT} HOST=${HOST:-0.0.0.0} npm start" ]
