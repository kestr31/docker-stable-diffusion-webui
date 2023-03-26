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
        sudo usermod -u ${UID} user -o 2>/dev/null && {
                sudo groupmod -g ${GID} user 2>/dev/null ||
                sudo usermod -a -G ${GID} user
        }
fi

echo "CHANGING OWNERSHIP OF SOME FILES..."

sudo chown -R user:user /home/user/stable-diffusion-webui/styles
sudo chown -R user:user /home/user/stable-diffusion-webui/ui-config.json

if [ -f "/home/user/stable-diffusion-webui/config.json" ];
then
        sudo chown -R user:user /home/user/stable-diffusion-webui/config.json
fi

echo "RECONFIGURED!"

source /home/user/stable-diffusion-webui/webui-user.sh
/home/user/stable-diffusion-webui/webui.sh