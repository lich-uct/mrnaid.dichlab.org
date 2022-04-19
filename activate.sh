# Set up your conda installation directory (should include bin directory)
CONDA_DIR=/opt/mambaforge

# Add conda bin directory to PATH
export "PATH=$CONDA_DIR/bin:$PATH"

# Enable conda
source $CONDA_DIR/etc/profile.d/conda.sh

# Activate the mRNAid environment
conda activate mRNAid

# Set up ENV vars for mRNAid
BACKEND_DIR=/opt/mrnaid-code/backend
export CELERY_BROKER_URL=redis://127.0.0.1:6379 
export CELERY_RESULT_BACKEND=redis://127.0.0.1:6379 
export LOG_FILE=${BACKEND_DIR}/flask_app/logs/logs.log 
export BACKEND_OBJECTIVES_DATA=${BACKEND_DIR}/common/objectives/data 
export PYTHONPATH=${BACKEND_DIR}/common:${BACKEND_DIR}/common/objectives:${BACKEND_DIR}/common/constraints
export APP_NAME=backend
