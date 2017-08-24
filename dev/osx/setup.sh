#!/usr/bin/env bash

# install Homebrew first
export TRAVIS=1
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# bunch of important packages
brew install mysql
brew install rabbitmq
brew install nginx
brew install redis
brew install boost --with-python
brew install boost-python

# setup a virtualenv
easy_install virtualenv
mkdir /usr/local/venv
virtualenv /usr/local/venv/dev

# install packages into virtualenv at /usr/local/venv/dev

source /usr/local/venv/dev/bin/activate

pip install termcolor ipaddr ujson pyzmq redis tornado pycrypto mysql-python
pip install git+https://github.com/anthill-utils/tornado-redis.git
pip install git+https://github.com/anthill-utils/PyMySQL.git
pip install tormysql sphinx
pip install git+https://github.com/anthill-utils/pyjwt.git
pip install git+https://github.com/anthill-utils/pika.git
pip install pyOpenSSL cffi cryptography futures ipgetter expiringdict python-geoip
pip install python-geoip-geolite2-yplan psutil lazy
pip install git+https://github.com/anthill-utils/pyv8.git

# start mysql server
ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist

# create various databases
mysql -u root -e "create database dev_login;"
mysql -u root -e "create database dev_config;"
mysql -u root -e "create database dev_dlc;"
mysql -u root -e "create database dev_environment;"
mysql -u root -e "create database dev_event;"
mysql -u root -e "create database dev_exec;"
mysql -u root -e "create database dev_game;"
mysql -u root -e "create database dev_leaderborad;"
mysql -u root -e "create database dev_message;"
mysql -u root -e "create database dev_profile;"
mysql -u root -e "create database dev_promo;"
mysql -u root -e "create database dev_social;"
mysql -u root -e "create database dev_store;"

# copy nginx configuration
cp nginx.conf /usr/local/etc/nginx/servers/dev.conf
mkdir /usr/local/var/run/anthill

# generate private key pair
mkdir ../../.anthill-keys
openssl genrsa -des3 -passout pass:wYrA9O187G71ILmZr67GZG945SgarS4K -out ../../.anthill-keys/anthill.pem 512
openssl rsa -in ../../.anthill-keys/anthill.pem -passin pass:wYrA9O187G71ILmZr67GZG945SgarS4K -outform PEM -pubout -out ../../.anthill-keys/anthill.pub

# start rest of the services
brew services start nginx
brew services start rabbitmq
brew services start redis