#!/usr/bin/env bash

min_version=1.9.2
ruby -e 'puts RUBY_VERSION' 2>/dev/null | bash script/check_version.bash $min_version || {
  echo "Ruby $min_version+ required!"
  echo Select an install option for Ruby 1.9.3
  select INSTALL_OPTION in "Don't install" "System MRI Ruby from source" "RVM";
  do
    case $REPLY in
      1)
        exit 1
        break;;
      2)
        bash script/install/sysruby.bash || exit 1
        break;;
      3)
        break;;
    esac
  done
}

