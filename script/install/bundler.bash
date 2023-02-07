#!/usr/bin/env bash

bundler_version="<2.4" # must be < 2.4 because Bundler 2.4 requires Ruby >= 2.6 but we use Ruby 2.3.8

bundle version 2>/dev/null || {
  # check if directory where gems are installed is writable
  if [ -w "$(gem environment gemdir)" ]; then
    # don't need sudo (probably user installation e.g. rvm/rbenv, or we could be running as root)
    cmd="gem install bundler -v $bundler_version"
    echo "$ $cmd"
    $cmd || exit 1
  else
    # need to use sudo to install gems (system-wide installation)
    cmd="sudo gem install bundler -v $bundler_version"
    echo "$ $cmd"
    $cmd || exit 1
  fi
  # check if 'gem' is available in the system-wide PATH (e.g. /usr/bin/gem)
  # ('command -v' is like 'which', -p uses the default value of PATH)
  if command -p -v gem &>/dev/null; then
    # if it is, also make bundler available in the system-wide PATH
    sudo update-alternatives --install /usr/bin/bundle bundle "$(ruby -e 'puts Gem.bindir')/bundle" 400 || exit 1
  fi
}


