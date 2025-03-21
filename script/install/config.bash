#!/usr/bin/env bash

cd `dirname $0`/../..

anyset=true
# read user options
for ARG in "$@"
do
    case $ARG in
    "--defaults")
        DEFAULTS=true
        ;;
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

prompt() {
  if [[ ! "$DEFAULTS" = true ]] ; then
    read -p "$1" $2
  fi
}

if [ -z "$SERVER_NAME" ] ; then
  anyset=true
  prompt "What is the nginx server name (default=_)? " SERVER_NAME
  if [[ ! $SERVER_NAME ]] ; then SERVER_NAME=_ ; fi
fi

if [ -z "$APP_NAME" ] ; then
  anyset=true
  prompt "What is the application name (default=nztrain)? " APP_NAME
  if [[ ! $APP_NAME ]] ; then APP_NAME=nztrain ; fi
fi

if [ -z "$RAILS_ROOT" ] ; then
  anyset=true
  RAILS_ROOT=`pwd`
fi

while [ -z "$APP_USER" ] ; do
  anyset=true
  prompt "What username will the server run as (default=$USER)? " APP_USER
  if [[ ! $APP_USER ]] ; then APP_USER=$USER ; fi
done

default_app_group="$(id -gn "$APP_USER")"
while [ -z "$APP_GROUP" ] ; do
  anyset=true
  prompt "What group will the server run as (default=$default_app_group)? " APP_GROUP
  if [[ ! $APP_GROUP ]] ; then APP_GROUP=$default_app_group ; fi
done

while [ -z "$RAILS_ENV" ] ; do
  anyset=true
  prompt 'What environment is used to run this rails installation - d[evelopment] (default), p[roduction] or t[est]? ' RAILS_ENV
  if [[ "development" =~ ^$RAILS_ENV ]] ; then RAILS_ENV=development
  elif [[ "production" =~ ^$RAILS_ENV ]]; then RAILS_ENV=production
  elif [[ "test" =~ ^$RAILS_ENV ]]; then RAILS_ENV=test
  else unset RAILS_ENV; fi
done

declare -p UNICORN_PORT &> /dev/null || {
  anyset=true
  prompt 'What port should unicorn listen on (default=none)? ' UNICORN_PORT
}

declare -p DATABASE &> /dev/null || while [[ -z "$DATABASE" ]] ; do
  anyset=true
  prompt 'What database should be used (default=nztrain)? ' DATABASE
  if [[ ! "$DATABASE" ]] ; then DATABASE=nztrain ; fi
  if [[ "$DATABASE" = "!" ]] ; then DATABASE=; break; fi
done

declare -p TEST_DATABASE &> /dev/null || while [ -z "$TEST_DATABASE" ] ; do
  anyset=true
  prompt 'What test database should be used (default=nztraintest)? ' TEST_DATABASE
  if [[ ! "$TEST_DATABASE" ]] ; then TEST_DATABASE=nztraintest ; fi
  if [[ "$TEST_DATABASE" = "!" ]] ; then TEST_DATABASE=; break; fi
done

while [ -z "$DATABASE_USERNAME" ] ; do
  anyset=true
  prompt "What username should be used to connect to the database (default=$APP_USER)? " DATABASE_USERNAME
  if [[ ! $DATABASE_USERNAME ]] ; then DATABASE_USERNAME=$APP_USER ; fi
done

declare -p REDIS_HOST &> /dev/null || while [[ -z "$REDIS_HOST" ]] ; do
  anyset=true
  prompt 'What is the hostname for Redis (default=localhost)? ' REDIS_HOST
  if [[ ! "$REDIS_HOST" ]] ; then REDIS_HOST=localhost ; fi
done

declare -p REDIS_PORT &> /dev/null || while [[ -z "$REDIS_PORT" ]] ; do
  anyset=true
  prompt 'What is the Redis port (default=6379)? ' REDIS_PORT
  if [[ ! "$REDIS_PORT" ]] ; then REDIS_PORT=6379 ; fi
done

declare -p REDIS_PASS &> /dev/null || while [[ -z "$REDIS_PASS" ]] ; do
  anyset=true
  prompt 'What is the Redis password (@ to read from a configuration file default=@/etc/redis/redis.conf)? ' REDIS_PASS
  if [[ ! "$REDIS_PASS" ]] ; then REDIS_PASS="@/etc/redis/redis.conf" ; fi
  if [[ "$REDIS_PASS" = "!" ]] ; then REDIS_PASS=; break; fi
done

declare -p REDIS_INSTALL &> /dev/null || {
  anyset=true
  if [[ "$REDIS_HOST" = "localhost" ]]; then
    REDIS_INSTALL="true"
  else
    REDIS_INSTALL="false"
  fi
}

declare -p SCHEDULE_BACKUPS &> /dev/null || {
  anyset=true
  DEFAULT=1 bash script/confirm.bash 'Schedule backups' && SCHEDULE_BACKUPS=1 || SCHEDULE_BACKUPS=0
}

if [[ "$SCHEDULE_BACKUPS" = "1" ]] ; then
  declare -p BACKUP_RSYNC &> /dev/null || {
    anyset=true
    DEFAULT=1 bash script/confirm.bash 'Backup using rsync' && BACKUP_RSYNC=1 || BACKUP_RSYNC=0
  }
  if [[ "$BACKUP_RSYNC" = "1" ]] ; then
    declare -p BACKUP_RSYNC_MODE &> /dev/null || {
      anyset=true
      prompt 'Backups: What mode should rsync operate in (default=ssh, or ssh_daemon, rsync_daemon)? ' BACKUP_RSYNC_MODE
      if [[ ! $BACKUP_RSYNC_MODE ]] ; then BACKUP_RSYNC_MODE=ssh ; fi
    }
    declare -p BACKUP_RSYNC_PORT &> /dev/null || {
      anyset=true
      prompt 'Backups: What port to use for rsync (default=22)? ' BACKUP_RSYNC_PORT
      if [[ ! $BACKUP_RSYNC_PORT ]] ; then BACKUP_RSYNC_PORT=22 ; fi
    }
    declare -p BACKUP_RSYNC_HOST &> /dev/null || {
      anyset=true
      prompt 'Backups: What is the host for rsync? ' BACKUP_RSYNC_HOST
    }
    declare -p BACKUP_RSYNC_USER &> /dev/null || {
      anyset=true
      prompt 'Backups: What is the username for rsync? ' BACKUP_RSYNC_USER
    }
    declare -p BACKUP_RSYNC_PASS &> /dev/null || {
      anyset=true
      prompt 'Backups: What is the password for rsync? ' BACKUP_RSYNC_PASS
    }
    declare -p BACKUP_RSYNC_SSH_KEY &> /dev/null || {
      anyset=true
      prompt 'Backups: What is the path to the ssh key (optional)? ' BACKUP_RSYNC_SSH_KEY
      if [[ ! $BACKUP_RSYNC_SSH_KEY ]] ; then BACKUP_RSYNC_SSH_KEY="~/.ssh/id_rsa" ; fi
    }
    declare -p BACKUP_RSYNC_PATH &> /dev/null || {
      anyset=true
      prompt 'Backups: What path to rsync to (default=~/backups)? ' BACKUP_RSYNC_PATH
      if [[ ! $BACKUP_RSYNC_PATH ]] ; then BACKUP_RSYNC_PATH="~/backups" ; fi
    }
  else
    BACKUP_RSYNC_MODE=ssh
    BACKUP_RSYNC_PORT=22
    BACKUP_RSYNC_HOST=
    BACKUP_RSYNC_USER=
    BACKUP_RSYNC_PASS=
    BACKUP_RSYNC_SSH_KEY="~/.ssh/id_rsa"
    BACKUP_RSYNC_PATH="~/backups"
  fi
else
  BACKUP_RSYNC=0
fi

if [ -z "$ISOLATE_ROOT" ] ; then
  anyset=true
  isolate_root_default=/
  if [[ $RAILS_ENV = "production" ]] ; then
    isolate_root_default=/srv/chroot/nztrain
  fi
  echo "What is root linux installation for programs run in the isolate sandbox?"
  echo "Recommendation: '/' for development, '/srv/chroot/nztrain' for production)"
  echo "Note: a path other than '/' installs a chrooted ubuntu via debootstrap"
  prompt "Path to isolate root (default=$isolate_root_default): " ISOLATE_ROOT
  if [[ ! $ISOLATE_ROOT ]] ; then ISOLATE_ROOT=$isolate_root_default ; fi
fi

declare -p ISOLATE_CGROUPS &> /dev/null || while [ -z "$ISOLATE_CGROUPS" ] ; do
  anyset=true
  prompt 'Install control groups for isolate? [Y/n]' ISOLATE_CGROUPS
  shopt -s nocasematch;
  if [[ yes =~ ^$ISOLATE_CGROUPS ]] ; then ISOLATE_CGROUPS=true
  else ISOLATE_CGROUPS=false; fi
done

declare -p ISOLATE_BRANCH &> /dev/null || ISOLATE_BRANCH=v1.10.1 # no prompt


shopt -u nocasematch;

if $anyset ; then
  export SERVER_NAME APP_NAME RAILS_ROOT APP_USER APP_GROUP RAILS_ENV UNICORN_PORT
  export DATABASE TEST_DATABASE DATABASE_USERNAME
  export REDIS_HOST REDIS_PORT REDIS_PASS REDIS_INSTALL
  export SCHEDULE_BACKUPS BACKUP_RSYNC BACKUP_RSYNC_MODE BACKUP_RSYNC_PORT BACKUP_RSYNC_HOST BACKUP_RSYNC_USER BACKUP_RSYNC_PASS BACKUP_RSYNC_SSH_KEY BACKUP_RSYNC_PATH
  export ISOLATE_ROOT ISOLATE_CGROUPS ISOLATE_BRANCH

  # generate template
  bash script/template.bash < script/install.cfg.template > script/install.cfg

  echo "   script/install.cfg configuration file written"
fi

