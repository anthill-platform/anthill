#!/usr/bin/env bash

# install Homebrew first
export TRAVIS=1
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# bunch of important packages
brew install mysql
brew install rabbitmq
brew install nginx
brew install redis

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

git clone https://github.com/anthill-utils/v8py.git
cd v8py
CFLAGS='-Wall -O0 -g' python setup.py install
cd ../

# start mysql server
ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist

# create various databases
mysql -h 127.0.0.1 -u root -e "create database dev_admin;"
mysql -h 127.0.0.1 -u root -e "create database dev_login;"
mysql -h 127.0.0.1 -u root -e "create database dev_config;"
mysql -h 127.0.0.1 -u root -e "create database dev_dlc;"
mysql -h 127.0.0.1 -u root -e "create database dev_environment;"
mysql -h 127.0.0.1 -u root -e "create database dev_event;"
mysql -h 127.0.0.1 -u root -e "create database dev_exec;"
mysql -h 127.0.0.1 -u root -e "create database dev_game;"
mysql -h 127.0.0.1 -u root -e "create database dev_leaderboard;"
mysql -h 127.0.0.1 -u root -e "create database dev_message;"
mysql -h 127.0.0.1 -u root -e "create database dev_profile;"
mysql -h 127.0.0.1 -u root -e "create database dev_promo;"
mysql -h 127.0.0.1 -u root -e "create database dev_social;"
mysql -h 127.0.0.1 -u root -e "create database dev_store;"
mysql -h 127.0.0.1 -u root -e "create database dev_report;"

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