log "Creating project..."

# Create folder
mkdir -p $PROJECTS_ROOT/$PROJECTNAME
chown -R $SUDO_USER:www-data $PROJECTS_ROOT/$PROJECTNAME

sudo -u $SUDO_USER composer create-project -n roots/bedrock $PROJECTS_ROOT/$PROJECTNAME

# cache folder
mkdir -p $PROJECTS_ROOT/$PROJECTNAME/web/app/cache
chown -R www-data:www-data $PROJECTS_ROOT/$PROJECTNAME/web/app/cache

# Also set wp cores owner to www-data
chown -R www-data:www-data $PROJECTS_ROOT/$PROJECTNAME/web/wp
chown -R www-data:www-data $PROJECTS_ROOT/$PROJECTNAME/web/app/uploads
chmod -R 744 $PROJECTS_ROOT/$PROJECTNAME/web/wp

cd $PROJECTS_ROOT/$PROJECTNAME

# Install acorn
sudo -u $SUDO_USER composer require roots/acorn # Acorn needs to be removed when moving away from Sage

# Add plugins
# TODO: create own plugin like air-helper
sudo -u $SUDO_USER composer require wp-cli/wp-cli-bundle wpackagist-plugin/imagify wpackagist-plugin/autodescription
sudo -u $SUDO_USER composer update

# Remove default theme
sudo -u $SUDO_USER composer remove wpackagist-theme/twentytwentythree

log "Adding project to /etc/hosts..."
# Add to /etc/hosts
sudo -- sh -c "echo 127.0.0.1 ${PROJECTNAME}.test >> /etc/hosts"

# Configure .env
sed -i -e "s/database_name/${PROJECTNAME}/g" .env
sed -i -e "s/database_user/root/g" .env
sed -i -e "s/database_password/${MYSQL_ROOT_PASSWORD}/g" .env
sed -i -e "s/database_host/localhost/g" .env
sed -i -e "s/example.com/${PROJECTNAME}.test/g" .env
sed -i -e "s/http/https/g" .env

log "Installing dependencies finished."