# Kanban Task Manager Frontend

This container packages a Create React App (CRA) frontend for the Kanban board.

Dockerfile uses image-internal paths (no host-specific absolute paths):
- App root inside image: `/app`
- Frontend WORKDIR: `/app/kanban_board_frontend`

Build:
  docker build -t kanban-task-manager-frontend .

Run (mapping port 3000):
  docker run --rm -it -p 3000:3000 --env-file .env --name kanban-task-manager-121675-286957 kanban-task-manager-frontend

Environment variables (can be set via .env or -e):
- REACT_APP_API_BASE
- REACT_APP_BACKEND_URL
- REACT_APP_FRONTEND_URL
- REACT_APP_WS_URL
- REACT_APP_NODE_ENV
- REACT_APP_NEXT_TELEMETRY_DISABLED
- REACT_APP_ENABLE_SOURCE_MAPS
- REACT_APP_PORT

Notes:
- The Dockerfile uses Tini as PID 1 to properly handle signals.
- By default, it runs the CRA dev server. For production, you can extend the Dockerfile to build the app and serve static files via Nginx or Node.
- The .init/.linter.sh script is resilient and will use the repo-relative `./kanban_board_frontend` on host or `/app/kanban_board_frontend` inside the container.
