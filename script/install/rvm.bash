#!/usr/bin/env bash

ruby_version=2.4.10

# detect rvm
rvm --version &> /dev/null && {
  # install ruby on rvm
  cmd="rvm install $ruby_version"
  echo "$ $cmd"
  $cmd

  source $HOME/.rvm/scripts/rvm
  cmd="rvm use $ruby_version --default"
  echo "$ $cmd"
  $cmd
  echo "Ruby $ruby_version installed, restart your session again and re-run this script"
  exit 1
} || {
  # install rvm

  curl --version &> /dev/null || {
    cmd="sudo apt-get install curl"
    echo "$ $cmd"
    $cmd
  }

  # Import GPG signing keys (key IDs from https://rvm.io/)
  cmd="gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB"
  echo "$ $cmd"
  $cmd

  echo "$ \\curl -L https://get.rvm.io | bash -s stable"
  \curl -sSL https://get.rvm.io | bash -s stable || exit 1
  echo '$ echo '\''source "$HOME/.rvm/scripts/rvm"'\'' >> ~/.bashrc'
  echo 'source "$HOME/.rvm/scripts/rvm"' >> ~/.bashrc
  echo "RVM installed, now restart the session and re-run this script"
  exit 1
}

