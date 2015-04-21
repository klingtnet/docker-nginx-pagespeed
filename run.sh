#!/usr/bin/env bash
NAME=${NAME:-'nginx-pagespeed'}
HTTP_PORT=${HTTP_PORT:-8888}
SSL_PORT=${SSL_PORT:-10043}
SITES=${SITES:-$PWD/share/sites}
CONFIG_PATH=${CONFIG_PATH:-$PWD/share/conf}
docker run --rm --name ${NAME} -p 9999:80 -p 10443:443 -v ${CONFIG_PATH}:/etc/nginx -v ${SITES}:/usr/share/sites:ro nginx-pagespeed
