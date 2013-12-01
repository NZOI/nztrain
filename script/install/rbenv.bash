#!/usr/bin/env bash

ruby_version=2.0.0-p353

# detect rbenv
rbenv --version &> /dev/null && {
  # install ruby on rbenv
  cmd="rbenv install $ruby_version"
  echo "$ $cmd"
  $cmd

  source ~/.bashrc
  cmd="rbenv global $ruby_version"
  echo "$ $cmd"
  $cmd
  echo "Ruby $ruby_version installed, restart your session again and re-run this script"
  exit 1
} || {
  # install rvm
  git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc

  # install ruby-build
  git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

  # add some bootstrap scripts
  cat `dirname $0`/rbenv-installer | bash

  echo "rbenv installed, now restart the session and re-run this script"
  echo "You might want to run a bootstrap script to install some ruby dependencies before installing a ruby, eg 'rbenv bootstrap-ubuntu-12-04'"
  exit 1
}

