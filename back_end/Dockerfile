FROM node:lts-alpine

# Create app directory and set ownership
RUN mkdir -p /app && chown -R node:node /app
WORKDIR /app

# Create a non-root user to run the application
USER node

COPY --chown=node:node package*.json ./

RUN npm install && npm cache clean --force; 

COPY --chown=node:node . .

RUN mkdir -p logs

EXPOSE 3000

CMD ["npm", "start"]