#!/bin/bash
set -e  # Exit on error

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

NGINX_CONF_FILE="$( readlink -m "${DIR}/../templates/nginx.conf" )"

echo 'Starting NGINX server'
"${DIR}/nginx/sbin/nginx" -c "$NGINX_CONF_FILE"

set +e  # Don't exit on error to be able to stop nginx
echo 'Executing wrk'
"${DIR}/wrk" "$@"
WRK_EXIT_CODE=$?

echo 'Stopping NGINX server'
"${DIR}/nginx/sbin/nginx" -s quit

exit $WRK_EXIT_CODE
