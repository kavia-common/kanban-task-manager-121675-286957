# Init Scripts

This folder contains helper scripts used by CI hooks for linting/build checks.

- .linter.sh: Runs npm install and lint within kanban_board_frontend.
- .build.sh: Ensures the expected directory exists and optionally builds.

Both scripts resolve paths relative to this container root to avoid referencing a non-existent workspace root path.
