#!/usr/bin/env bash

minversion=2.6

if [[ "root" != "$(whoami)" ]] ; then
  echo Run this script as root >&2
  exit 1
fi

redis-server --version 2>/dev/null | bash script/extract_version.bash | bash script/check_version.bash $minversion || {
  # install script uses curl
  curl --version &> /dev/null || {
    cmd="sudo apt-get install curl"
    echo "$ $cmd"
    $cmd
  }

  # install script dependency
  apt-get install chkconfig

  # install redis
  bash "`dirname $0`/redis-installer.bash"
  result=$?

  if [[ "$result" -eq 0 ]] ; then
    service redis start
  fi

  exit $result
}
