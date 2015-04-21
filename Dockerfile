FROM debian:latest
MAINTAINER Andreas Linz "klingt.net@gmail.com"

# inspired by the official nginx docker container
# https://github.com/nginxinc/docker-nginx/blob/master/Dockerfile

RUN apt-get update
RUN apt-get install -y build-essential \
    curl \
    libpcre3 \
    libpcre3-dev \
    libxml2-dev \
    libxslt1-dev \
    tar \
    unzip \
    zlib1g-dev 
RUN rm -rf /var/lib/apt/lists/*

RUN NPS_VERSION=1.9.32.3 \
    NGINX_VERSION=1.7.12 \
    PCRE_VERSION=8.35 \
    ZLIB_VERSION=1.2.8 \
    OPENSSL_VERSION=1_0_2a \
    NGINX_LOG_PATH=/var/log/nginx \
    NGINX_USER=www-data \
    NGINX_GROUP=www-data \
    TMP_DIR=$(mktemp -d) &&\
    curl -Ls https://github.com/pagespeed/ngx_pagespeed/archive/v${NPS_VERSION}-beta.tar.gz | tar -xvzf - \
        -C ${TMP_DIR} &&\
    curl -Ls https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz | tar -xvzf - \
        -C ${TMP_DIR}/ngx_pagespeed-${NPS_VERSION}-beta --exclude=lib/Debug &&\
    curl -Ls https://github.com/nginx/nginx/archive/v${NGINX_VERSION}.tar.gz | tar -xvzf - \
        -C ${TMP_DIR} &&\
    curl -Ls ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz | tar -xvzf - \
        -C ${TMP_DIR} &&\
    curl -Ls https://github.com/madler/zlib/archive/v1.2.8.tar.gz | tar -xvzf - \
        -C ${TMP_DIR} &&\
    curl -Ls https://github.com/openssl/openssl/archive/OpenSSL_${OPENSSL_VERSION}.tar.gz | tar -xzvf - \
        -C ${TMP_DIR} &&\
    cd ${TMP_DIR}/nginx-${NGINX_VERSION} &&\
    ./configure \
        --add-module=${TMP_DIR}/ngx_pagespeed-${NPS_VERSION}-beta \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=${NGINX_LOG_PATH}/error.log \
        --group=${NGINX_GROUP} \
        --http-log-path=${NGINX_LOG_PATH}/access.log \
        --lock-path=/var/lock/nginx.lock \
        --pid-path=/var/run/nginx.pid \
        --prefix=/usr/local/share/nginx \
        --sbin-path=/usr/sbin/nginx \
        --user=${NGINX_USER} \
        --with-cc-opt='-D_FORTIFY_SOURCE=2 -pie -fPIE -fstack-protector -Wformat -Wformat-security -fstack-protector -g -O1' \
        --with-ld-opt='-Wl,-z,now -Wl,-z,relro' \
        --with-http_addition_module \
        --with-http_dav_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_mp4_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_spdy_module \
        --with-http_ssl_module --with-openssl=${TMP_DIR}/openssl-OpenSSL_${OPENSSL_VERSION} \
        --with-http_sub_module \
        --with-http_sub_module \
        --with-http_xslt_module \
        --with-ipv6 \
        --with-mail \
        --with-mail_ssl_module \
        --with-pcre-jit \
        --with-pcre=${TMP_DIR}/pcre-${PCRE_VERSION} \
        --with-zlib=${TMP_DIR}/zlib-${ZLIB_VERSION} &&\
    make &&\
    make install &&\
    cd / && rm -rf ${TMP_DIR}

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443

VOLUME [ "/usr/share/sites", "/etc/nginx" ]

CMD [ "nginx", "-g", "daemon off;" ]
