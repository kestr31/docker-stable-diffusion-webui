#!/bin/bash

# ENTYPOINT SCRIPT TO DEPLOY SD WEBUI

# CHECK IF DIRECTORY workspace EXISTS IN USER user HOME
if [ ! -f /home/user/workspace/webui.sh ]; then
    echo "THERE IS NO webui.sh IN /home/user/workspace"
    exit 1
else
    # IF UID IS SET, CHANGE THE UID OF THE USER
    if [ ! -z ${PUID} ]; then
        usermod -u ${PUID} user
    fi

    # IF GID IS SET, CHANGE THE GID OF THE USER
    if [ ! -z ${PGID} ]; then
        groupmod -g ${PGID} user
    fi

    # RUN webu.sh AS USER user
    su user -c "bash /home/user/workspace/webui.sh --listen --enable-insecure-extension-access"
fi