FROM nginx:stable-alpine

# environment arguments
ARG UID
ARG GID
ARG USER
ARG TZ

ENV UID=${UID}
ENV GID=${GID}
ENV USER=${USER}
ENV TZ=${TZ}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN delgroup dialout

# Install logrotate and openssl
RUN apk update &&\
    apk upgrade &&\
    apk --update add logrotate &&\
    apk add --no-cache openssl &&\
    apk add --no-cache curl

RUN addgroup -g ${GID} --system ${USER}
RUN adduser -G ${USER} --system -D -s /bin/sh -u ${UID} ${USER}

# Modify nginx configuration to use the new user's priviledges for starting it.
ADD ./.docker/nginx/web/nginx.conf /etc/nginx/nginx.conf
#RUN sed -i "s/user nginx/user ${USER}/g" /etc/nginx/nginx.conf
#RUN sed -i "s/user nginx/nginx '${USER}'/g" /etc/nginx/nginx.conf

# Copies nginx configurations to override the default.
ADD ./.docker/nginx/web/sites/dev.default.conf /etc/nginx/conf.d/default.conf

COPY ./.docker/nginx/web/logrotate/nginx_log.conf /etc/logrotate.d/nginx
COPY ./.docker/nginx/web/ssl /var/www/ssl

COPY ./.docker/nginx/web/nginx-service.sh /var/log/nginx-service.sh
RUN chmod +x /var/log/nginx-service.sh

ENTRYPOINT ["/var/log/nginx-service.sh", "/var/www/ssl"]