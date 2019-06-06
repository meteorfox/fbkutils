#!/bin/bash

BENCHPRESS_ROOT="$(dirname "$(readlink -f "$0")")"
TEMPLATES_DIR="${BENCHPRESS_ROOT}/templates/django-workload"
HTTP_PROXY="fwdproxy:8080"
HTTPS_PROXY="fwdproxy:8080"

# 1. Clone Django workload repo
git -c http.proxy=$HTTP_PROXY -c https.proxy=$HTTPS_PROXY clone https://github.com/Instagram/django-workload

# 2. Install JDK
yum install -y fb-jdk-8.72

# 3. Configure env to use JDK as default Java env
# java
update-alternatives --install /usr/bin/java java /usr/local/fb-jdk-8.72/bin/java 3000000
update-alternatives --set java /usr/local/fb-jdk-8.72/bin/java
# javac
update-alternatives --install /usr/bin/javac javac /usr/local/fb-jdk-8.72/bin/javac 3000000
update-alternatives --set javac /usr/local/fb-jdk-8.72/bin/javac
# keytool
update-alternatives --install /usr/bin/keytool keytool /usr/local/fb-jdk-8.72/bin/keytool 3000000
update-alternatives --set keytool /usr/local/fb-jdk-8.72/bin/keytool

# 4. Install Cassandra
yum install -y apache-cassandra
cp "$TEMPLATES_DIR/cassandra" "/etc/default/cassandra" || exit
mv /etc/cassandra/conf/jvm-server.options /etc/cassandra/conf/jvm-server.options.bkp
cp "$TEMPLATES_DIR/jvm-server.options" "/etc/cassandra/conf/jvm-server.options" || exit
# Create data directories to use in configuring Cassandra
mkdir -p /data/cassandra/{commitlog,data,saved_caches,hints}/
chmod -R 0700 /data/cassandra
chown -R cassandra:cassandra /data/cassandra
# Configure and start Cassandra
cp "$TEMPLATES_DIR/cassandra.yaml" "/etc/cassandra/conf/cassandra.yaml" || exit
systemctl daemon-reload
systemctl stop cassandra
systemctl start cassandra

# 5. Install Django and its dependencies
cd "${BENCHPRESS_ROOT}/django-workload/django-workload" || exit
yum install -y memcached libmemecached-devel zlib-devel
# FB does not have RPMs with Python 3.5+, pip, virtualenv, so download remotely
export https_proxy=$HTTPS_PROXY
yum -y install https://centos7.iuscommunity.org/ius-release.rpm
export http_proxy=$HTTP_PROXY
yum -y install python36u python36u-pip python36u-devel
# Activate virtual env to run Python 3.6
python3.6 -m venv venv
# shellcheck source=venv/bin/activate
source venv/bin/activate # source /root/virtualenvs/benchpress_venv/bin/activate
pip install -r requirements.txt
# Configure Django and uWSGI
cp cluster_settings_template.py cluster_settings.py || exit
cp "${TEMPLATES_DIR}/cluster_settings.py" "${BENCHPRESS_ROOT}/django-workload/django-workload/cluster_settings.py" || exit
cp "${TEMPLATES_DIR}/uwsgi.ini" "${BENCHPRESS_ROOT}/django-workload/django-workload/uwsgi.ini" || exit
# Start memcached service
cd "${BENCHPRESS_ROOT}/django-workload/services/memcached/" || exit
./run-memcached &
cd "${BENCHPRESS_ROOT}/django-workload/django-workload/django_workload" || exit
git -c http.proxy=$HTTP_PROXY -c https.proxy=$HTTPS_PROXY apply templates/django-workload/0002-Memcache-Tuning.patch
# TODO: Do I include below 4 commands?
service cassandra start # Need to start cassandra before loading data from Django into it!
DJANGO_SETTINGS_MODULE=cluster_settings django-admin setup
cd "${BENCHPRESS_ROOT}/django-workload/django-workload" || exit
uwsgi uwsgi.ini &
# Run Siege load generator (FAILS if Siege is not already installed from install_oss_performance_mediawiki.sh)
unset http_proxy
unset https_proxy
yum install -y python34
yum install -y python34-numpy

: '
# 6. Run Django workload benchmark
# source /root/virtualenvs/benchpress_venv/bin/activate
cd ~/django-workload/client || exit
./gen-urls-file
WORKERS=144 DURATION=2M LOG=./siege.log SOURCE=urls.txt ./run-siege # TODO: Have these env vars customizable
'
