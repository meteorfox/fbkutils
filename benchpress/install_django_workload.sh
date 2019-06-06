#!/bin/bash

BENCHPRESS_ROOT="$(dirname "$(readlink -f "$0")")"
TEMPLATES_DIR="${BENCHPRESS_ROOT}/templates/django-workload"
HTTP_PROXY="fwdproxy:8080"
HTTPS_PROXY="fwdproxy:8080"

# 1. Clone Django workload repo
yum install -y git
git -c http.proxy=$HTTP_PROXY -c https.proxy=$HTTPS_PROXY clone https://github.com/Instagram/django-workload # Assumes git is installed

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

# 1) wget new cassandra pkg
# 2) unpack
# 3) cd into django-workload/apache-cassandra-3.11.4/conf
# 4) modify cassandra.yaml and jvm.options (cmd remains same except for destination of cp)
# 5) create data directories and apply permisions (cmd remains same)
# 6) cd .. && bin/cassandra -R -p cassandra.pid (starts cassandra)
# 7) cd django-workload/django-workload && source venv/bin/activate && DJANGO_SETTINGS_MODULE=cluster_settings django-admin setup

# To kill cassandra server at end:
# 1) cd into django-workload/apache-cassandra-3.11.4
# 2) kill `cat cassandra.pid`
# pgrep java to ensure that it's no longer running

# Download Cassandra from third-party source
https_proxy=$HTTPS_PROXY http_proxy=$HTTP_PROXY wget https://www-us.apache.org/dist/cassandra/3.11.4/apache-cassandra-3.11.4-bin.tar.gz
tar -xzvf apache-cassandra-3.11.4-bin.tar.gz
cd apache-cassandra-3.11.4 || exit
mv conf/jvm.options conf/jvm.options.bkp || exit
cp "${TEMPLATES_DIR}/jvm.options" "${BENCHPRESS_ROOT}/apache-cassandra-3.11.4/conf/jvm.options" || exit
# Create data directories to use in configuring Cassandra
mkdir -p /data/cassandra/{commitlog,data,saved_caches,hints}/
chmod -R 0700 /data/cassandra
# Configure and start Cassandra
cp "${TEMPLATES_DIR}/cassandra.yaml" "${BENCHPRESS_ROOT}/apache-cassandra-3.11.4/conf/cassandra.yaml" || exit
bin/cassandra -R -p cassandra.pid 2>&1 > cassandra.log

# 5. Install Django and its dependencies
cd "${BENCHPRESS_ROOT}/django-workload/django-workload" || exit
yum install -y memcached libmemcached-devel zlib-devel
yum install -y python36 python36-devel python36-numpy
# Activate virtual env to run Python 3.6
python3.6 -m venv venv
# shellcheck source=venv/bin/activate
source venv/bin/activate
https_proxy=$HTTPS_PROXY http_proxy=$HTTP_PROXY pip install -r requirements.txt
# Configure Django and uWSGI
cp cluster_settings_template.py cluster_settings.py || exit
cp "${TEMPLATES_DIR}/cluster_settings.py" "${BENCHPRESS_ROOT}/django-workload/django-workload/cluster_settings.py" || exit
cp "${TEMPLATES_DIR}/uwsgi.ini" "${BENCHPRESS_ROOT}/django-workload/django-workload/uwsgi.ini" || exit
# Start memcached service
cd "${BENCHPRESS_ROOT}/django-workload/services/memcached/" || exit
./run-memcached &
cd "${BENCHPRESS_ROOT}/django-workload/django-workload/django_workload" || exit
git -c http.proxy=$HTTP_PROXY -c https.proxy=$HTTPS_PROXY apply "${TEMPLATES_DIR}/0002-Memcache-Tuning.patch"
DJANGO_SETTINGS_MODULE=cluster_settings django-admin setup
cd "${BENCHPRESS_ROOT}/django-workload/django-workload" || exit
uwsgi uwsgi.ini &
deactivate
# Run Siege load generator (FAILS if Siege is not already installed from install_oss_performance_mediawiki.sh)
# 6. Run Django workload benchmark
cd "${BENCHPRESS_ROOT}/django-workload/client" || exit
./gen-urls-file
WORKERS=144 DURATION=2M LOG=./siege.log SOURCE=urls.txt ./run-siege # TODO: Have these env vars customizable
# Kill Cassandra process (cleanup)
cd "${BENCHPRESS_ROOT}/apache-cassandra-3.11.4"
kill `cat cassandra.pid`
# TODO: Kill memcache and uwsgi (do some cleanup)
