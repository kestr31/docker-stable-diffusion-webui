#! /bin/bash

# Change UID and GUID per user
set -e
set -u

if [ ${UID} != 1000 ] || [ ${GID} != 1000 ] then
    echo -e "[INFO]\t UID OR GID IS NOT 1000."
    echo -e "[INFO]\t OWNERSHIP MUST BE CHANGED."
    echo -e "[INFO]\t THIS WILL TAKE SOME TIME..."

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

    if [ -f "/home/user/stable-diffusion-webui/ui-config.json" ]; then
        chown -R user:user /home/user/stable-diffusion-webui/ui-config.json
    fi

    if [ -f "/home/user/stable-diffusion-webui/config.json" ]; then
        chown -R user:user /home/user/stable-diffusion-webui/config.json
    fi


else
    echo -e "[INFO]\t BOTH UID AND GID ARE 1000."
    echo -e "[INFO]\t NO NEED TO CHANGE OWNERSHIP."
fi

echo -e "[INFO]\t OWNERSHIP PREPARATION COMPLETE!"

if [-s /home/user/stable-diffusion-webui/ui-config-user.json] | [/home/user/stable-diffusion-webui/config-user.json] then
    echo -e "[INFO]\t EMPTY ui-config-user.json or config-user.json"
    echo -e "[INFO]\t THESE FILES WILL BE FILLED UP WITH DEFAULT SETTINGS FOR ONLY ONCE."
    su -c "/home/user/stable-diffusion-webui/webui.sh --xformers --skip-torch-cuda-test --no-download-sd-model" user &

    UI_CONFIG_DIR=$(find /home/user/stable-diffusion-webui -maxdepth 1 -type f -name 'ui-config.json')
    UI_SETTINGS_DIR=$(find /home/user/stable-diffusion-webui -maxdepth 1 -type f -name 'config.json')

    TIME_START=$(date +%s)
    TIME_COUNT=${TIME_START}

    while [ -z ${UI_CONFIG_DIR} ] && [ -z ${UI_CONFIG_DIR} ] do
    
        UI_CONFIG_DIR=$(find /home/user/stable-diffusion-webui -maxdepth 1 -type f -name 'ui-config.json')
        UI_SETTINGS_DIR=$(find /home/user/stable-diffusion-webui -maxdepth 1 -type f -name 'config.json')

	TIME_NOW=$(date +%s)
	TIME_ELLAPSED=$(($TIME_NOW-$TIME_START))
	NOTIFICATION_THRESHOLD=$(($TIME_NOW-$TIME_COUNT))

	# if [ ${NOTIFICATION_THRESHOLD} -gt 20 ];
	# then
	# 	TIME_COUNT=${TIME_NOW}
	# 	echo "---------------------------------------"
	# 	echo "KEEP SETTING UP STABLE-DIFFUSION-WEBUI"
	# 	echo "TIME ELLAPSED: ${TIME_ELLAPSED} SECONDS"
	# 	echo "---------------------------------------"
	# fi
    done

    echo ${UI_CONFIG_DIR} >> /home/user/stable-diffusion-webui/ui-config-user.json
    echo ${UI_SETTINGS_DIR} >> /home/user/stable-diffusion-webui/config-user.json

    pkill python3
else
    echo -e "[INFO]\t IT SEEMS YOU ALREADY HAVE RUN SD WEBUI BEFORE."
fi

source /home/user/stable-diffusion-webui/webui-user.sh
su -c "/home/user/stable-diffusion-webui/webui.sh" user