# Dev Server Port and Host Notes

- The app uses Create React App (react-scripts).
- The dev server must bind to 0.0.0.0 inside containers so the orchestrator can reach it.
- Scripts ensure PORT and HOST are respected and forwarded to webpack-dev-server:

How it works:
- Dockerfile sets HOST=0.0.0.0 and PORT defaults to 3000.
- package.json start script passes `--host 0.0.0.0 --port ${REACT_APP_PORT:-$PORT}` to react-scripts.

Environment variables:
- PORT: primary port; default 3000.
- REACT_APP_PORT: optional override for port; if present it takes precedence in start script.

Local run:
- npm start (binds to 0.0.0.0:3000, accessible at http://localhost:3000)

Override port:
- REACT_APP_PORT=4000 npm start  # binds to 0.0.0.0:4000
