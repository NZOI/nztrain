#!/usr/bin/env bash

# generates a new install.cfg from the install.cfg.template, filling in the necessary variables from user prompts

# read user options
shopt -s nocasematch;

while [ -z "$RAILS_ENV" ] ; do
  read -p 'What environment is used to run this rails installation - d[evelopment] (default) or p[roduction]? ' RAILS_ENV
  if [[ development =~ ^$RAILS_ENV ]] ; then RAILS_ENV=development
  elif [[ production =~ ^$RAILS_ENV ]]; then RAILS_ENV=production
  else unset RAILS_ENV; fi
done

shopt -u nocasematch;

# generate template
while read line ; do
    while [[ "$line" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]] ; do
        LHS=${BASH_REMATCH[1]}
        RHS="$(eval echo "\"$LHS\"")"
        line=${line//$LHS/$RHS}
    done
    echo $line
done < script/install.cfg.template > script/install.cfg

echo "   script/install.cfg configuration file written"

