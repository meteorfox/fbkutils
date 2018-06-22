#!/bin/bash

GAP_GIT_REPO="https://github.com/sbeamer/gapbs.git"
GAP_GIT_TAG="tags/v1.1"

BENCHMARKS_DIR="$(pwd)/benchmarks/gapbs"
mkdir -p "$BENCHMARKS_DIR"

rm -rf build
mkdir -p build
cd build

git clone "$GAP_GIT_REPO"
cd gapbs
git checkout -b gapbs_benchpress "$GAP_GIT_TAG"
make

mv tc sssp pr converter cc bfs bc "$BENCHMARKS_DIR"
cd ../../
rm -rf build

echo "GAP benchmark suite installed into ${BENCHMARKS_DIR}"
