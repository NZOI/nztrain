#!/usr/bin/env bash

ruby_version=2.0.0

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

  echo "$ \\curl -L https://get.rvm.io | bash -s stable"
  \curl -L https://get.rvm.io | bash -s stable
  echo 'echo "source $HOME/.rvm/scripts/rvm" >> ~/.bashrc'
  echo "source $HOME/.rvm/scripts/rvm" >> ~/.bashrc
  echo "RVM installed, now restart the session and re-run this script"
  exit 1
}

