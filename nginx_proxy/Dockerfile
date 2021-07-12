ARG BUILD_FROM

FROM ${BUILD_FROM} as build_modsecurity

ARG NGINX_VERSION
ARG MODSEC_BRANCH
ARG OWASP_BRANCH

WORKDIR /opt

# Install dependencies; includes dependencies required for compile-time options:
# curl, libxml, pcre, and lmdb and Modsec
# https://build.alpinelinux.org/buildlogs/build-3-11-x86_64/main/nginx/nginx-1.16.1-r6.log
RUN echo "Installing Dependencies" && \
    apk add --no-cache --virtual general-dependencies \
    alpine-sdk \
    autoconf \
    automake \
    byacc \
    curl-dev \
    findutils \
    flex \
    g++ \
    gcc \
    gd-dev \
    geoip-dev \
    git \
    libc-dev \
    libedit-dev \
    libstdc++ \
    libtool \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    lmdb-dev \
    make \
    libmaxminddb-dev \
    openssl-dev \
    pcre-dev \
    perl-dev \
    yajl-dev \
    zlib-dev

# Clone and compile modsecurity. Binary will be located in /usr/local/modsecurity
RUN echo "Installing ModSec Library" && \
    git clone -b ${MODSEC_BRANCH} --depth 1 https://github.com/SpiderLabs/ModSecurity && \
    git -C /opt/ModSecurity submodule update --init --recursive && \
    (cd "/opt/ModSecurity" && \
        ./build.sh && \
        ./configure && \
        make && \
        make install \
    ) && \
    rm -fr /opt/ModSecurity \
        /usr/local/modsecurity/lib/libmodsecurity.a \
        /usr/local/modsecurity/lib/libmodsecurity.la

# Clone Modsec Nginx Connector, ModSec OWASP Rules, and download/extract nginx and GeoIP databases
RUN echo 'Cloning Modsec Nginx Connector and ModSec OWASP Rules' && \
    git clone -b master --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git && \
    git clone -b ${OWASP_BRANCH} --depth 1 https://github.com/coreruleset/coreruleset.git /usr/local/owasp-modsecurity-crs && \
    wget -O - https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -xz

# Install ModSecurity Nginx modules
# Since Alpine nginx package is not compiled using
# `--with-compat` flag, we must specify all the same
# compile options that are used to compile the nginx Alpine
# packge when we configure the modsecurity nginx connector
# https://git.alpinelinux.org/aports/tree/main/nginx/APKBUILD?h=3.11-stable
RUN echo 'Installing Nginx Modules' && \
    (cd "/opt/nginx-${NGINX_VERSION}" && \
        ./configure --add-dynamic-module=../ModSecurity-nginx --prefix=/var/lib/nginx \
        --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf --pid-path=/run/nginx/nginx.pid \
        --lock-path=/run/nginx/nginx.lock --http-client-body-temp-path=/var/lib/nginx/tmp/client_body \
        --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi \
        --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi \
        --with-perl_modules_path=/usr/lib/perl5/vendor_perl --user=nginx --group=nginx --with-threads \
        --with-file-aio --with-http_ssl_module --with-http_v2_module --with-http_realip_module \
        --with-http_addition_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic \
        --with-http_geoip_module=dynamic --with-http_sub_module --with-http_dav_module --with-http_flv_module \
        --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module \
        --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_slice_module \
        --with-http_stub_status_module --with-http_perl_module=dynamic --with-mail=dynamic --with-mail_ssl_module \
        --with-stream=dynamic --with-stream_ssl_module --with-stream_realip_module --with-stream_geoip_module=dynamic \
        --with-stream_ssl_preread_module && \
        make modules \
    ) && \
    mkdir -p /usr/lib/nginx/modules && \
    cp /opt/nginx-${NGINX_VERSION}/objs/ngx_http_modsecurity_module.so \
        /usr/lib/nginx/modules/ && \
    rm -fr /opt/* && \
    apk del general-dependencies

FROM $BUILD_FROM

# Setup base
RUN apk add --no-cache \
    geoip \
    libmaxminddb \
    libstdc++ \
    libxml2 \
    lmdb \
    yajl \
    nginx \
    openssl \
    && mkdir /etc/nginx/modsec

# Copy owasp-modsecurity-crs and modsecurity from the build image
COPY --from=build_modsecurity /usr/local/modsecurity /usr/local/modsecurity
COPY --from=build_modsecurity /usr/local/owasp-modsecurity-crs /usr/local/owasp-modsecurity-crs
COPY --from=build_modsecurity /usr/lib/nginx/modules/ /usr/lib/nginx/modules/

# Copy data
COPY rootfs /

CMD [ "/run.sh" ]
