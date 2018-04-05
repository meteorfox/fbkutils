#!/bin/bash
set -e
set -x

WRK_GIT_REPO="https://github.com/wg/wrk.git"
WRK_GIT_COMMIT="7594a95186ebdfa7cb35477a8a811f84e2a31b62"
WRK_GIT_RELEASE_TAG="4.1.0"

BENCHMARKS_DIR="$(pwd)/benchmarks"
mkdir -p "$BENCHMARKS_DIR"

rm -rf build
mkdir -p build
cd build

git clone "$WRK_GIT_REPO" wrk
cd wrk

git checkout -b "$WRK_GIT_RELEASE_TAG" "$WRK_GIT_COMMIT"

make
mv wrk "$BENCHMARKS_DIR"

cd ../../
rm -rf build

echo "wrk installed into ${BENCHMARKS_DIR}"
