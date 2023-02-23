FROM node:18.14.2-alpine3.17

# Create app directory
WORKDIR /usr/src/app

# Bundle app source
COPY . .

RUN npm install

EXPOSE 8080
CMD [ "node", "server.js" ]