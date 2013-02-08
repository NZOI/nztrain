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
  read -p "What username should be used to connect to the database (default=$USER)? " DATABASE_USERNAME
  if [[ ! $DATABASE_USERNAME ]] ; then DATABASE_USERNAME=$USER ; fi
done

shopt -u nocasematch;

if $anyset ; then
  export RAILS_ENV DATABASE TEST_DATABASE DATABASE_USERNAME

  # generate template
  bash script/template.bash < script/install.cfg.template > script/install.cfg

  echo "   script/install.cfg configuration file written"
fi

