#!/bin/bash
#
# Installs HHVM's oss-performance under benchmarks/
#

HHVM_PATH=${HHVM_PATH:-'hhvm'}

read -d '' HHVM_NOT_FOUND_MSG <<END
Could not find \'$HHVM_PATH\' executable in PATH or HHVM_PATH env variable.

Please make sure 'hhvm' executable is installed or path is set
correctly in HHVM_PATH.
END

command -v "$HHVM_PATH" >/dev/null 2>&1 || {
    >&2 echo "$HHVM_NOT_FOUND_MSG"
    exit 1
}

DEFAULT_OSS_GIT_HASH='aa38192b47443fcf968a390fff23d1b2aa6930de'
BENCHPRESS_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OSS_PERFORMANCE_GIT_REPO='https://github.com/hhvm/oss-performance.git'
OSS_PERFORMANCE_GIT_COMMIT=${OSS_PERFORMANCE_GIT_HASH:-$DEFAULT_OSS_GIT_HASH}
# Clones repo without changes requiring hhvm 3.24 or higher
# Can be overriden by setting OSS_PERFORMANCE_GIT_HASH env variable

TEMPLATES_DIR="${BENCHPRESS_ROOT}/templates"
BENCHMARKS_DIR="${BENCHPRESS_ROOT}/benchmarks"
mkdir -p "$BENCHMARKS_DIR"

rm -rf build/
mkdir -p build/
cd build/

git clone "$OSS_PERFORMANCE_GIT_REPO"
cd  oss-performance/
git checkout --quiet "$OSS_PERFORMANCE_GIT_COMMIT"

git apply --check "${TEMPLATES_DIR}"/oss-performance/*.patch || {
  >&2 echo "Could not apply patches in ${TEMPLATES_DIR}/oss-performance/*.patch"
  exit 1
}
git apply "${TEMPLATES_DIR}"/oss-performance/*.patch

EXPECTED_SIGNATURE="$( wget -q -O - https://composer.github.io/installer.sig )"
wget -q -O - 'https://getcomposer.org/installer' > 'composer-setup.php'
ACTUAL_SIGNATURE="$( sha384sum 'composer-setup.php' | awk '{print $1;}' )"

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    >&2 echo 'ERROR: Invalid composer-setup.php installer signature'
    rm composer-setup.php
    exit 1
fi

set -e
set -x
"$HHVM_PATH" composer-setup.php --quiet
rm composer-setup.php

"$HHVM_PATH" composer.phar install

cd ../
cp -r oss-performance/ "${BENCHPRESS_ROOT}"/benchmarks/
cp "${TEMPLATES_DIR}/oss-performance/run.sh" \
   "${BENCHPRESS_ROOT}/benchmarks/oss-performance/"
chmod u+x "${BENCHPRESS_ROOT}/benchmarks/oss-performance/run.sh"

cd "${BENCHPRESS_ROOT}"/
rm -rf build/

echo "Installed oss-performance into ${BENCHMARKS_DIR}/oss-performance"
echo ''
cat <<END
In some situations, the kernel can infer that it is safe to re-use a socket that
is in TIME_WAIT. This can be enabled through /proc:

    echo 1 | sudo tee /proc/sys/net/ipv4/tcp_tw_reuse
END
