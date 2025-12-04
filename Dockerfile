# syntax=docker/dockerfile:1

# Use official Node.js LTS image
FROM node:18-alpine AS base

# Set a generic app root inside the image
WORKDIR /app

# Install OS updates and utilities (optional but useful)
RUN apk add --no-cache tini

# Copy package manager files first to leverage Docker layer caching
# Copy to a stable path inside the image
COPY kanban_board_frontend/package.json /app/kanban_board_frontend/package.json
# Lock files are optional; copy them if present
COPY kanban_board_frontend/package-lock.json /app/kanban_board_frontend/package-lock.json
COPY kanban_board_frontend/yarn.lock /app/kanban_board_frontend/yarn.lock
COPY kanban_board_frontend/pnpm-lock.yaml /app/kanban_board_frontend/pnpm-lock.yaml

# Move into the real frontend directory inside the image
WORKDIR /app/kanban_board_frontend

# Install dependencies
RUN if [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
    elif [ -f package-lock.json ]; then npm ci; \
    else npm install; fi

# Copy the rest of the app source into the working directory
COPY kanban_board_frontend/ .

# Expose port (align with CRA default and env-configurable port)
EXPOSE 3000

# Environment variables (read at runtime; default fallbacks)
# These can be overridden via docker run -e or docker-compose env
ENV PORT=3000 \
    HOST=0.0.0.0 \
    REACT_APP_API_BASE="" \
    REACT_APP_BACKEND_URL="" \
    REACT_APP_FRONTEND_URL="" \
    REACT_APP_WS_URL="" \
    REACT_APP_NODE_ENV="production" \
    REACT_APP_NEXT_TELEMETRY_DISABLED="1" \
    REACT_APP_ENABLE_SOURCE_MAPS="false" \
    REACT_APP_PORT="3000"

# Use Tini as init to handle PID 1 and signals properly
ENTRYPOINT ["/sbin/tini", "--"]

# Start the React dev server (or serve build if you adjust to a multi-stage prod image)
# Ensure the dev server binds to 0.0.0.0 and respects PORT
CMD [ "sh", "-lc", "echo Using WORKDIR: $(pwd) && PORT=${REACT_APP_PORT:-$PORT} HOST=${HOST:-0.0.0.0} npm start" ]
