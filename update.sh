#!/bin/bash

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

# change pwd to RAILS ROOT (the directory this script resides in)
cd `dirname $0`

# note, we are bashing the echoes so that "sh update.sh" will still print coloured output

# optional: mark website down (.htaccess url rewrite or other similar)

if ${gitpull:=true} ; then
    # pull from git
    bash -c "echo -e '\E[34m\033[1mgit pull\033[0m'"
    git pull | sed -e 's/^/   /g;' | cat # sed to indent output
fi

# install new gems required
bash -c "echo -e '\E[34m\033[1mbundle install\033[0m'"
bundle install | sed -e 's/^/   /g;/Using/{:a;N;$!ba;s/Using [0-9a-z_ -]\+\(([0-9.]\+) \)\?\n//g}' | cat # sed indents, remove output of un-upgraded gems

# Stop WEBrick/Apache server here (only if database needs migration?)

# migrate database
bash -c "echo -e '\E[34m\033[1mbundle exec rake db:migrate\033[0m'"
bundle exec rake db:migrate | sed -e 's/^/   /g;' | cat # sed to indent output
# reseed database if necessary
bash -c "echo -e '\E[34m\033[1mbundle exec rake db:seed\033[0m'"
bundle exec rake db:seed | sed -e 's/^/   /g;' | cat # sed to indent output

# can restart server here

# update cron jobs (whenever cronjobs tagged with the rails directory name)
cmd="bundle exec whenever --update-crontab `basename \`pwd\``"
bash -c "echo -e '\E[34m\033[1m$cmd\033[0m'"
$cmd

# precompile assets (if in production mode)
bash -c "echo -e '\E[34m\033[1mbundle exec rake assets:precompile\033[0m'"
bundle exec rake assets:precompile | sed -e 's/^/   /g;' | cat # sed to indent output


# Start WEBrick/Apache server here

# If using Phusion Passenger, touch tmp/restart.txt can restart Rails





