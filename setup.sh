#! /bin/bash

SD_DATA_DIR="/home/${USER}/Documents/Stable-diffusion-WebUI"

UID=$(id -u)
GID=$(id -g)

sed -i "s/<YOUR_UID>/${UID}/g" ./run.env
sed -i "s/<YOUR_GID>/${GID}/g" ./run.env

echo -e "[INFO]\t SD WEBUI DIRECTORY WILL BE CREATED ON:"
echo -e "[INFO]\t\t ${SD_DATA_DIR}"

if [ ! -d "${SD_DATA_DIR}" ]; then
    mkdir ${SD_DATA_DIR} \
        ${SD_DATA_DIR}/models \
        ${SD_DATA_DIR}/output \
        ${SD_DATA_DIR}/styles \
        ${SD_DATA_DIR}/extensions
    
    touch ${SD_DATA_DIR}/ui-config-user.json
    # touch ${SD_DATA_DIR}/config-user.json
    cp ./webui-user.sh ${SD_DATA_DIR}/webui-user.sh
    echo "user:INITIAL_PASSWORD" >> ${SD_DATA_DIR}/gradio_auth.txt
    
    echo -e "[INFO]\t DIRECTORIES CREATED."
else
    echo -e "[INFO]\t DIRECTORIES ALREADY EXISTS!"
fi

sed -i "s#<YOUR_DIRECTORY_TO_SD>#${SD_DATA_DIR}#g" ./run.env

docker compose --env-file run.env down
docker compose --env-file run.env up