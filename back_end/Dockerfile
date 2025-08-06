# Use official Node.js LTS Alpine image for smaller size
FROM node:lts-alpine

# Create app directory and set ownership
RUN mkdir -p /app && chown -R node:node /app
WORKDIR /app

# Create a non-root user to run the application
USER node

# Copy package.json and package-lock.json (if available) as node user
COPY --chown=node:node package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy application code
COPY --chown=node:node . .

# Create necessary directories with proper permissions
RUN mkdir -p logs

# Expose the port
EXPOSE 3000

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000', (res) => { \
        process.exit(res.statusCode === 200 ? 0 : 1) \
    }).on('error', () => process.exit(1))"

# Start the server
CMD ["npm", "start"]