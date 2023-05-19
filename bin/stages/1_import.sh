# Used to import existing projects from Git
# From https://github.com/digitoimistodude/dudestack
# Licensed under MIT, Copyright © 2017 Digitoimisto Dude Oy <koodarit@dude.fi>

parse_args() {
  case "$1" in
    "--import")
      # Check if local .env found
      if [ ! -f ${ENV_FILE} ]; then
        warn "No .env file found. Please run the script without --import flag first."
        echo ""
        exit
      fi

      # Tell the user we are using existing project
      cyan "--import flag detected. Make sure you know what you're doing."

      # Check if company username is set
      if [ -n "$GITHUB_COMPANY_USERNAME" ]; then
        # If found
        cd "$PROJECTS_ROOT"

        # Ask the existing project name
        log "What is the name of the Github repository in the ${GITHUB_COMPANY_USERNAME} organization?"
        read -e PROJECTNAME

        # If empty, bail
        if [ -z "$PROJECTNAME" ]; then
          warn "No project name given. Please give the correct project name."
          echo ""
          exit
        fi

        # If clone already exists, bail
        if [ -d "$PROJECTS_ROOT/$PROJECTNAME" ]; then
          echo "Project already exists. Please give the correct project name."
          echo ""
          exit
        fi

        # If clone command fails, bail
        if ! git clone git@github.com:${GITHUB_COMPANY_USERNAME_ENV}/${PROJECTNAME}.git
        then
          echo "Cloning project failed. The project might not exist, or you may not have permission to access it."
          echo ""
          exit

        else
          # If clone command succeeds, continue
          cd "$PROJECTS_ROOT/$PROJECTNAME"

          # Check for package.json
          if [ -f "package.json" ]; then
            # Run npm install in project root
            echo "Running yarn install in project root..."
            yarn install

            # Run npm install in theme directory
            echo "Running yarn install in theme directory..."
            cd "$PROJECTS_ROOT/$PROJECTNAME/content/themes/$PROJECTNAME"
            yarn install

            # Go back to project root
            cd "$PROJECTS_ROOT/$PROJECTNAME"
          else
            echo ""
          fi

          # Add project to hosts file
          log "Updating hosts file..."
          sudo -- sh -c "echo 127.0.0.1 ${PROJECTNAME}.test >> /etc/hosts"

          # Set up virtual hosts
          source ${SCRIPT_PATH}/tasks/nginx.sh

          # Add cert with mkcert
          source ${SCRIPT_PATH}/tasks/ssl.sh

          log "Restarting nginx..."
          source ${SCRIPT_PATH}/tasks/restart-nginx.sh

          # Tell to add .env
          success "All done! Except..."
          echo ""
          log "Next:
1. Please add an .env file to project root
2. Run composer install"
          echo ""

          log "After this you can start developing at https://${PROJECTNAME}.test"
          echo ""

          exit
        fi
      else
        # If not found
        warn "No GitHub company username found. Please run the script without --existing flag first."
        echo ""
        exit
      fi

      exit
    ;;
    *)
      export DIR_TO_FILE=$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")
    ;;
    esac
}

# Parse args
parse_args "$@"
