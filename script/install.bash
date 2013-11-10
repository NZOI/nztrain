#!/usr/bin/env bash

cd `dirname $0`/..

if [ ! -f script/install.cfg ] ; then 
  echo To continue, you need to set some configuration settings...
  bash script/install/config.bash || exit 1
else
  bash script/install/config.bash --amend # in case there are new settings
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

bash script/install/postgresql.bash || exit 1 # create user & db if it doesn't exist

bash script/install/imagemagick.bash || exit 1 # install imagemagick

bash script/install/nztrain.bash || exit 1 # fix files & directory structure

bash script/install/bundler.bash || exit 1

bash script/install/nokogiri.bash || exit 1 # nokogiri dependencies

bash script/install/jdk.bash || exit 1 # required by yui-compressor

sudo bash script/install/isolate.bash || exit 1 # install isolate

if ${update:=true} ; then
  # stuff that update needs to do as well
  bash script/install/bundle.bash || exit 1 # bundle install gems

  bash script/install/migrate.bash || exit 1 # migrate database
  bash script/install/whenever.bash || exit 1 # setup cronjobs

  # if in production mode
  if [[ $RAILS_ENV = production ]] ; then
    bash script/install/assets.bash # precompile assets
  fi
fi


