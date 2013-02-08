#!/usr/bin/env bash

# Installs the latest stable Ruby 1.9.x from source
branch="ruby-1.9-stable"
tmpdir="ruby_install"

# remember current directory
pdir=`pwd`

# download and extract source
cmd="mkdir /tmp/$tmpdir" ; echo "$ $cmd" ; $cmd || exit 1
cmd="cd /tmp/$tmpdir" ; echo "$ $cmd" ; $cmd || exit 1
cmd="wget http://ftp.ruby-lang.org/pub/ruby/$branch.tar.gz" ; echo "$ $cmd" ; $cmd || exit 1
cmd="mkdir src" ; echo "$ $cmd" ; $cmd
cmd="tar xvf $branch.tar.gz -C src" ; echo "$ $cmd" ; $cmd || exit 1
version=`ls src`
cmd="mkdir build" ; echo "$ $cmd" ; $cmd || exit 1
cmd="cd build" ; echo "$ $cmd" ; $cmd || exit 1

# prepare install commands
cmd="sudo apt-get install build-essential libreadline-dev libssl-dev libyaml-dev libffi-dev libncurses-dev libdb-dev libgdbm-dev tk-dev"
cmd2="sudo ../src/$version/configure --enable-shared --prefix=/opt/ruby/$version"
cmd3="sudo make all"
cmd4="sudo make test"
cmd5="sudo make install"
echo "$ $cmd"
echo "$ $cmd2"
echo "$ $cmd3"
echo "$ $cmd4"
echo "$ $cmd5"
# install
$cmd && $cmd2 && $cmd3 && $cmd4 && $cmd5 && {
  cd $pdir
  cmd="sudo update-alternatives --install /usr/bin/ruby ruby /opt/ruby/$version/bin/ruby 400 \
        --slave   /usr/bin/ri ri /opt/ruby/$version/bin/ri \
        --slave   /usr/bin/irb irb /opt/ruby/$version/bin/irb \
        --slave   /usr/bin/erb erb /opt/ruby/$version/bin/erb \
        --slave   /usr/bin/rake rake /opt/ruby/$version/bin/rake \
        --slave   /usr/bin/rdoc rdoc /opt/ruby/$version/bin/rdoc"
  echo "$ $cmd" ; $cmd
  cmd="sudo update-alternatives --install /usr/bin/gem gem /opt/ruby/$version/bin/gem 400"
  echo "$ $cmd" ; $cmd

  bash script/confirm.bash "update-alternatives of ruby/gem commands to $version" && {
    cmd="sudo update-alternatives --set ruby /opt/ruby/$version/bin/ruby"
    echo "$ $cmd" ; $cmd
    cmd="sudo update-alternatives --set gem /opt/ruby/$version/bin/gem"
    echo "$ $cmd" ; $cmd
  }
  bash script/confirm.bash "Add /opt/ruby/$version/bin to \$PATH in ~/.profile" && {
    cmd="echo PATH=\\\"\\\$PATH:/opt/ruby/$version/bin\\\" | tee -a ~/.profile"
    echo "$ $cmd"
    echo PATH=\"\$PATH:/opt/ruby/$version/bin\" | tee -a ~/.profile
  }
} || exit 1
cd $pdir
bash script/confirm.bash "Delete ruby source in /tmp/$tmpdir" && {
  cmd="sudo rm /tmp/$tmpdir -r" ; echo "$ $cmd" ; $cmd
}

exit 0

