#!/usr/bin/env bash

min_version=1.9.2
ruby -v >/dev/null 2>&1 || { echo >&2 "Ruby is not installed, Ruby $min_version+ required!"; exit 1; }

version=`ruby -v | gawk 'match($0, /ruby ([0-9.p]+)/, ary) {print ary[1]}'`
larger=`echo -e "$version\n$min_version" | sort -V | tail -1`

if [[ $version != $larger ]] ; then
  echo "Ruby $min_version+ required!"
  exit 1
fi

