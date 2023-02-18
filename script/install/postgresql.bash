#!/usr/bin/env bash

cd `dirname $0`/../..

source script/install.cfg

min_version=8

psql --version 2>/dev/null | bash script/extract_version.bash | bash script/check_version.bash $min_version || {
  echo PostgreSQL $min_version+ required!
  bash script/confirm.bash 'Install PostgreSQL' && {

    # version 12 breaks compatibility with rails < 4.2.5
    # https://stackoverflow.com/questions/58763542/pginvalidparametervalue-error-invalid-value-for-parameter-client-min-messag
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo apt-get update

    cmd="sudo apt-get install postgresql-11"
    echo "$ $cmd"
    $cmd
  } || exit 1

}

# required by pg gem
cmd="sudo apt-get install libpq-dev"
echo "$ $cmd"
$cmd || exit 1

# setup user if required
psql -U$DATABASE_USERNAME postgres -c '' &> /dev/null || {
  bash script/confirm.bash "Create new PostgreSQL user $DATABASE_USERNAME" && {
    cmd="sudo -u postgres createuser --superuser $DATABASE_USERNAME"
    echo "$ $cmd"
    $cmd
  } || exit 1
}

# setup database if required
if [[ $DATABASE ]] ; then
  psql -U$DATABASE_USERNAME $DATABASE -c '' &> /dev/null || {
    bash script/confirm.bash "Create new PostgreSQL database $DATABASE" && {
      cmd="sudo -u postgres createdb $DATABASE"
      echo "$ $cmd"
      $cmd
    } || exit 1
  }
fi

# setup database if required
if [[ $TEST_DATABASE ]] ; then
  psql -U$DATABASE_USERNAME $TEST_DATABASE -c '' &> /dev/null || {
    bash script/confirm.bash "Create new PostgreSQL database $TEST_DATABASE" && {
      cmd="sudo -u postgres createdb $TEST_DATABASE"
      echo "$ $cmd"
      $cmd
    } || exit
  }
fi

