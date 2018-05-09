#!/bin/bash
set -x
DISTRO="$(awk -F= '/^ID=/{gsub(/"/,"",$2); print $2;}' /etc/os-release)"
HHVM_RPM_REPO_BASE_URL='http://mirrors.linuxeye.com/hhvm-repo/7/x86_64/'
HHVM_RPM='hhvm-3.15.3-1.el7.centos.x86_64.rpm'
PACKAGE_MANAGER='yum'
IFS='' read -r -d '' YUM_PACKAGES_DEPS <<EOF
  cmake psmisc binutils-devel boost-devel
  jemalloc-devel numactl-devel ImageMagick-devel sqlite-devel tbb-devel
  bzip2-devel openldap-devel readline-devel elfutils-libelf-devel gmp-devel
  lz4-devel pcre-devel libxslt-devel libevent-devel libyaml-devel
  libvpx-devel libpng-devel libzip-devel libicu-devel libmcrypt-devel
  libmemcached-devel libcap-devel libdwarf-devel unixODBC-devel expat-devel
  mariadb-devel libedit-devel libcurl-devel libxml2-devel libxslt-devel
  glog-devel oniguruma-devel ocaml gperf enca libjpeg-turbo-devel
  openssl-devel libc-client
EOF

if [[ "$EUID" -ne 0 ]]; then
   >&2 echo "This script must be run as root"
   exit 1
fi

for d in ${DISTRO}; do
  if [[ "$d" = "ubuntu" ]] || [[ "$d" = "debian" ]]; then
    PACKAGE_MANAGER='apt'
    break
  fi
done

command -v "${PACKAGE_MANAGER}" > /dev/null 2>&1
if [[ "$?" -ne 0 ]]; then
  >&2 echo "Could not find package manager '${PACKAGE_MANAGER}'"
  exit 1
fi

if [[ "${PACKAGE_MANAGER}" = "yum" ]]; then
  yum install -y ${YUM_PACKAGES_DEPS}
  rpm -U "${HHVM_RPM_REPO_BASE_URL}/${HHVM_RPM}"
  if [[ "$?" -ne 0 ]]; then
    >&2 echo "There was a problem installing HHVM RPM."
    exit 1
  fi
else
  apt update
  apt install -y 'hhvm'
  if [[ "$?" -ne 0 ]]; then
    >&2 echo "There was a problem installing HHVM."
    exit 1
  fi
fi
