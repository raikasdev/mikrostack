if [ -f $ENV_FILE ]; then
  export $(echo $(cat $ENV_FILE | sed 's/#.*//g'| xargs) | envsubst)
fi
