#!/usr/bin/env bash

lastupdate=`cat script/update.time` # get time of last update

lastmodified=`find Gemfile Gemfile.lock -printf '%T+\n' | sort -r | head -n1`
if [[ "$lastupdate" < "$lastmodified" ]] ; then
  # don't use sudo with bundler, it will ask for password if necessary
  # see https://bundler.io/man/bundle-install.1.html#SUDO-USAGE
  echo "$ bundle install"
  bundle install || exit 1
fi

