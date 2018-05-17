#!/bin/bash
set -e
set -x

NGINX_VERSION='nginx-1.12.2'
NGINX_TAR_FILE="${NGINX_VERSION}.tar.gz"
NGINX_DOWNLOAD_URL="http://nginx.org/download/${NGINX_TAR_FILE}"

PCRE_VERSION='pcre-8.41'
PCRE_TAR_FILE="${PCRE_VERSION}.tar.gz"
PCRE_DOWNLOAD_URL="https://downloads.sourceforge.net/project/pcre/pcre/8.41/${PCRE_TAR_FILE}"

ZLIB_VERSION='zlib-1.2.11'
ZLIB_TAR_FILE="${ZLIB_VERSION}.tar.gz"
ZLIB_DOWNLOAD_URL="http://zlib.net/${ZLIB_TAR_FILE}"

BENCHMARKS_DIR="$(pwd)/benchmarks"
mkdir -p "$BENCHMARKS_DIR"

NGINX_INSTALLATION_PREFIX="${BENCHMARKS_DIR}/nginx"
NGINX_BINARY_PATH="${NGINX_INSTALLATION_PREFIX}/sbin/nginx"

if [[ -f "$NGINX_BINARY_PATH" && -x "$NGINX_BINARY_PATH" ]]; then
  echo "NGINX already insalled into ${NGINX_INSTALLATION_PREFIX}"
  exit 0
fi

rm -rf build
mkdir -p build
cd build

echo 'Installing NGINX dependencies'

#PCRE
wget "${PCRE_DOWNLOAD_URL}"
tar -zxvf "$PCRE_TAR_FILE"
cd "$PCRE_VERSION"
./configure
make -j4
cd ../

#zlib
wget "${ZLIB_DOWNLOAD_URL}"
tar -zxvf "$ZLIB_TAR_FILE"
cd "$ZLIB_VERSION"
./configure
make -j4
cd ../

echo 'Done installing NGINX dependencies'
echo 'Installing NGINX'
#NGINX
wget "${NGINX_DOWNLOAD_URL}"
tar -xzvf "$NGINX_TAR_FILE"

cd "$NGINX_VERSION"
./configure \
    --prefix="${NGINX_INSTALLATION_PREFIX}" \
    --with-pcre="../${PCRE_VERSION}" \
    --with-zlib="../${ZLIB_VERSION}" \
    --with-http_ssl_module

make -j4
make install

cd ../../
rm -rf build

echo "NGINX installed into ${BENCHMARKS_DIR}"
