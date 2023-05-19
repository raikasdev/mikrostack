#!/bin/bash

# Colors
RED='\033[0;31m'
NC='\033[0m' # No Color

# Installs all dependencies on Ubuntu

# Let's refresh repositories
required_version="22.04"
current_version=$(lsb_release -rs)
arch=$(dpkg --print-architecture)
user=$(whoami)

if ! [[ $user = "root" ]]; then
    echo "Please run this script as root."
    echo "Example: sudo ./scripts/ubuntu-setup.sh"
    exit
fi

if ! [[ $(bc <<< "${current_version} >= ${required_version}") -eq 1 ]]; then
    echo "! ! ! WARNING ! ! !"
    echo "Your Ubuntu version is ${current_version}, which is older than ${required_version}."
    echo "This means that the APT repository might contain a PHP version older than 8.1"
    echo "Proceed at your own caution. You can exit the program by using CTRL+C"
    echo "! ! ! WARNING ! ! !"
    echo "Resuming in 10 seconds..."
    sleep 10
fi

echo "Refreshing APT database..."

apt update

echo "Installing dependencies..."

# Installing php-fpm first to avoid Apache2
apt install -y php-fpm
apt install -y git php mariadb-server php-bcmath php-ctype php-fileinfo php-json php-mbstring php-tokenizer php-xml nginx libnss3-tools

systemctl enable nginx
systemctl enable mariadb

echo "Downloading mkcert from Filippo"
curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/${arch}"
chmod +x mkcert-v*-linux-${arch}
cp mkcert-v*-linux-${arch} /usr/local/bin/mkcert
rm mkcert-v*-linux-${arch}

echo "Installing NodeJS"

# Due to personal preference: I am using `n` instead of `nvm`, and yarn instead of npm
apt install nodejs npm
npm install -g n
n lts
corepack enable # Enabled access to Yarn 

echo "Installing Composer."
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
chmod +x composer.phar
mv composer.phar /usr/local/bin/composer

echo "Installing bun"
curl -fsSL https://bun.sh/install | bash

echo "Creating SSL cert folder"
mkdir -p /var/www/certs

echo "Setting /var/www permissions"
chmod -R 776 /var/www
chown -R $SUDO_USER:www-data /var/www

echo "Installation complete"
echo "Running mysql secure install script. Remember the password you set."
mysql_secure_installation
