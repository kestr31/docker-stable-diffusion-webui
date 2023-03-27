#! /bin/bash

# Change UID and GUID per user
set -e
set -u

: "${UID:=0}"
: "${GID:=${UID}}"

if [ "$#" = 0 ]; then
    set -- "$(command -v bash 2>/dev/null || command -v sh)" -l
fi

if [ ${UID} != 0 ]; then
        usermod -u ${UID} user -o 2>/dev/null && {
                groupmod -g ${GID} user 2>/dev/null ||
                usermod -a -G ${GID} user
        }
fi

echo "CHANGING OWNERSHIP OF SOME FILES..."

chown -R user:user /home/user/stable-diffusion-webui/extensions
chown -R user:user /home/user/stable-diffusion-webui/outputs
chown -R user:user /home/user/stable-diffusion-webui/styles
chown -R user:user /home/user/stable-diffusion-webui/models

if [ -f "/home/user/stable-diffusion-webui/ui-config.json" ];
then
        chown -R user:user /home/user/stable-diffusion-webui/ui-config.json
fi

if [ -f "/home/user/stable-diffusion-webui/config.json" ];
then
        chown -R user:user /home/user/stable-diffusion-webui/config.json
fi

chown -R user:user /home/user/kohya_ss/images
chown -R user:user /home/user/kohya_ss/logs
chown -R user:user /home/user/kohya_ss/models
chown -R user:user /home/user/kohya_ss/regularizations

echo "RECONFIGURED!"

source /home/user/stable-diffusion-webui/webui-user.sh
su -c "/home/user/stable-diffusion-webui/webui.sh" user &
su -c "cd /home/user/kohya_ss \
        && source /home/user/kohya_ss/venv/bin/activate \
        && /home/user/kohya_ss/gui.sh \
                --username $(sed 's/:.*//' ${DIR_GRADIO_AUTH}) \
                --password $(sed 's/.*://' ${DIR_GRADIO_AUTH}) \
                --listen 0.0.0.0 \
                --server_port 7861" user