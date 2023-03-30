#! /bin/bash

# Change UID and GUID per user
set -e
set -u

: "${UID:=0}"
: "${GID:=${UID}}"

mkdir -p /tmp/home/user
usermod -d /tmp/home/user user

if [ "$#" = 0 ]; then
    set -- "$(command -v bash 2>/dev/null || command -v sh)" -l
fi

if [ ${UID} != 0 ]; then
        usermod -u ${UID} user -o 2>/dev/null && {
                groupmod -g ${GID} user 2>/dev/null ||
                usermod -a -G ${GID} user
        }
fi
usermod -d /home/user user
rm -rf /tmp/home/user

echo "CHANGING OWNERSHIP OF SOME FILES..."

chown user:user /home/user
chown user:user /home/user/.bashrc
chown -R user:user /home/user/.cache

chown -R user:user /home/user/kohya_ss/venv/bin/activate
chown -R user:user /home/user/kohya_ss/logs
chown -R user:user /home/user/kohya_ss/models
chown -R user:user /home/user/kohya_ss/regularizations

echo "RECONFIGURED!"

su -c "source /home/user/kohya_ss/venv/bin/activate \
        && /home/user/kohya_ss/gui.sh \
            --username $(sed 's/:.*//' ${DIR_GRADIO_AUTH}) \
            --password $(sed 's/.*://' ${DIR_GRADIO_AUTH}) \
            --listen 0.0.0.0 \
            --server_port 7861" user