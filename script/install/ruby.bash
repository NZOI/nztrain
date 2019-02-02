#!/usr/bin/env bash

min_version=1.9.2

# min_version needs to be increased to 2.3, but for now still allow 1.9.2 - 2.2
# when min_version is set to 2.3 this section of the script can be removed
min_recommended_version=2.3
if ruby_version="$(ruby -e 'puts RUBY_VERSION' 2>/dev/null)"; then
  echo "Ruby $ruby_version detected"
  if echo "$ruby_version" | bash script/check_version.bash $min_recommended_version; then
    exit 0 # new version already installed, skip installation
  elif echo "$ruby_version" | bash script/check_version.bash $min_version; then
    echo "Warning: This is an old version of Ruby with known problems"
    echo "- Ruby < 2.3 has reached end-of-life and is no longer supported"
    echo "- Gem dependencies are broken (e.g. public_suffix-3.0.1 requires ruby >= 2.1, bundler 2.0.1 requires ruby >= 2.3.0)"
    echo "- Custom evaluators only work on Ruby >= 2.3 (need https://github.com/ruby/ruby/commit/1ade9cad02a3)"
    if ! DEFAULT=1 bash script/confirm.bash "Use Ruby $ruby_version"; then
      min_version=$min_recommended_version # force newer version to be installed
    fi
  else
    echo "This version of Ruby is too old, you must install a new one"
  fi
else
  echo "Ruby is not installed"
fi

ruby -e 'puts RUBY_VERSION' 2>/dev/null | bash script/check_version.bash $min_version || {
  echo "Ruby $min_version+ required!"
  echo "Select an install option for Ruby 2.3.8"

  # detect RVM
  rvm --version &>/dev/null && rvm_option="Install Ruby using RVM" || rvm_option="Install RVM (single user)"
  rbenv --version &>/dev/null && rbenv_option="Install Ruby using rbenv" || rbenv_option="Install rbenv (single user with ruby-build)"
  select INSTALL_OPTION in "Exit without installing" "System MRI Ruby from source" "$rvm_option" "$rbenv_option";
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

