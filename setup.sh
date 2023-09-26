#! /bin/bash

SD_DATA_DIR=home/${USER}/Documents/Stable-Diffusion-WebUI

sed -i "s/<YOUR_UID>/${UID}/g" run.env
sed -i "s/<YOUR_GID>/${GID}/g" run.env

echo -e "[INFO]\t SD WEBUI DIRECTORY WILL BE CREATED ON:"
echo -e "[INFO]\t\t /home/${USER}/Documents/Stable-Diffusion-WebUI"

if [ ! -d "${SD_DATA_DIR}" ]; then
    mkdir ${SD_DATA_DIR} \
        ${SD_DATA_DIR}/models \
        ${SD_DATA_DIR}/output \
        ${SD_DATA_DIR}/styles \
        ${SD_DATA_DIR}/extensions
    
    touch ${SD_DATA_DIR}/ui-config-user.json
    touch ${SD_DATA_DIR}/config-user.json
    echo "INITIAL_PASSWORD" >> ${SD_DATA_DIR}/gradio_auth.txt
    
    echo -e "[INFO]\t DIRECTORIES CREATED."
else
    echo -e "[INFO]\t DIRECTORIES ALREADY EXISTS!"
fi

sed -i "s/<YOUR_DIRECTORY_TO_SD>/${SD_DATA_DIR}/g" run.env

docker compose --env-file run.env up