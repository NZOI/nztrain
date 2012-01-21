#!/bin/bash

# note, we are bashing the echoes so that "sh update.sh" will still print coloured output

# optional: mark website down (.htaccess url rewrite or other similar)

# pull from git
bash -c "echo -e '\E[34m\033[1mgit pull\033[0m'"
git pull | sed -e 's/^/   /g;' | cat # sed to indent output

# install new gems required
bash -c "echo -e '\E[34m\033[1mbundle install\033[0m'"
bundle install | sed -e 's/^/   /g;/Using/{:a;N;$!ba;s/Using [0-9a-z_ -]\+\(([0-9.]\+) \)\?\n//g}' | cat # sed indents, remove output of un-upgraded gems

# Stop WEBrick/Apache server here

# migrate database
bash -c "echo -e '\E[34m\033[1mbundle exec rake db:migrate\033[0m'"
bundle exec rake db:migrate | sed -e 's/^/   /g;' | cat # sed to indent output
# reseed database if necessary
bash -c "echo -e '\E[34m\033[1mbundle exec rake db:seed\033[0m'"
bundle exec rake db:seed | sed -e 's/^/   /g;' | cat # sed to indent output


# Start WEBrick/Apache server here

# If using Phusion Passenger, touch tmp/restart.txt can restart Rails





