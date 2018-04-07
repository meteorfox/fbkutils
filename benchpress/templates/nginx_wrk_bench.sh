#!/bin/bash
set -e  # Exit on error
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

NGINX_CONF_FILE="$( readlink -m "${DIR}/../templates/nginx.conf" )"
set +e

if [ -f "${DIR}/nginx/logs/nginx.pid" ]; then
  echo 'NGINX is already running'
  echo 'Stopping NGINX'
  "${DIR}/nginx/sbin/nginx" -s quit
fi
set -e

echo 'Starting NGINX server'
"${DIR}/nginx/sbin/nginx" -c "$NGINX_CONF_FILE"

set +e # Don't exit on error, so we can gracefully shutdown nginx
echo 'Executing wrk'
"${DIR}/wrk" "$@"
WRK_EXIT_CODE=$?

echo 'Stopping NGINX server'
"${DIR}/nginx/sbin/nginx" -s quit

exit $WRK_EXIT_CODE
