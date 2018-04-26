#!/bin/bash
set -e
set -x

NU_MINEBENCH_VERSION='NU-MineBench-3.0.1'
NU_MINEBENCH_TAR_FILE="${NU_MINEBENCH_VERSION}.tar.gz"
NU_MINEBENCH_DOWNLOAD_URL="http://cucis.ece.northwestern.edu/projects/DMS"

KMEANS_DATASET_TAR_FILE="kmeans.tar.gz"
PLSA_DATASET_TAR_FILE="PLSA.tar.gz"
RSEARCH_DATASET_TAR_FILE="rsearch.tar.gz"
NU_MINEBENCH_DATASETS="${KMEANS_DATASET_TAR_FILE} ${PLSA_DATASET_TAR_FILE} ${RSEARCH_DATASET_TAR_FILE}"

BENCHMARKS_DIR="$(pwd)/benchmarks"
mkdir -p "${BENCHMARKS_DIR}"
mkdir -p "${BENCHMARKS_DIR}/minebench"
mkdir -p "${BENCHMARKS_DIR}/minebench/datasets"



echo 'Downloading NU-MineBench and its datasets'
cd "${BENCHMARKS_DIR}/minebench/datasets/"
for dataset in $NU_MINEBENCH_DATASETS; do
  wget "${NU_MINEBENCH_DOWNLOAD_URL}/DATASETS/$dataset"
  tar -zxvf $dataset
done
cd "${BENCHMARKS_DIR}/.."

cp templates/time_wrap.sh "${BENCHMARKS_DIR}/minebench/"
chmod u+x "${BENCHMARKS_DIR}/minebench/time_wrap.sh"

rm -rf build
mkdir -p build
cd build

wget "${NU_MINEBENCH_DOWNLOAD_URL}/${NU_MINEBENCH_TAR_FILE}"
tar -xzvf "${NU_MINEBENCH_TAR_FILE}"
cd "$NU_MINEBENCH_VERSION"



echo 'Compiling and Installing KMeans'
cd 'KMeans/'
make OPTFLAGS="-O3" example
cp 'example' "${BENCHMARKS_DIR}/minebench/kmeans"
cd ../
echo 'Done installing KMeans'

echo 'Compiling and Installing PLSA'
cd 'PLSA/'
make COMPILEOPTION='-g -Wno-write-strings -fopenmp -O3' -f Makefile.omp
cp 'parasw.mt' "${BENCHMARKS_DIR}/minebench/plsa"
cd ../
echo 'Done installing PLSA'

echo 'Compiling and Installing RSearch'
cd 'RSEARCH/'
./configure --prefix="${BENCHMARKS_DIR}/minebench/rsearch"
make CFLAGS="-O3 -fopenmp"
make install
cd ../
echo 'Done installing RSearch'

cd ../../

rm -rf build/

echo "NU-MineBench installed into ${BENCHMARKS_DIR}/minebench"
