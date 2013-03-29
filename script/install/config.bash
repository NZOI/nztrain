#!/usr/bin/env bash

cd `dirname $0`/../..

anyset=true
# read user options
for ARG in "$@"
do
    case $ARG in
    "--amend")
        if [[ -f script/install.cfg ]] ; then
	  source script/install.cfg
          anyset=false
	fi
        ;;
    --prompt=[a-zA-Z]*)
	unset `echo $ARG | sed 's/^--prompt=//g'`
	;;
    *)
        ;;
    esac
done

# generates a new install.cfg from the install.cfg.template, filling in the necessary variables from user prompts

shopt -s nocasematch;

if [ -z "$SERVER_NAME" ] ; then
  anyset=true
  read -p "What is the nginx server name (default=_)? " SERVER_NAME
  if [[ ! $SERVER_NAME ]] ; then SERVER_NAME=_ ; fi
fi

if [ -z "$APP_NAME" ] ; then
  anyset=true
  read -p "What is the application name (default=nztrain)? " APP_NAME
  if [[ ! $APP_NAME ]] ; then APP_NAME=nztrain ; fi
fi

if [ -z "$RAILS_ROOT" ] ; then
  anyset=true
  RAILS_ROOT=`pwd`
fi

while [ -z "$APP_USER" ] ; do
  anyset=true
  read -p "What username should the server run as (default=$USER)? " APP_USER
  if [[ ! $APP_USER ]] ; then APP_USER=$USER ; fi
done

while [ -z "$RAILS_ENV" ] ; do
  anyset=true
  read -p 'What environment is used to run this rails installation - d[evelopment] (default) or p[roduction]? ' RAILS_ENV
  if [[ development =~ ^$RAILS_ENV ]] ; then RAILS_ENV=development
  elif [[ production =~ ^$RAILS_ENV ]]; then RAILS_ENV=production
  else unset RAILS_ENV; fi
done

declare -p DATABASE &> /dev/null || while [[ -z "$DATABASE" ]] ; do
  anyset=true
  read -p 'What database should be used (default=nztrain)? ' DATABASE
  if [[ ! "$DATABASE" ]] ; then DATABASE=nztrain ; fi
  if [[ "$DATABASE" = "!" ]] ; then DATABASE=; break; fi
done

declare -p TEST_DATABASE &> /dev/null || while [ -z "$TEST_DATABASE" ] ; do
  anyset=true
  read -p 'What test database should be used (default=nztraintest)? ' TEST_DATABASE
  if [[ ! "$TEST_DATABASE" ]] ; then TEST_DATABASE=nztraintest ; fi
  if [[ "$TEST_DATABASE" = "!" ]] ; then TEST_DATABASE=; break; fi
done

while [ -z "$DATABASE_USERNAME" ] ; do
  anyset=true
  read -p "What username should be used to connect to the database (default=$APP_USER)? " DATABASE_USERNAME
  if [[ ! $DATABASE_USERNAME ]] ; then DATABASE_USERNAME=$APP_USER ; fi
done

declare -p UNICORN_PORT &> /dev/null || {
  anyset=true
  read -p 'What port should unicorn listen on (default=none)? ' UNICORN_PORT
}

shopt -u nocasematch;

if $anyset ; then
  export SERVER_NAME APP_NAME RAILS_ROOT APP_USER RAILS_ENV DATABASE TEST_DATABASE DATABASE_USERNAME UNICORN_PORT

  # generate template
  bash script/template.bash < script/install.cfg.template > script/install.cfg

  echo "   script/install.cfg configuration file written"
fi

