#!/usr/bin/env bash

lastupdate=`cat script/update.time` # get time of last update

lastmodified=`find Gemfile Gemfile.lock -printf '%T+\n' | sort -r | head -n1`
if [[ "$lastupdate" < "$lastmodified" ]] ; then
  # don't use sudo with bundler, it will ask for password if necessary
  # see https://bundler.io/man/bundle-install.1.html#SUDO-USAGE
  echo "$ bundle install"
  bundle install | sed -e 's/^/   /g;/Using/{:a;N;$!ba;s/Using [0-9a-z_ -]\+\(([0-9.]\+) \)\?\n//g}' | cat || exit 1
  # sed indents, remove output of un-upgraded gems
fi

