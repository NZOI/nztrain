#!/usr/bin/env bash
#
# Author:  Wayne E. Seguin <wayneeseguin@gmail.com>
# License: The same licence as Redis, New BSD
#          http://www.opensource.org/licenses/bsd-license.php
#
# Changes:
#   Author: Ronald Chan <ronalchn@gmail.com>
#     * Changed links to http://download.redis.io
#     * Automatically detect latest stable version
#     * Get init script the same directory
#     * requirepass a random password
#

default_redis_version=stable

# Emit usage information to the user.
usage() {
  printf "\n$0 [--version $default_redis_version] [--prefix /usr/local]\n"
}

#
# Parse any CLI arguments.
#
while true ; do
  case "$1" in
    -h|--help|-\?) usage               ; exit 0        ;;
    --verbose)     verbose=1           ; shift         ;;
    --trace)       set -x              ; shift         ;;
    # --pre)         version="2.0.0-rc4" ; shift         ;;
    --)            shift               ; break         ;;
    --version)     version=$2          ; shift ; shift ;;
    --prefix)      prefix=$2           ; shift ; shift ;;
    -*)            echo "invalid option: $1" 1>&2 ; usage ; exit 1;;
    *)             break                               ;;
  esac
done

#
# Configuration Defaults
#
package="redis"
version="${version:-"$default_redis_version"}"
archive_format="tar.gz"
timestamp=$(date +%m.%d.%YT%H:%M:%S)
result=0

# Alternate configuration based on root/user install.
if [[ "root"  = "$(whoami)" ]] ; then
  prefix="${prefix:-/usr/local}"
  redis_path="${redis_path:-"${prefix}/redis"}"
  bin_path="${bin_path:-"${prefix}/bin"}"
  config_path="${config_path:-"/etc/redis"}"
  log_path="${log_path:-"/var/log/redis"}"
  pid_path="${pid_path:-"/var/run/redis"}"
  data_path="${data_path:-"/var/data/redis"}"
  source_path="${source_path:-"$prefix/src"}"
  user="${user:-"redis"}"
  environment="${environment:-production}"
  init_d="${init_d:-"/etc/init.d"}"
  useradd -r ${user} 2>/dev/null # If the user already exists we don't want to hear about it.
else
  prefix="${prefix:-"$HOME"}"
  redis_path="${redis_path:-"${prefix}/.redis"}"
  bin_path="${bin_path:-"${prefix}/bin"}"
  config_path="${config_path:-"$prefix/.redis/config"}"
  log_path="${log_path:-"$prefix/.redis/log"}"
  pid_path="${pid_path:-"$prefix/.redis/run"}"
  data_path="${data_path:-"$prefix/.redis/data"}"
  source_path="${source_path:-"$prefix/.src"}"
  user="$(whoami)"
  environment="${environment:-development}"
  temlpate="user"
fi

appendfsync="${appendfsync:-everysec}"
port="${port:-6379}"
pidfile="${pidfile:-"redis.pid"}"
logfile="${logfile:-"redis.log"}"
dbfile="${dbfile:-"dump.rdb"}"
timeout="${timeout:-300}"
databases="${databases:-24}"
if [[ "production" = "${environment}" ]] || [[ "staging" = "${environment}" ]] ; then
  appendonly="${appendonly:-yes}"
  loglevel="${loglevel:-notice}"
  daemonize="${daemonize:-yes}"
else
  appendonly="${appendonly:-no}"
  loglevel="${loglevel:-debug}"
  daemonize="${daemonize:-yes}"
fi

if [[ "${version}" = "stable" ]]; then
  # sets REDIS_VERSION
  eval $(curl -L "http://download.redis.io/redis-stable/src/version.h" | grep -w REDIS_VERSION | sed 's/#define *REDIS_VERSION */REDIS_VERSION=/g')
  version="$REDIS_VERSION"
fi

config_template="${config_template:-"${source_path}/${package}-${version}/redis.conf"}"
current_dir=$(pwd)

#
# Ensure that redis related directories exist.
#
printf "\nCreating directories ${package} ${version} ...\n"
if [[ "$result" -eq 0 ]] ; then

  # Directories that must exist.
  for directory in "${redis_path}" "${config_path}" "${log_path}" "${pid_path}" "${data_path}" "${bin_path}" "${source_path}" ; do

    mkdir -p "${directory}"

  done

  # Directories that $user must own.
  for directory in "${redis_path}" "${config_path}" "${log_path}" "${pid_path}" "${data_path}" ; do

    chown -R "${user}" "${directory}"

  done


fi

# Switch to it to work out of the $source_path.
cd $source_path

#
# Fetch the Redis tarball
#
printf "\nDownloading  ${package}-${version}.${archive_format} ...\n"

curl -O -L "http://download.redis.io/releases/${package}-${version}.${archive_format}"

result=$? ; if [[ "$result" -gt 0 ]] ; then

  printf "\nERROR: ${package}-${version}.${archive_format} failed to download.\n"

  exit 1

fi

#
# Extract the Redis tarball
#
printf "\nExtracting ${package} ${version} ...\n"

tar zxf "${package}-${version}.${archive_format}"

result=$? ; if [[ "$result" -gt 0 ]] ; then

  printf "\nERROR: ${package}-${version}.${archive_format} failed to extract.\n"

  exit 1

fi

# Switch into the extracted redis source directory.
cd "${package}-${version}"

#
# Compile redis-server, redis-cli
#
printf "\nCompiling ${package} ${version} ...\n"

make

result=$? ; if [[ "$result" -gt 0 ]] ; then

  printf "\nERROR: ${package}-${version} failed to compile.\n"

  exit 1

fi

#
# Install redis-server, redis-cli to $prefix
#
printf "\nInstalling ${package} ${version} ...\n"

cp -f src/redis-server "${bin_path}/" && cp src/redis-cli "${bin_path}/"

result=$? ; if [[ "$result" -gt 0 ]] ; then

  printf "\nERROR: ${package}-${version} failed to install.\n"

  exit 1

fi

#
# Install start-stop script to $init_d (if it exists)
#
if [[ -d $init_d ]] ; then

  printf "\nInstalling start-stop script to ${init_d}\n"

  cp -f $current_dir/`dirname $0`/redis-init-script "${init_d}/redis"
  chmod +x "${init_d}/redis"

  if command -v update-rc.d > /dev/null ; then

    update-rc.d -f redis remove
    update-rc.d redis defaults

  elif command -v chkconfig > /dev/null ; then

    chkconfig redis on

  fi

  result=$? ; if [[ "$result" -gt 0 ]] ; then

    printf "\nERROR: could not install start-stop-script to system.\n"
    exit 1

  fi

fi

#
# Configure, if necessary.
#
if [[ ! -s "${config_path}/redis.conf" ]] ; then
pwd
echo $config_template
  if [[ -s "${config_template}" ]] ; then

    # Filter sample config file into actual config file using defaults/settings.
    sed -e 's#/var/run#'"${pid_path}"'#g'  \
        -e 's#^daemonize .*$#daemonize '"${daemonize}"'#g'  \
        -e 's#^port .*$#port '"${port}"'#g'  \
        -e 's#^appendfsync .*$#appendfsync '"${appendfsync}"'#g'  \
        -e 's#^timeout .*$#timeout '"${timeout}"'#g'  \
        -e 's#^databases .*$#databases '"${databases}"'#g'  \
        -e 's#^loglevel .*$#loglevel '"${loglevel}"'#g'  \
        -e 's#^appendonly .*$#appendonly '"${appendonly}"'#g'  \
        -e 's#^pidfile .*$#pidfile '"${pid_path}/${pidfile}"'#g'  \
        -e 's#^logfile .*$#logfile '"${log_path}/${logfile}"'#g'  \
        -e 's#^dbfilename .*$#dbfilename '"${dbfile}"'#g'\
        -e 's#^dir .*$#dir '"${data_path}/"'#g'\
        -e 's#^\# requirepass .*$#requirepass '"$(tr -cd '[:alnum:]' < /dev/urandom | fold -w64 | head -n1)"'#g'\
        "${config_template}" \
      > "${config_path}/redis.conf"

  else
    printf "\nERROR: could not configure redis.\n"
    exit 1
  fi

fi

exit $result
