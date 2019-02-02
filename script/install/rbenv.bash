#!/usr/bin/env bash

ruby_version=2.3.8

# detect rbenv
rbenv --version &> /dev/null || {
  # install rbenv using rbenv-installer

  curl --version &> /dev/null || {
    cmd="sudo apt-get install curl"
    echo "$ $cmd"
    $cmd || exit 1
  }

  # suggested build environment (https://github.com/rbenv/ruby-build/wiki#suggested-build-environment)
  cmd="sudo apt-get install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev"
  echo "$ $cmd"
  $cmd || exit 1
  # as suggested, try installing libgdbm5, if it is not available try with libgdbm3
  # (it should have been installed as a dependency of libgdbm-dev anyway)
  cmd="sudo apt-get install libgdbm5"
  echo "$ $cmd"
  $cmd || {
    cmd="sudo apt-get install libgdbm3"
    echo "$ $cmd"
    $cmd || exit 1
  }

  # rbenv-installer prints some instructions, make it clear what is
  # output from rbenv-installer and what is output from this script.
  echo "script/install/rbenv.bash: running rbenv-installer..."
  curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash
  # ignore exit code because rbenv-installer runs rbenv-doctor, which is fussy and reports spurious errors
  echo "script/install/rbenv.bash: rbenv-installer finished"
  if ! [ -x ~/.rbenv/bin/rbenv ]; then
    echo "rbenv-installer appears to have failed, please fix and re-run this script"
    exit 1
  fi

  # check if the user wants ~/.bashrc to be configured
  # (try to detect if it's already been configured)
  configure_bashrc=false
  if ! grep -q 'PATH.*\.rbenv/bin' ~/.bashrc; then
    # looks like it hasn't been configured yet
    if bash script/confirm.bash "Configure ~/.bashrc"; then
	configure_bashrc=true
    fi
  else
    # looks like is has already been configured
    echo "It looks like ~/.bashrc has already been configured (did you restart the session?)"
    if DEFAULT=1 bash script/confirm.bash "Configure ~/.bashrc anyway"; then
      configure_bashrc=true
    fi
  fi
  # configure ~/.bashrc (if asked)
  if $configure_bashrc; then
    echo '$ echo '\''export PATH="$HOME/.rbenv/bin:$PATH"'\'' >> ~/.bashrc'
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo '$ echo '\''eval "$(rbenv init -)"'\'' >> ~/.bashrc'
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  fi

  echo "rbenv installed, now restart the session and re-run this script"
  exit 1
}

# install ruby on rbenv
cmd="rbenv install $ruby_version"
echo "$ $cmd"
$cmd || exit 1

# TODO: consider using .ruby-version file for project instead of global version
cmd="rbenv global $ruby_version"
echo "$ $cmd"
$cmd || exit 1
echo "Ruby $ruby_version installed" # no need to restart session
