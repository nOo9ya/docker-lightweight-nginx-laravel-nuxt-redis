#!/bin/sh

SSL_DIR=${1}

crond

if [ ! -f $SSL_DIR/default.crt ]; then
    openssl genrsa -out "$SSL_DIR/default.key" 2048
    openssl req -new -key "$SSL_DIR/default.key" -out "$SSL_DIR/default.csr" -subj "/CN=default/O=default"
    openssl x509 -req -days 365 -in "$SSL_DIR/default.csr" -signkey "$SSL_DIR/default.key" -out "$SSL_DIR/default.crt"
    chmod 644 $SSL_DIR/default.key
fi

# cron job to restart nginx every 6 hour
(crontab -l ; echo "0 0 */4 * * nginx -s reload") | crontab -

# Start crond in background
crond -l 2 -b
#* * * * * root nginx -s reload >> /var/log/cron.log


sed -i "s/0       2       */0       4       */g" /var/spool/cron/crontabs/root
# cron job to restart nginx every 04:20
echo "20      4       *       *       *       nginx -s reload" >> /var/spool/cron/crontabs/root;
# cron job to nginx log delete
echo "30      4       *       *       *       find /var/log/nginx/ -mtime +30 -delete" >> /var/spool/cron/crontabs/root;

logrotate /etc/logrotate.d/nginx

nginx -g 'daemon off;'