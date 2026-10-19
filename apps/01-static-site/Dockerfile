# DEMO FIXTURE. The base image below is deliberately an upstream Docker Hub
# image. This file is the "before" state that Guardener migrates. Don't copy it
# as a reference architecture. See ../../README.md.
#
# Tier: easy. Single stage, no RUN, exec-form ENTRYPOINT.
# Expected: Guardener should offer a one-click suggested change here.

FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY site/ /usr/share/nginx/html/

EXPOSE 8080

ENTRYPOINT ["nginx", "-g", "daemon off;"]
