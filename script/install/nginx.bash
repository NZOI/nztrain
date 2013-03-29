#!/usr/bin/env bash

# installs nginx from source
# this is not part of the main installer script, because not all development systems need nginx to be installed
# and a production system may not need nginx to be reinstalled

### VARIABLES ###
PRE_PACK="libc6 libpcre3 libpcre3-dev libpcrecpp0 libssl0.9.8 libssl-dev zlib1g zlib1g-dev lsb-base" # nginx dependencies

VER="1.3.14"

INSTALL_DIR="/usr/local/nginx"
PROG_NAME="nginx"

USER_BIN="/usr/local/sbin"

# optional configuration directives
CONFIGURE_OPTIONS="--prefix=$INSTALL_DIR-$VER
                   --with-http_ssl_module
                   --with-http_gzip_static_module
                   --with-http_mp4_module"

# add passenger as a module if it is installed on the system
if [ `which passenger-config` ] ; then
  CONFIGURE_OPTIONS="$CONFIGURE_OPTIONS --add-module=`passenger-config --root`/ext/nginx"
fi

TEMP_DIR="/tmp/nginx-src"
RAILS_ROOT=`dirname $0`/../..
WD=`pwd`

# install dependencies
sudo aptitude install $PRE_PACK

mkdir $TEMP_DIR; cd $TEMP_DIR

# download and install
wget -q http://nginx.org/download/nginx-$VER.tar.gz
tar xzf ng*.tar.gz && rm -f ng*.tar.gz; cd nginx-*
./configure $CONFIGURE_OPTIONS
make && make install


echo 'Choose nginx configuration file to install:'
cpopt=""
if [ -f /etc/nginx/nginx.conf ]; then
  cpopt="Retain_from_previous_version"
fi
select CONFIG_OPTION in "Retain nginx default" "Use default nztrain nginx.conf" $cpopt;
do
  case $REPLY in
    1)
      break;;
    2)
      cp $RAILS_ROOT/script/install/nginx.conf $INSTALL_DIR-$VER/conf/nginx.conf
      break;;
    3)
      # copy previous configuration files when upgrading
      if [ -f /etc/nginx/nginx.conf ]; then
        cp /etc/nginx/nginx.conf $INSTALL_DIR-$VER/conf/nginx.conf
        cp /etc/nginx/*.app.conf $INSTALL_DIR-$VER/conf/
      else
        echo 'nginx.conf file from previous version of nginx not found'
      fi
      break;;
  esac
done


# remove previous symlinks, if any
rm -f $INSTALL_DIR > /dev/null
rm -f /etc/nginx > /dev/null
rm -f $USER_BIN/$PROG_NAME > /dev/null

# sym links creation
ln -s $INSTALL_DIR-$VER $INSTALL_DIR
cd /etc/; ln -s $INSTALL_DIR/conf nginx
cd $USER_BIN; ln -s $INSTALL_DIR/sbin/$PROG_NAME .

# create alternative
# update-alternatives --install /usr/bin/nginx nginx $INSTALL_DIR/sbin/$PROG_NAME 400
cd $WD
# setup init script
cat $RAILS_ROOT/script/install/nginx-init-script > /etc/init.d/nginx
chmod +x /etc/init.d/nginx

# setup update-rc.d
update-rc.d -f nginx defaults

# remove the temp source directory
rm -rf $TEMP_DIR

