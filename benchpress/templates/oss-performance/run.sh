#!/bin/bash
declare -r OLD_CWD="$( pwd )"

function show_help() {
cat <<EOF
Usage: ${0##*/} [-h] [-H db host] [-r hhvm path] [-n nginx path] [-s siege path] [-- extra_args]
Proxy shell script to executes oss-performance benchmark
    -h          display this help and exit
    -H          hostname or IP address to mariadb or mysql database
    -n          path to nginx binary (default: 'nginx')
    -r          path to hhvm binary (default: 'hhvm')
    -s          path to siege binary (default: 'siege')

Any other options that oss-performance perf.php script could accept can be
passed in as extra argunts appending two hyphens '--' followed by the
arguments. Example:

${0##*/} -- --mediawiki --siege-duration 10M --exec-after-benchmark time

EOF
}

# Check either mariadb or mysql is running
# Assuming systemd
# Note that if mariadb or mysql is not running or is not installed
# ActiveState will still show 'inactive'
function _systemd_service_status() {
  local service="$1"

  local status
  status="$(systemctl show mariadb | awk -F= '/ActiveState/{print $2}')"
  echo "$status"
}

function _check_local_db_running() {
  local mariadb_status
  mariadb_status="$(_systemd_service_status mariadb)"

  local mysql_status
  mysql_status="$(_systemd_service_status mysqld=)"

  if [[ "$mariadb_status" = "inactive" ]] || [[ "$mysql_status" = "inactive" ]]
  then
    >&2 echo "Make sure either 'mariadb' or 'mysql' is running."
    return 1
  fi
}

# Executes the oss-benchmark
# run_benchmark hhvm_path nginx_path siege_path [db_host]
function run_benchmark() {
  local _hhvm_path="$1"
  local _nginx_path="$2"
  local _siege_path="$3"
  local _db_host=""

  if [[ $# -eq 4 ]]; then
    _db_host="--db-host $4"
  fi
  cd "$( dirname "${BASH_SOURCE[0]}" )"
  "$_hhvm_path" perf.php \
    --nginx "$_nginx_path" \
    --siege "$_siege_path" \
    --hhvm "$_hhvm_path" \
    ${_db_host} \
    ${extra_args}
  cd "${OLD_CWD}"
}

function main() {
  local db_host
  db_host=""

  local hhvm_path
  hhvm_path='hhvm'

  local nginx_path
  nginx_path='nginx'

  local siege_path
  siege_path='siege'

  while getopts 'H:n:r:s:' OPTION "${@}"; do
    case "$OPTION" in
      H)
        db_host="${OPTARG}"
        ;;
      n)
        # Use readlink to get absolute path if relative is given
        nginx_path="${OPTARG}"
        if [[ "$nginx_path" != 'nginx' ]]; then
          nginx_path="$(readlink -f $nginx_path)"
        fi
        ;;
      r)
        hhvm_path="${OPTARG}"
        if [[ "$hhvm_path" != 'hhvm' ]]; then
          hhvm_path="$(readlink -f $hhvm_path)"
        fi
        ;;
      s)
        siege_path="${OPTARG}"
        if [[ "$siege_path" != 'siege' ]]; then
          siege_path="$(readlink -f $siege_path)"
        fi
        ;;
      ?)
        show_help >&2
        exit 1
        ;;
    esac
  done
  shift "$(($OPTIND -1))"

  # Extra arguments to pass to perf.php
  extra_args=$@

  readonly db_host
  readonly hhvm_path
  readonly nginx_path
  readonly siege_path

  if [[ "$db_host" = "" ]]; then
    _check_local_db_running || return
    run_benchmark ${hhvm_path} ${nginx_path} ${siege_path}
  else
    run_benchmark ${hhvm_path} ${nginx_path} ${siege_path} ${db_host}
  fi

  exit 0
}

trap "cd ${OLD_CWD}; exit 1" 1 2 3 13 15

main "$@"
