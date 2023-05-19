PROJECTS_ROOT=$1
PROJECTNAME=$2
WP_EMAIL=$3

# Actual install command
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp core install --title=${PROJECTNAME} --admin_email=${WP_EMAIL}

# Update settings
echo "Removing default WordPress posts and applying settings via WP-CLI..."
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp post delete 1 --force
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp post delete 2 --force
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp option update blogdescription ''
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp option update WPLANG 'fi'
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp option update current_theme '$PROJECTNAME'
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp theme delete twentytwelve
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp theme delete twentythirteen
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp option update permalink_structure '/%postname%'
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp option update timezone_string 'Europe/Helsinki'
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp option update default_pingback_flag '0'
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp option update default_ping_status 'closed'
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp option update default_comment_status 'closed'
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp option update date_format 'j.n.Y'
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp option update time_format 'H.i'
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp option update admin_email 'koodarit@dude.fi'
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp option delete new_admin_email
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp plugin activate --all
cd ${PROJECTS_ROOT}/$PROJECTNAME;./vendor/wp-cli/wp-cli/bin/wp plugin deactivate worker