# Kanban Board Frontend Container

This container runs the React Kanban frontend.

Build-time:
- Node 18 (alpine) used for the app.
- The app is located in `kanban_board_frontend`.

Runtime:
- Runs `npm start` (development server) on port 3000.
- Working directory: `/home/kavia/workspace/code-generation/kanban-task-manager-121675-286957/kanban_board_frontend`

Environment variables:
- See .env.example for the complete list.
- These are passed to the container and picked up by `react-scripts`.
