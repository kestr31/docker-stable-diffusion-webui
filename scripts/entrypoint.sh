#! /bin/bash

debug_message() {
    echo "
        ____  __________  __  ________   __  _______  ____  ______
       / __ \/ ____/ __ )/ / / / ____/  /  |/  / __ \/ __ \/ ____/
      / / / / __/ / __  / / / / / __   / /|_/ / / / / / / / __/   
     / /_/ / /___/ /_/ / /_/ / /_/ /  / /  / / /_/ / /_/ / /___   
    /_____/_____/_____/\____/\____/  /_/  /_/\____/_____/_____/   
    
    "
    echo "INFO [SITL] DEBUG_MODE IS SET. NOTHING WILL RUN"
}


# Change UID and GUID per user
set -e
set -u

SD_WEBUI_DIR="/home/user/stable-diffusion-webui"

if [ "${DEBUG_MODE}" -eq "1" ]; then
    debug_message
    sleep infinity
else 
    if [ ${UID} != 1000 ] || [ ${GID} != 1000 ]; then
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

        chown -R user:user ${SD_WEBUI_DIR}/extensions
        chown -R user:user ${SD_WEBUI_DIR}/outputs
        chown -R user:user ${SD_WEBUI_DIR}/styles
        chown -R user:user ${SD_WEBUI_DIR}/models
        chown -R user:user ${SD_WEBUI_DIR}/settings
        chown -R user:user ${SD_WEBUI_DIR}/webui-user.sh
    else
        echo -e "[INFO]\t BOTH UID AND GID ARE 1000."
        echo -e "[INFO]\t NO NEED TO CHANGE OWNERSHIP."
    fi

    echo -e "[INFO]\t OWNERSHIP PREPARATION COMPLETE!"

    # if [ ! -s ${SD_WEBUI_DIR}/settings/ui-config-user.json ] || [ ! -s ${SD_WEBUI_DIR}/settings/config-user.json ]; then
    if [ ! -s ${SD_WEBUI_DIR}/settings/ui-config-user.json ]; then
        echo -e "[INFO]\t EMPTY ui-config-user.json or config-user.json"
        echo -e "[INFO]\t THESE FILES WILL BE FILLED UP WITH DEFAULT SETTINGS FOR ONLY ONCE."

        su -c "./webui.sh --xformers --skip-torch-cuda-test" user &

        UI_CONFIG_DIR=$(find ${SD_WEBUI_DIR} -maxdepth 1 -type f -name 'ui-config.json')
        UI_SETTINGS_DIR=$(find ${SD_WEBUI_DIR} -maxdepth 1 -type f -name 'config.json')

        TIME_START=$(date +%s)
        TIME_COUNT=${TIME_START}

        while [ -z ${UI_CONFIG_DIR} ]; do
            
                UI_CONFIG_DIR=$(find ${SD_WEBUI_DIR} -maxdepth 1 -type f -name 'ui-config.json')
                # UI_SETTINGS_DIR=$(find ${SD_WEBUI_DIR} -maxdepth 1 -type f -name 'config.json')

            TIME_NOW=$(date +%s)
            TIME_ELLAPSED=$(($TIME_NOW-$TIME_START))
            NOTIFICATION_THRESHOLD=$(($TIME_NOW-$TIME_COUNT))

            if [ ${NOTIFICATION_THRESHOLD} -gt 20 ];
            then
            	TIME_COUNT=${TIME_NOW}
            	echo "---------------------------------------"
            	echo "KEEP SETTING UP STABLE-DIFFUSION-WEBUI"
            	echo "TIME ELLAPSED: ${TIME_ELLAPSED} SECONDS"
            	echo "---------------------------------------"
            fi
        done

        echo $(cat ${UI_CONFIG_DIR}) > ${SD_WEBUI_DIR}/settings/ui-config-user.json

        echo -e "\n"
        echo -e "[INFO]\t INITIAL SETUP COMPLETE. PLEASE RUN THIS AGAIN."
        exit 0
    else
        echo -e "[INFO]\t IT SEEMS YOU ALREADY HAVE RUN SD WEBUI BEFORE."
    fi

    su -c "cp ./settings/webui-user.sh ./webui-user.sh" user
    su -c "./webui.sh" user
fi

sleep infinity