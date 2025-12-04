# Use an official Node runtime as a parent image
FROM node:18-alpine

# Set the working directory to the correct project structure path to avoid chdir errors
WORKDIR /home/kavia/workspace/code-generation/kanban-task-manager-121675-286957/kanban_board_frontend

# Copy package files first for better caching
# Context is the container root: kanban-task-manager-121675-286957
COPY kanban_board_frontend/package.json kanban_board_frontend/package-lock.json* ./

# Install dependencies
RUN npm ci --legacy-peer-deps

# Copy the rest of the application code
COPY kanban_board_frontend/ .

# Expose the application port
EXPOSE 3000

# Start the application using npm start
CMD ["npm", "start"]
