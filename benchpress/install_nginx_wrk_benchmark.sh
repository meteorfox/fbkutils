#!/bin/bash
set -e
set -x

BENCHMARKS_DIR="$(pwd)/benchmarks"
mkdir -p "$BENCHMARKS_DIR"

./install_wrk.sh
./install_nginx.sh

cp templates/nginx_wrk_bench.sh "${BENCHMARKS_DIR}/"
chmod u+x "${BENCHMARKS_DIR}/nginx_wrk_bench.sh"

echo "nginx_wrk installed into $BENCHMARKS_DIR"
