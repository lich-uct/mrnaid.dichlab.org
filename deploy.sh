#!/bin/bash
# Deploy latest version
# Pulls latest changes from GitHub and restarts the services

set -ex

cd /opt/mrnaid-code

git pull

source /opt/mrnaid-deployment/activate.sh

#pip install . --no-deps

service mrnaid-celery restart
service mrnaid-uwsgi restart

