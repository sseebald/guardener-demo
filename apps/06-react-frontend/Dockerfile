# DEMO FIXTURE. The base images below are deliberately upstream Docker Hub
# images. This file is the "before" state that Guardener migrates. Don't copy it
# as a reference architecture. See ../../README.md.
#
# Tier: intermediate. Node builds the bundle, nginx serves it.
# Expected: comment only on the node stage, one-click suggestion on the nginx
# serving stage.

FROM node:20-alpine AS build

WORKDIR /app

COPY package.json ./
RUN npm install

COPY src ./src
RUN npm run build

FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 8080

ENTRYPOINT ["nginx", "-g", "daemon off;"]
