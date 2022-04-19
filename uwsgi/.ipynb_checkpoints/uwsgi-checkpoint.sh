#!/bin/bash
# Run mRNAid flask backend using uwsgi

# Exit on first error
set -e

# Activate conda env and set ENV vars
source /opt/mrnaid-deployment/activate.sh

uwsgi --ini app.ini:uwsgi-no-docker
