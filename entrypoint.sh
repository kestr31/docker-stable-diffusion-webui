#! /bin/sh

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

echo "Started changing permissions"
echo "Please wait until next message appears..."
echo "It will take some time"
chown -R user:user /home/user
echo "Reconfigured!"

su -c /home/user/stable-diffusion-webui/run.sh user

# Leave container to be persistent
sleep infinity