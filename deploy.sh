#!/bin/bash
# Deploy latest version
# Pulls latest changes from GitHub and restarts the services

set -ex

cd /opt/mrnaid-code

git pull

cd frontend
npm ci && npm run build
cp ./config/nginx.conf /etc/nginx/conf.d/
cp -R ./build/* /usr/share/nginx/html

source /opt/mrnaid-deployment/activate.sh

#pip install . --no-deps

service mrnaid-celery restart
service mrnaid-uwsgi restart

