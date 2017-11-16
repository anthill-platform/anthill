#!/usr/bin/env bash

if [[ $EUID -eq 0 ]]; then
  echo "Do not run this script as root." 2>&1
  exit 1
fi

# install Homebrew first
export TRAVIS=1
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# bunch of important packages
brew install git
brew install mysql
brew install rabbitmq
brew install redis

mkdir /opt/local
sudo mkdir /opt/local/anthill
sudo chmod -R 770 /opt/local/anthill

# setup a virtualenv
sudo easy_install virtualenv
mkdir /usr/local/venv
virtualenv /usr/local/venv/dev

# install packages into virtualenv at /usr/local/venv/dev

source /usr/local/venv/dev/bin/activate

/usr/local/venv/dev/bin/pip install termcolor ipaddr ujson pyzmq redis tornado pycrypto mysql-python GitPython
/usr/local/venv/dev/bin/pip install git+https://github.com/anthill-utils/tornado-redis.git
/usr/local/venv/dev/bin/pip install git+https://github.com/anthill-utils/PyMySQL.git
/usr/local/venv/dev/bin/pip install tormysql sphinx
/usr/local/venv/dev/bin/pip install git+https://github.com/anthill-utils/pyjwt.git
/usr/local/venv/dev/bin/pip install git+https://github.com/anthill-utils/pika.git
/usr/local/venv/dev/bin/pip install pyOpenSSL cffi cryptography futures ipgetter expiringdict python-geoip
/usr/local/venv/dev/bin/pip install python-geoip-geolite2-yplan psutil lazy

git clone https://github.com/anthill-utils/v8py.git
cd v8py
export MACOSX_DEPLOYMENT_TARGET=10.8
CFLAGS='-Wall -O0 -g' /usr/local/venv/dev/bin/python setup.py install
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
mysql -h 127.0.0.1 -u root -e "create database dev_static;"
mysql -h 127.0.0.1 -u root -e "create database dev_report;"

# generate private key pair
mkdir ../../.anthill-keys
openssl genrsa -des3 -passout pass:wYrA9O187G71ILmZr67GZG945SgarS4K -out ../../.anthill-keys/anthill.pem 512
openssl rsa -in ../../.anthill-keys/anthill.pem -passin pass:wYrA9O187G71ILmZr67GZG945SgarS4K -outform PEM -pubout -out ../../.anthill-keys/anthill.pub

# start rest of the services
brew services start rabbitmq
brew services start redis