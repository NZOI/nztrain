#!/usr/bin/env bash

sdo=sudo
rvm --version &>/dev/null && {
  if [[ `rvm current` != "system" ]] ; then
    sdo=
  fi
}

lastupdate=`cat script/update.time` # get time of last update

lastmodified=`find Gemfile Gemfile.lock -printf '%T+\n' | sort -r | head -n1`
if [[ "$lastupdate" < "$lastmodified" ]] ; then
  echo "$ ${sdo}bundle install"
  ${sdo}bundle install | sed -e 's/^/   /g;/Using/{:a;N;$!ba;s/Using [0-9a-z_ -]\+\(([0-9.]\+) \)\?\n//g}' | cat || exit 1
fi

