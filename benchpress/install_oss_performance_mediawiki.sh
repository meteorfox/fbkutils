#!/bin/bash

# set -e

BENCHPRESS_ROOT="$(dirname "$(readlink -f "$0")")"
TEMPLATES_DIR="${BENCHPRESS_ROOT}/templates/oss-performance-mediawiki"
HHVM="/usr/local/hphpi/legacy/bin/hhvm"
MARIADB_PWD="password"
HTTP_PROXY="fwdproxy:8080"
HTTPS_PROXY="fwdproxy:8080"

# 1. Install prerequisite packages
yum install -y git devtoolset-7-toolchain autoconf automake libevent-devel php-cli zlib-devel php-json

# 2. Install hhvm package
yum install -y fb-hphpi-legacy

# 3. Install nginx
yum install -y nginx
systemctl stop nginx

# 4. Install mariadb
cp "${TEMPLATES_DIR}/MariaDB.repo" "/etc/yum.repos.d/MariaDB.repo" || exit
yum remove -y fb-mysql-libs-universal
yum install -y mariadb-server
systemctl start mariadb
mysql_secure_installation <<EOF
Y
$MARIADB_PWD
$MARIADB_PWD
n
n
n
Y
EOF

mysql -u root --password=$MARIADB_PWD < "${TEMPLATES_DIR}/grant_privileges.sql"


# 5. Install Siege
git -c http.proxy=$HTTP_PROXY -c https.proxy=$HTTPS_PROXY clone https://github.com/JoeDog/siege.git
cd siege || exit
git -c http.proxy=$HTTP_PROXY -c https.proxy=$HTTPS_PROXY checkout tags/v4.0.3rc3
./utils/bootstrap
automake --add-missing
./configure
make -j8
sudo make uninstall
sudo make install
cd ..

# 6. Install memcache
http_proxy=$HTTP_PROXY https_proxy=$HTTPS_PROXY wget http://www.memcached.org/files/memcached-1.5.12.tar.gz
tar -xzf memcached-1.5.12.tar.gz
cd memcached-1.5.12 || exit
./configure --prefix=/usr/local/memcached
make -j8
make install
cd ..

# 7. Installing OSS-performance
git -c http.proxy=$HTTP_PROXY -c https.proxy=$HTTPS_PROXY clone https://github.com/hhvm/oss-performance.git
cd oss-performance || exit
git -c http.proxy=$HTTP_PROXY -c https.proxy=$HTTPS_PROXY fetch origin pull/87/head:memcached
git -c http.proxy=$HTTP_PROXY -c https.proxy=$HTTPS_PROXY checkout memcached
git -c http.proxy=$HTTP_PROXY -c https.proxy=$HTTPS_PROXY merge origin
http_proxy=$HTTP_PROXY https_proxy=$HTTPS_PROXY wget https://getcomposer.org/installer
mv installer composer-setup.php
http_proxy=$HTTP_PROXY https_proxy=$HTTPS_PROXY php composer-setup.php
http_proxy=$HTTP_PROXY https_proxy=$HTTPS_PROXY wget https://gist.githubusercontent.com/meteorfox/37350cc0e2954e5a7696a073931c9ae7/raw/301521947262bf7a66e8673caeeea57aadbcceb8/0000-Allow-to-run-as-root.patch
git -c http.proxy=$HTTP_PROXY -c https.proxy=$HTTPS_PROXY apply 0000-Allow-to-run-as-root.patch
$HHVM composer.phar install

# 8. Basic tuning
echo 1 | sudo tee /proc/sys/net/ipv4/tcp_tw_reuse

# 9. MariaDB tuning
cp "${TEMPLATES_DIR}/my.cnf" "/etc/my.cnf"
systemctl restart mariadb

# 10. Nginx and Mediawiki tuning
git -c http.proxy=$HTTP_PROXY -c https.proxy=$HTTPS_PROXY apply "${TEMPLATES_DIR}/0001-Nginx-Mediawiki-Tuning.patch" # Applies patch to change files to desired tuning

# 11. Run benchmark
$HHVM perf.php \
        --mediawiki \
        --memcached=/usr/local/memcached/bin/memcached \
        --memcached-threads=8 \
        --hhvm=$HHVM \
        --client-threads 200 \
        --server-threads 100
