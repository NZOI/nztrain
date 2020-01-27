#!/usr/bin/env bash

cd `dirname $0`/../..

source script/install.cfg

update=false
# process script options
for ARG in "$@"
do
    case $ARG in
    "--update")
        update=true
        ;;
    *)
        ;;
    esac
done

SUITE=xenial


new_debootstrap=false

if [[ "$ISOLATE_ROOT" != "/" ]] && [[ ! -d "$ISOLATE_ROOT" ]]; then
  new_debootstrap=true
  apt-get install debootstrap

  mkdir "$ISOLATE_ROOT" -p

  # prompt user before debootstrap
  debootstrap $SUITE "$ISOLATE_ROOT" http://archive.ubuntu.com/ubuntu

  # add sources
  echo deb http://archive.ubuntu.com/ubuntu/ $SUITE-updates main restricted >> /srv/chroot/nztrain/etc/apt/sources.list
  echo deb http://archive.ubuntu.com/ubuntu/ $SUITE universe >> /srv/chroot/nztrain/etc/apt/sources.list
  echo deb http://security.ubuntu.com/ubuntu $SUITE-security main restricted universe >> /srv/chroot/nztrain/etc/apt/sources.list
  echo deb http://nz.archive.ubuntu.com/ubuntu/ $SUITE multiverse >> /srv/chroot/nztrain/etc/apt/sources.list
  echo deb-src http://nz.archive.ubuntu.com/ubuntu/ $SUITE multiverse >> /srv/chroot/nztrain/etc/apt/sources.list
  echo deb http://nz.archive.ubuntu.com/ubuntu/ $SUITE-updates multiverse >> /srv/chroot/nztrain/etc/apt/sources.list

  # link /etc/resolv.conf
  ln --force /etc/resolv.conf "$ISOLATE_ROOT/etc/resolv.conf"
fi

if ${update:=true} || ${new_debootstrap:=true} ; then
  chroot "$ISOLATE_ROOT" apt-get update
fi

chroot_cmd="$ chroot \"$ISOLATE_ROOT\""
chroot_install="$chroot_cmd apt-get install"

mount -o bind /proc "$ISOLATE_ROOT/proc"

[ -z "$TRAVIS" ] && { # if not in Travis-CI
  # python ppa
  if ! chroot "$ISOLATE_ROOT" apt-cache show python3.4 &>/dev/null ||
      ! chroot "$ISOLATE_ROOT" apt-cache show python3.8 &>/dev/null; then
    echo "$chroot_cmd add-apt-repository ppa:deadsnakes/ppa -y"
    chroot "$ISOLATE_ROOT" add-apt-repository ppa:deadsnakes/ppa -y
  fi

  # ruby ppa
  echo "$chroot_cmd add-apt-repository ppa:brightbox/ruby-ng -y"
  chroot "$ISOLATE_ROOT" add-apt-repository ppa:brightbox/ruby-ng -y
}

echo "$chroot_cmd apt-get update"
chroot "$ISOLATE_ROOT" apt-get update

# utilities
echo "$chroot_install wget"
chroot "$ISOLATE_ROOT" apt-get install wget

# end utilities

echo "$chroot_install software-properties-common"
chroot "$ISOLATE_ROOT" apt-get install software-properties-common # provides add-apt-repository

echo "$chroot_install build-essential"
chroot "$ISOLATE_ROOT" apt-get install build-essential # C/C++ (g++, gcc)

echo "$chroot_install ruby"
chroot "$ISOLATE_ROOT" apt-get install ruby # Ruby (ruby)

[ -z "$TRAVIS" ] && { # if not in Travis-CI
  # add haskell ppa
  echo "$chroot_cmd add-apt-repository ppa:hvr/ghc -y"
  chroot "$ISOLATE_ROOT" add-apt-repository ppa:hvr/ghc -y

  echo "$chroot_cmd apt-get update"
  chroot "$ISOLATE_ROOT" apt-get update

  echo "$chroot_install ghc-8.8.2"
  chroot "$ISOLATE_ROOT" apt-get install ghc-8.8.2 # Haskell (ghc)

  echo "$chroot_cmd update-alternatives --install /usr/bin/ghc ghc /opt/ghc/8.8.2/bin/ghc 75"
  chroot "$ISOLATE_ROOT" update-alternatives --install /usr/bin/ghc ghc /opt/ghc/8.8.2/bin/ghc 75

  # Note: Running ghc requires /proc to be mounted. The isolate command mounts
  # it, but it might not be mounted if running ghc manually in the chroot.
  # (To find shared libraries, the ghc binary has a RUNPATH attribute with
  # paths that are relative to $ORIGIN. The dynamic linker uses /proc/self/exe
  # to expand $ORIGIN. It can be overridden using the environment variable
  # LD_ORIGIN_PATH.)
}

if ! chroot "$ISOLATE_ROOT" apt-cache show openjdk-11-jdk &>/dev/null; then
  # add java ppa
  echo "$chroot_cmd add-apt-repository ppa:openjdk-r/ppa -y"
  chroot "$ISOLATE_ROOT" add-apt-repository ppa:openjdk-r/ppa -y

  echo "$chroot_cmd apt-get update"
  chroot "$ISOLATE_ROOT" apt-get update
fi

echo "$chroot_install openjdk-11-jdk"
chroot "$ISOLATE_ROOT" apt-get install openjdk-11-jdk # Java

[ -z "$TRAVIS" ] && { # if not in Travis-CI

  # echo "$chroot_install python"
  # chroot "$ISOLATE_ROOT" apt-get install python # Python 2 (deprecated)
  echo "$chroot_install python3.4"
  chroot "$ISOLATE_ROOT" apt-get install python3.4 # Python 3.4
  echo "$chroot_install python3.8"
  chroot "$ISOLATE_ROOT" apt-get install python3.8 # Python 3.8
  # note: when updating these Python versions, also update the check for adding the PPA above

  echo "$chroot_install ruby2.2"
  chroot "$ISOLATE_ROOT" apt-get install ruby2.2


  ## INSTALL J
  chroot "$ISOLATE_ROOT" mkdir /home/j -p
  J_TAG="J803"
  J_DEB="j803_amd64.deb"
  J_SAVE="/home/j/$J_DEB"
  [ -f "$ISOLATE_ROOT/$J_SAVE" ] || {
    echo "wget -O \"$ISOLATE_ROOT/$J_SAVE\" https://github.com/NZOI/J-install/releases/download/$J_TAG/$J_DEB"
    wget -O "$ISOLATE_ROOT/$J_SAVE" "https://github.com/NZOI/J-install/releases/download/$J_TAG/$J_DEB"
  }

  echo "$chroot_cmd dpkg -i $J_SAVE"
  chroot "$ISOLATE_ROOT" dpkg -i "$J_SAVE"

  cat << EOF > "$ISOLATE_ROOT"/home/j/install.ijs
load 'pacman'
'update' jpkg ''
'install' jpkg 'format/printf'
'install' jpkg 'format/datefmt'
'install' jpkg 'types/datetime'
'upgrade' jpkg 'all'
exit 0
EOF

  echo "$chroot_cmd ijconsole /home/j/install.ijs"
  chroot "$ISOLATE_ROOT" ijconsole /home/j/install.ijs
  ## END INSTALL J

}

umount "$ISOLATE_ROOT/proc"

if [ ! -f "$ISOLATE_ROOT/usr/bin/cint.rb" ] ; then
  cmd="cp `dirname $0`/cint.rb $ISOLATE_ROOT/usr/bin"
  echo "$cmd"
  $cmd

  cmd="chmod 0755 $ISOLATE_ROOT/usr/bin/cint.rb"
  echo "$cmd"
  $cmd
fi

# gcc 9
echo "$chroot_cmd add-apt-repository ppa:ubuntu-toolchain-r/test -y"
chroot "$ISOLATE_ROOT" add-apt-repository ppa:ubuntu-toolchain-r/test -y

echo "$chroot_cmd apt-get update"
chroot "$ISOLATE_ROOT" apt-get update

echo "$chroot_cmd apt-get install gcc-9"
chroot "$ISOLATE_ROOT" apt-get install gcc-9

echo "$chroot_cmd apt-get install g++-9"
chroot "$ISOLATE_ROOT" apt-get install g++-9

echo "$chroot_cmd update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 75"
chroot "$ISOLATE_ROOT" update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 75

echo "$chroot_cmd update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 75"
chroot "$ISOLATE_ROOT" update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 75
# gcc 9 done

[ -z "$TRAVIS" ] && bash script/confirm.bash 'Install .NET Core (C#)' && {
  set -x

  : Installing .NET Core for C#
  # https://docs.microsoft.com/en-us/dotnet/core/install/linux-package-manager-ubuntu-1604

  : Downloading package info from Microsoft
  UBUNTU_VERSION=$(lsb_release --release --short)
  chroot "$ISOLATE_ROOT" wget -q "https://packages.microsoft.com/config/ubuntu/${UBUNTU_VERSION}/packages-microsoft-prod.deb" -O /tmp/packages-microsoft-prod.deb
  chroot "$ISOLATE_ROOT" dpkg -i /tmp/packages-microsoft-prod.deb
  chroot "$ISOLATE_ROOT" rm /tmp/packages-microsoft-prod.deb
  if [ "$UBUNTU_VERSION" == "18.04" ]; then chroot "$ISOLATE_ROOT" add-apt-repository universe; fi
  chroot "$ISOLATE_ROOT" apt-get install -y apt-transport-https
  chroot "$ISOLATE_ROOT" apt-get update

  : Installing dotnet 3.1
  chroot "$ISOLATE_ROOT" apt-get install -y dotnet-sdk-3.1

  : Creating runtime config file
  # The dotnet command will not execute the compiled .exe unless there is a config file
  # which tells it what runtime framework to use.
  # https://stackoverflow.com/questions/46065777/is-it-possible-to-compile-a-single-c-sharp-code-file-with-the-net-core-roslyn-c

  RUNTIME_CONFIG_PATH="$ISOLATE_ROOT/usr/share/dotnet-config.json"  # used in the compile command
  RUNTIME_CONFIG_TEMPL="script/csharp/dotnet-config-template.json"

  # referenced in RUNTIME_CONFIG_TEMPL file
  DOTNET_FW_VERSION=$(dotnet --version | sed -r "s/([0-9].[0-9].[0-9])[0-9]*/\1/") \
  DOTNET_FW_NAME="Microsoft.NETCore.App" \
  envsubst < $RUNTIME_CONFIG_TEMPL | cat > $RUNTIME_CONFIG_PATH

  : Moving shell scripts into place

  cp "script/csharp/compile-command.sh" "$ISOLATE_ROOT/usr/local/csc.sh"
  chroot "$ISOLATE_ROOT" ln "/usr/local/csc.sh" "/usr/bin/csc"
  chroot "$ISOLATE_ROOT" chmod +x "/usr/bin/csc"

  cp "script/csharp/run-command.sh" "$ISOLATE_ROOT/usr/local/csr.sh"
  chroot "$ISOLATE_ROOT" ln "/usr/local/csr.sh" "/usr/bin/csr"
  chroot "$ISOLATE_ROOT" chmod +x "/usr/bin/csr"

  set +x
  echo ".NET Core (C#) was installed"
}
