log "Installing WordPress..."

echo "path: web/wp
url: https://${PROJECTNAME}.test

core install:
  admin_user: \"${WP_USERNAME}\"
  admin_password: \"${WP_PASSWORD}\"
  admin_email: \"${WP_EMAIL}\"
  title: \"${PROJECTNAME}\"" > wp-cli.yml

sudo -u $SUDO_USER /bin/bash $SCRIPT_PATH/tasks/wpcli.sh $PROJECTS_ROOT $PROJECTNAME $WP_EMAIL