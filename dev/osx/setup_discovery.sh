#!/usr/bin/env bash

cd ../../admin

source /usr/local/venv/dev/bin/activate
./terminal.sh --file="../dev/osx/setup_discovery.txt" --discovery_service="http://localhost:9502"