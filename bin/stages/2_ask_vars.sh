log "What is the project ID? (name in lowercase with no special characters)"
read -e PROJECTNAME

# Check if configuration exists
if [ ! -f ${ENV_FILE} ]; then
  # Ask Credentials
  echo ""
  echo "${BOLDYELLOW}What is your MySQL root password (asked only first time):${TXTRESET} "
  read -s MYSQL_ROOT_PASSWORD

  echo ""
  echo "${BOLDYELLOW}What is the admin user you want to login to wp-admin by default (asked only first time):${TXTRESET} "
  read -e WP_USERNAME

  echo ""
  echo "${BOLDYELLOW}What is the password you want to use with your wp-admin admin user by default (asked only first time):${TXTRESET} "
  read -s WP_PASSWORD

  echo ""
  echo "${BOLDYELLOW}What is the email address you want to use with your wp-admin admin user by default (asked only first time):${TXTRESET} "
  read -e WP_EMAIL

  # Add Credentials to .env
  touch ${ENV_FILE}
  echo "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}" >> ${ENV_FILE}
  echo "WP_USERNAME=${WP_USERNAME}" >> ${ENV_FILE}
  echo "WP_PASSWORD=${WP_PASSWORD}" >> ${ENV_FILE}
  echo "WP_EMAIL=${WP_EMAIL}" >> ${ENV_FILE}
fi