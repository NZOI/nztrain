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
    "--skip-pull")
        gitpull=false
        ;;
    *)
        ;;
    esac
done

# optional: mark website down (.htaccess url rewrite or other similar)

if ${gitpull:=true} ; then
  bash script/install/pull.bash
fi

bash script/install/bundle.bash # bundle install gems

# Stop WEBrick/Apache server here (only if database needs migration?)
bash script/install/migrate.bash # migrate database
bash script/install/whenever.bash # setup cronjobs

# if in production mode
if [[ $RAILS_ENV = production ]] ; then
  bash script/install/assets.bash # precompile assets
fi

# Start WEBrick/Apache server here

# If using Phusion Passenger, touch tmp/restart.txt can restart Rails


