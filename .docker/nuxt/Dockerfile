# Nuxt.js Dockerfile-prod-dev
FROM node:20.15-alpine

ARG WORK_DIR
ENV WORK_DIR=${WORK_DIR}

# Install dependencies
WORKDIR ${WORK_DIR}

COPY ./.docker/nuxt/start-service.sh /usr/local/bin/start-service.sh
RUN chmod +x /usr/local/bin/start-service.sh

# Expose port and start the application
EXPOSE 3000
ENTRYPOINT ["start-service.sh"]