# DEMO FIXTURE. The base image below is deliberately an upstream Docker Hub
# image. This file is the "before" state that Guardener migrates. Don't copy it
# as a reference architecture. See ../../README.md.
#
# Tier: complex. A shared "golden base" image in the ONBUILD style that a lot of
# platform teams still carry. Downstream services just write `FROM
# northwind/node-base` and inherit the build steps below.
#
# Expected: Guardener reports this reference under "Not migrated". ONBUILD
# defers instructions to whatever builds on this image, so Guardener cannot
# reason about what the base needs. The trailing CMD without an ENTRYPOINT is a
# second, independent blocker.

FROM node:20-alpine

LABEL org.opencontainers.image.title="northwind-node-base" \
      org.opencontainers.image.description="Shared Node base for Northwind services"

WORKDIR /usr/src/app

ONBUILD COPY package.json ./
ONBUILD RUN npm install --omit=dev
ONBUILD COPY . ./

EXPOSE 3000

CMD ["node", "index.js"]
