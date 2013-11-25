# configures nginx and adds unicorn and other servers as a service running this application

# Example:
#
#   bash script/install/service.bash
#
# adds a service $APP_NAME (from install.cfg, eg. nztrain) that starts the application
# which can be controlled via
#
#   sudo service nztrain start

cd `dirname $0`/../..

if [ -z $CONFIG_LOADED ]; then
  source script/install.cfg
fi

NGINX_INSTALL_DIR="/usr/local/nginx"

# nginx includes this app configuration
bash $RAILS_ROOT/script/template.bash < $RAILS_ROOT/script/install/nginx.app.conf | cat > $NGINX_INSTALL_DIR/conf/$APP_NAME.app.conf

(
  RAILS_ENV=production
  cd config/procfiles/$RAILS_ENV
  foreman export upstart /etc/init
)

#if [ ! -f /etc/init.d/$APP_NAME ] ; then
#  # setup unicorn init.d
#  bash script/template.bash < script/install/app-init-script | cat > /etc/init.d/$APP_NAME
#
#  chmod +x /etc/init.d/$APP_NAME
#
#  # automatically startup service on boot
#  update-rc.d -f $APP_NAME defaults
#else # update the init.d script, but don't add service to startup
#  bash script/template.bash < script/install/app-init-script | cat > /etc/init.d/$APP_NAME
#
#  chmod +x /etc/init.d/$APP_NAME
#fi

