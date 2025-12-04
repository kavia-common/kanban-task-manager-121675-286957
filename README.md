# Kanban Board Frontend Container

This container builds and serves the React Kanban frontend via NGINX.

Build-time:
- Node 18 (alpine) used for building the app.
- The app is built from kanban_board_frontend.

Runtime:
- NGINX serves the static build.
- The container creates and maintains the directory:
  /home/kavia/workspace/code-generation/kanban-task-manager-121675/kanban_board_frontend
- A runtime config.json is generated from environment variables at container start and placed at:
  - /home/kavia/workspace/code-generation/kanban-task-manager-121675/kanban_board_frontend/config.json
  - /usr/share/nginx/html/config.json (so the client can fetch it)

Environment variables:
- See .env.example for the complete list.
- Ensure these are set by the orchestrator/CI when starting the container.

Healthcheck:
- Uses REACT_APP_HEALTHCHECK_PATH (defaults to "/") to verify the server is responding.
