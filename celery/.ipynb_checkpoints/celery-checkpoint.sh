#!/bin/bash
# Run Celery worker service

# Exit on first error
set -e

# Activate conda env and set ENV vars
source /opt/mrnaid-deployment/activate.sh

celery \
	-A tasks \
	worker \
	--loglevel=INFO \
	--concurrency 4
