#!/usr/bin/env bash

min_version=1.9.2
ruby -e 'puts RUBY_VERSION' 2>/dev/null | bash script/check_version.bash $min_version || {
  echo "Ruby $min_version+ required!"
  echo Select an install option for Ruby 1.9.3

  # detect RVM
  rvm --version && rvm_option="Install Ruby using RVM" || rvm_option="Install RVM (Single User)"
  rbenv --version && rbenv_option="Install Ruby using rbenv" || rbenv_option="Install rbenv (Single User on Desktop with ruby-build)"
  select INSTALL_OPTION in "Don't install" "System MRI Ruby from source" "$rvm_option" "$rbenv_option";
  do
    case $REPLY in
      1)
        exit 1
        break;;
      2)
        bash script/install/sysruby.bash || exit 1
        break;;
      3)
        bash script/install/rvm.bash || exit 1
        break;;
      4)
        bash script/install/rbenv.bash || exit 1
        break;;
    esac
  done
}

