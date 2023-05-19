# Installs the starter theme
log "Installing the starter theme..."

mkdir -p $PROJECTS_ROOT/$PROJECTNAME/web/app/themes/$PROJECTNAME
chown $SUDO_USER:www-data $PROJECTS_ROOT/$PROJECTNAME/web/app/themes/$PROJECTNAME
chmod 774 $PROJECTS_ROOT/$PROJECTNAME/web/app/themes/$PROJECTNAME

sudo -u $SUDO_USER composer create-project -n roots/sage $PROJECTS_ROOT/$PROJECTNAME/web/app/themes/$PROJECTNAME dev-main

cd $PROJECTS_ROOT/$PROJECTNAME/web/app/themes/$PROJECTNAME

# Add Acorn to composer.json
json=$(cat "./composer.json")

# Check if the "scripts" key exists
if [[ "$json" == *"\"scripts\":"* ]]; then
    # Add the string to the "scripts" array under "post-autoload-dump" key
    updated_json=$(echo "$json" | jq '.scripts["post-autoload-dump"] += ["'"Roots\\\\Acorn\\\\ComposerScripts::postAutoloadDump"'"]')
else
    # Create a new "scripts" object with the string under "post-autoload-dump" key
    updated_json=$(echo "$json" | jq '. + { "scripts": { "post-autoload-dump": ["'"Roots\\\\Acorn\\\\ComposerScripts::postAutoloadDump"'"] } }')
fi

echo $updated_json > ./composer.json

sudo -u $SUDO_USER composer update

# Configure bud
sed -i -e "s/http:\/\/example.test/https:\/\/${PROJECTNAME}.test/g" bud.config.js

# Run yarn
sudo -u $SUDO_USER yarn install
sudo -u $SUDO_USER yarn build

cd $PROJECTS_ROOT/$PROJECTNAME
sudo -u $SUDO_USER ./vendor/wp-cli/wp-cli/bin/wp theme activate $PROJECTNAME

mkdir -p web/app/cache
chmod -R 777 web/app/cache

# Set up virtual hosts
source ${SCRIPT_PATH}/tasks/nginx.sh

# Add cert with mkcert
source ${SCRIPT_PATH}/tasks/ssl.sh

log "Restarting nginx..."
source ${SCRIPT_PATH}/tasks/restart-nginx.sh