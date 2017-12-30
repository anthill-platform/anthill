#!/usr/bin/env bash

brew install collectd
brew install influxdb
brew install grafana

cp monitoring/collectd.conf /usr/local/etc/collectd.conf
cp monitoring/influxdb.conf /usr/local/etc/influxdb.conf

brew services start influxdb
brew services start collectd
brew services start grafana

sleep 5

influx -execute 'CREATE DATABASE dev'
