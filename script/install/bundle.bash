#!/usr/bin/env bash

sdo=sudo
rvm --version &>/dev/null && {
  if [[ `rvm current` != "system" ]] ; then
    sdo=
  fi
}
echo "$ ${sdo}bundle install"
${sdo}bundle install | sed -e 's/^/   /g;/Using/{:a;N;$!ba;s/Using [0-9a-z_ -]\+\(([0-9.]\+) \)\?\n//g}' | cat || exit 1

