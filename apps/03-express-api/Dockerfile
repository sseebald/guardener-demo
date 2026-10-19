# DEMO FIXTURE. The base image below is deliberately an upstream Docker Hub
# image. This file is the "before" state that Guardener migrates. Don't copy it
# as a reference architecture. See ../../README.md.
#
# Tier: easy. Single stage with a package install.
# Expected: replacement named, one-click withheld because of the RUN.

FROM node:20-alpine

ENV NODE_ENV=production

WORKDIR /app

COPY package.json ./
RUN npm install --omit=dev

COPY server.js ./

EXPOSE 3000

ENTRYPOINT ["node", "server.js"]
