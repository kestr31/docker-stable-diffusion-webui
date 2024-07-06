#!/bin/bash

# FUNCTION TO DEPLOY SD WEBUI
# INPUTS
# $1: ARGUMENT [run|stop|debug]
# $2: WORKSPACE DIRECTORY (optional, defult: ${HOME}/Documents/sd-webui)



# INITIAL STATEMENTS
# >>>----------------------------------------------------

# SET THE BASE DIRECTORY
BASE_DIR=$(dirname $(realpath $0))
REPO_DIR=$(dirname ${BASE_DIR})

# SOURCE THE ENVIRONMENT AND FUNCTION DEFINITIONS
source ${BASE_DIR}/commonFcn.sh
source ${REPO_DIR}/run.env

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



# DEFINE USAGE FUNCTION
# >>>----------------------------------------------------

usage(){
    echo "Usage: $0 [run|stop|debug] [WORKSPACE_DIR (optional)]"
    echo "run: RUN THE SD-WEBUI CONTAINER"
    echo "stop: STOP THE SD-WEBUI CONTAINER"
    echo "debug: RUN THE SD-WEBUI CONTAINER IN DEBUG MODE"
    exit 1
}

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



# CHECK IF ANY INPUT ARGUMENTS ARE PROVIDED
# >>>----------------------------------------------------

if [ $# -eq 0 ] || [ $# -gt 2 ]; then
    usage $0
else
    if [ "$1x" != "runx" ] && [ "$1x" != "startx" ] && [ "$1x" != "downx" ] && [ "$1x" != "stopx" ] && [ "$1x" != "debugx" ]; then
        EchoRed "[$(basename "$0")] INVALID INPUT. PLEASE USE \"run\", \"stop\", OR \"debug\"."
        exit 1
    else
        # CHECK IF INPUT STATEMENT $2 IS PROVIDED
        if [ $# -eq 2 ]; then
            WORKSPACE_DIR=$2
            CheckDir ${WORKSPACE_DIR}
        else
            WORKSPACE_DIR=${HOME}/Documents/sd-webui
            CheckDir ${WORKSPACE_DIR} create
        fi
    fi
fi

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



# MAIN STATEMENTS
# >>>----------------------------------------------------

if [ "$1x" == "runx" ]; then
    # RUN THE SD-WEBUI CONTAINER    
    EchoYellow "[$(basename "$0")] RUNNING SD-WEBUI CONTAINER"
    EchoYellow "[$(basename "$0")] WORKSPACE DIRECTORY: ${WORKSPACE_DIR}"

    cp ${REPO_DIR}/compose.yml ${WORKSPACE_DIR}/compose.yml
    cp ${REPO_DIR}/run.env ${WORKSPACE_DIR}/run.env

    sed -i "s~\${WORKSPACE_DIR}~${WORKSPACE_DIR}~g" \
        ${WORKSPACE_DIR}/run.env
    sed -i "s~\${ENTRYPOINT}~/usr/local/bin/entrypoint.sh~g" \
        ${WORKSPACE_DIR}/run.env
    sed -i "s~\${PUID}~$(id -u)~g" \
        ${WORKSPACE_DIR}/run.env
    sed -i "s~\${PGID}~$(id -g)~g" \
        ${WORKSPACE_DIR}/run.env

    # CHECK IF stable-diffusion-webui DIRECTORY EXISTS IN WORKSPACE DIRECTORY
    if [ ! -d ${WORKSPACE_DIR}/stable-diffusion-webui ]; then
        EchoYellow "[$(basename "$0")] DIRECTORY stable-diffusion-webui NOT FOUND IN WORKSPACE DIRECTORY"
        EchoYellow "[$(basename "$0")] CLONING STABLE-DIFFUSION-WEBUI REPOSITORY"
        git clone \
            https://github.com/AUTOMATIC1111/stable-diffusion-webui.git \
            ${WORKSPACE_DIR}/stable-diffusion-webui \
            -b ${WEBUI_VERSION}
    else
        EchoGreen "[$(basename "$0")] DIRECTORY stable-diffusion-webui EXISTS IN WORKSPACE DIRECTORY"
    fi

    docker compose \
        -f ${WORKSPACE_DIR}/compose.yml \
        --env-file ${WORKSPACE_DIR}/run.env \
        up -d

    EchoGreen "[$(basename "$0")] SD-WEBUI CONTAINER RUNNING SUCCESSFULLY"
    EchoBoxLine

elif [ "$1x" == "startx" ]; then
    # STOP THE SD-WEBUI CONTAINER

    # CHECK IF compose.yml EXISTS IN WORKSPACE DIRECTORY
    if [ -f ${WORKSPACE_DIR}/compose.yml ] && [ -f ${WORKSPACE_DIR}/run.env ]; then
        EchoYellow "[$(basename "$0")] STOPPING SD-WEBUI CONTAINER"

        docker compose \
            -f ${WORKSPACE_DIR}/compose.yml \
            --env-file ${WORKSPACE_DIR}/run.env \
            start

        EchoGreen "[$(basename "$0")] SD-WEBUI CONTAINER STARTED SUCCESSFULLY"

        EchoBoxLine
    else
        EchoRed "[$(basename "$0")] compose.yml OR run.env NOT FOUND IN WORKSPACE DIRECTORY"
        EchoRed "[$(basename "$0")] PLEASE RUN THE SD-WEBUI CONTAINER FIRST"
        EchoRed "[$(basename "$0")] IF YOU DID, PLEASE CHECK IF compose.yml EXISTS IN ${WORKSPACE_DIR}"

        EchoBoxLine
        exit 1
    fi

elif [ "$1x" == "downx" ]; then
    # STOP THE SD-WEBUI CONTAINER

    # CHECK IF compose.yml EXISTS IN WORKSPACE DIRECTORY
    if [ -f ${WORKSPACE_DIR}/compose.yml ] && [ -f ${WORKSPACE_DIR}/run.env ]; then
        EchoYellow "[$(basename "$0")] STOPPING SD-WEBUI CONTAINER"

        docker compose \
            -f ${WORKSPACE_DIR}/compose.yml \
            --env-file ${WORKSPACE_DIR}/run.env \
            down

        EchoGreen "[$(basename "$0")] SD-WEBUI CONTAINER DOWN SUCCESSFULLY"

        EchoBoxLine
    else
        EchoRed "[$(basename "$0")] compose.yml OR run.env NOT FOUND IN WORKSPACE DIRECTORY"
        EchoRed "[$(basename "$0")] PLEASE RUN THE SD-WEBUI CONTAINER FIRST"
        EchoRed "[$(basename "$0")] IF YOU DID, PLEASE CHECK IF compose.yml EXISTS IN ${WORKSPACE_DIR}"

        EchoBoxLine
        exit 1
    fi

elif [ "$1x" == "stopx" ]; then
    # STOP THE SD-WEBUI CONTAINER

    # CHECK IF compose.yml EXISTS IN WORKSPACE DIRECTORY
    if [ -f ${WORKSPACE_DIR}/compose.yml ] && [ -f ${WORKSPACE_DIR}/run.env ]; then
        EchoYellow "[$(basename "$0")] STOPPING SD-WEBUI CONTAINER"

        docker compose \
            -f ${WORKSPACE_DIR}/compose.yml \
            --env-file ${WORKSPACE_DIR}/run.env \
            stop

        EchoGreen "[$(basename "$0")] SD-WEBUI CONTAINER STOPPED SUCCESSFULLY"

        EchoBoxLine
    else
        EchoRed "[$(basename "$0")] compose.yml OR run.env NOT FOUND IN WORKSPACE DIRECTORY"
        EchoRed "[$(basename "$0")] PLEASE RUN THE SD-WEBUI CONTAINER FIRST"
        EchoRed "[$(basename "$0")] IF YOU DID, PLEASE CHECK IF compose.yml EXISTS IN ${WORKSPACE_DIR}"

        EchoBoxLine
        exit 1
    fi

elif [ "$1x" == "debugx" ]; then
    # RUN THE SD-WEBUI CONTAINER IN DEBUG MODE
    # RUN THE SD-WEBUI CONTAINER    
    EchoYellow "[$(basename "$0")] RUNNING SD-WEBUI CONTAINER IN DEBUG MODE"
    EchoYellow "[$(basename "$0")] WORKSPACE DIRECTORY: ${WORKSPACE_DIR}"

    cp ${REPO_DIR}/compose.yml ${WORKSPACE_DIR}/compose.yml
    cp ${REPO_DIR}/run.env ${WORKSPACE_DIR}/run.env

    sed -i "s~\${WORKSPACE_DIR}~${WORKSPACE_DIR}~g" \
        ${WORKSPACE_DIR}/run.env
    sed -i "s~\${ENTRYPOINT}~'bash -c \"sleep infinity\"'~g" \
        ${WORKSPACE_DIR}/run.env
    sed -i "s~\${PUID}~$(id -u)~g" \
        ${WORKSPACE_DIR}/run.env
    sed -i "s~\${PGID}~$(id -g)~g" \
        ${WORKSPACE_DIR}/run.env

    # CHECK IF stable-diffusion-webui DIRECTORY EXISTS IN WORKSPACE DIRECTORY
    if [ ! -d ${WORKSPACE_DIR}/stable-diffusion-webui ]; then
        EchoYellow "[$(basename "$0")] DIRECTORY stable-diffusion-webui NOT FOUND IN WORKSPACE DIRECTORY"
        EchoYellow "[$(basename "$0")] CLONING STABLE-DIFFUSION-WEBUI REPOSITORY"
        git clone \
            https://github.com/AUTOMATIC1111/stable-diffusion-webui.git \
            ${WORKSPACE_DIR}/stable-diffusion-webui \
            -b ${WEBUI_VERSION}
    else
        EchoGreen "[$(basename "$0")] DIRECTORY stable-diffusion-webui EXISTS IN WORKSPACE DIRECTORY"
    fi

    docker compose \
        -f ${WORKSPACE_DIR}/compose.yml \
        --env-file ${WORKSPACE_DIR}/run.env \
        up -d

    EchoGreen "[$(basename "$0")] SD-WEBUI CONTAINER RUNNING SUCCESSFULLY"
    EchoBoxLine

fi