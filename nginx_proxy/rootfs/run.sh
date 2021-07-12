#!/usr/bin/env bashio
set -e

DHPARAMS_PATH=/data/dhparams.pem

SNAKEOIL_CERT=/data/ssl-cert-snakeoil.pem
SNAKEOIL_KEY=/data/ssl-cert-snakeoil.key

CLOUDFLARE_CONF=/data/cloudflare.conf

DOMAIN=$(bashio::config 'domain')
KEYFILE=$(bashio::config 'keyfile')
CERTFILE=$(bashio::config 'certfile')
HSTS=$(bashio::config 'hsts')

# Generate dhparams
if ! bashio::fs.file_exists "${DHPARAMS_PATH}"; then
    bashio::log.info  "Generating dhparams (this will take some time)..."
    openssl dhparam -dsaparam -out "$DHPARAMS_PATH" 4096 > /dev/null
fi

if ! bashio::fs.file_exists "${SNAKEOIL_CERT}"; then
    bashio::log.info "Creating 'snakeoil' self-signed certificate..."
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout $SNAKEOIL_KEY -out $SNAKEOIL_CERT -subj '/CN=localhost'
fi

if bashio::config.true 'cloudflare'; then
    sed -i "s|#include /data/cloudflare.conf;|include /data/cloudflare.conf;|" /etc/nginx.conf
    # Generate cloudflare.conf
    if ! bashio::fs.file_exists "${CLOUDFLARE_CONF}"; then
        bashio::log.info "Creating 'cloudflare.conf' for real visitor IP address..."
        echo "# Cloudflare IP addresses" > $CLOUDFLARE_CONF;
        echo "" >> $CLOUDFLARE_CONF;

        echo "# - IPv4" >> $CLOUDFLARE_CONF;
        for i in $(curl https://www.cloudflare.com/ips-v4); do
            echo "set_real_ip_from ${i};" >> $CLOUDFLARE_CONF;
        done

        echo "" >> $CLOUDFLARE_CONF;
        echo "# - IPv6" >> $CLOUDFLARE_CONF;
        for i in $(curl https://www.cloudflare.com/ips-v6); do
            echo "set_real_ip_from ${i};" >> $CLOUDFLARE_CONF;
        done

        echo "" >> $CLOUDFLARE_CONF;
        echo "real_ip_header CF-Connecting-IP;" >> $CLOUDFLARE_CONF;
    fi
fi

# Prepare config file
sed -i "s#%%FULLCHAIN%%#$CERTFILE#g" /etc/nginx.conf
sed -i "s#%%PRIVKEY%%#$KEYFILE#g" /etc/nginx.conf
sed -i "s/%%DOMAIN%%/$DOMAIN/g" /etc/nginx.conf

[ -n "$HSTS" ] && HSTS="add_header Strict-Transport-Security \"$HSTS\" always;"
sed -i "s/%%HSTS%%/$HSTS/g" /etc/nginx.conf

# Allow customize configs from share
if bashio::config.true 'customize.active'; then
    CUSTOMIZE_DEFAULT=$(bashio::config 'customize.default')
    sed -i "s|#include /share/nginx_proxy_default.*|include /share/$CUSTOMIZE_DEFAULT;|" /etc/nginx.conf
    CUSTOMIZE_SERVERS=$(bashio::config 'customize.servers')
    sed -i "s|#include /share/nginx_proxy/.*|include /share/$CUSTOMIZE_SERVERS;|" /etc/nginx.conf
fi

if bashio::config.true 'security.active'; then
    SECURITY_MODE=$(bashio::config 'security.mode')

    # Enable ModSecurity
    sed -i -e "s|#load_module modules/ngx_http_modsecurity_module.so;|load_module modules/ngx_http_modsecurity_module.so;|" \
        -e "s|#modsecurity on;|modsecurity on;|" \
        -e "s|#modsecurity_rules_file /etc/nginx/modsec/main.conf;|modsecurity_rules_file /etc/nginx/modsec/main.conf;|" \
        /etc/nginx.conf


    # Configure ModSecurity run mode
    sed -i "s/%%SECURITY_MODE%%/$SECURITY_MODE/g" /etc/nginx/modsec/modsecurity.conf
fi

# start server
bashio::log.info "Running nginx..."
exec nginx -c /etc/nginx.conf < /dev/null
