#!/usr/bin/env bash

echo '$ rake assets:precompile'
bundle exec rake assets:precompile || exit 1

