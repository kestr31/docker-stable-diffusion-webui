#!/bin/bash

# FUNCTION FOR BUILDING THE DOCKER IMAGE
# INPUTS
# $1: IMAGE NAME (e.g. docker.io/username/sd-webui)
# $2: CUDA Version (e.g. 12.2.2)
# EXAMPLE COMMAND: ./build.sh username/sd-webui 12.2.2


# INITIAL STATEMENTS
# >>>----------------------------------------------------

# SET THE BASE DIRECTORY
BASE_DIR=$(dirname $(realpath $0))
REPO_DIR=$(dirname ${BASE_DIR})

# SOURCE THE ENVIRONMENT AND FUNCTION DEFINITIONS
source ${BASE_DIR}/commonFcn.sh

# HARDCODED VERSION VALUE
REPO_VERSION="1.3.0"

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



# MAIN STATEMENTS
# >>>----------------------------------------------------

# GET ABSOLUTE DIRECTORY OF THIS SCRIPT

EchoYellow "[$(basename "$0")] BUILDING DOCKER IMAGE"
EchoYellow "[$(basename "$0")] IMAGE NAME: ${1}:${2}"

docker build \
    --tag=${1}:${REPO_VERSION}-${2} \
    --build-arg BASEIMAGE=docker.io/nvidia/cuda \
    --build-arg BASETAG=${2}-devel-ubuntu22.04 \
    -f ${REPO_DIR}/Dockerfile ${REPO_DIR}

EchoGreen "[$(basename "$0")] DOCKER IMAGE BUILT SUCCESSFULLY"
EchoBoxLine

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
