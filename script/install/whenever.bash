#!/usr/bin/env bash

echo '$ whenever --update-crontab '`basename \`pwd\``
`bundle list whenever`/bin/whenever --update-crontab `basename \`pwd\``

