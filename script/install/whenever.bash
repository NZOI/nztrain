#!/usr/bin/env bash

echo '$ whenever --update-crontab '`basename \`pwd\``
bundle exec whenever --update-crontab `basename \`pwd\``

