#!/bin/bash
cd projects/$1/web/app/themes/$1

if ! command -v yarn &> /dev/null
then
    echo "Yarn is not installed. Installing yarn."
    sudo npm install -g yarn
fi

yarn
yarn build
