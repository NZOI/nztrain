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
  # version temporarily locked to 7, because 8.0+ don't compile on Ubuntu 16.04 / gcc 5.4.0
  # TODO: once that issue is fixed, "--version ..." can be removed to switch back to "stable"
  bash "`dirname $0`/redis-installer.bash" --version 7.4.4
  result=$?

  if [[ "$result" -eq 0 ]] ; then
    service redis start
  fi

  exit $result
}
