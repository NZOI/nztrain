#!/usr/bin/env bash

cd `dirname $0`/..

if [ ! -f script/install.cfg ] ; then 
  echo To continue, you need to set some configuration settings...
  bash script/install/config.bash
fi
source script/install.cfg

# process script options
for ARG in "$@"
do
    case $ARG in
    "--skip-update")
        update=false
        ;;
    *)
        ;;
    esac
done

bash script/install/ruby.bash || exit 1 # check ruby version

# TODO: create db if it doesn't exist (and prompt for db details to create, or option to change details)

bash script/install/imagemagick.bash # install imagemagick

bash script/install/nztrain.bash # fix files & directory structure

if ${update:=true} ; then
  # stuff that update needs to do as well
  bash script/install/bundle.bash # bundle install gems

  bash script/install/migrate.bash # migrate database
  bash script/install/whenever.bash # setup cronjobs

  # if in production mode
  if [[ $RAILS_ENV = production ]] ; then
    bash script/install/assets.bash # precompile assets
  fi
fi


