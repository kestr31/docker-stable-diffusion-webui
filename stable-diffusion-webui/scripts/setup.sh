#! /bin/bash

# WAIT UNTIL ui-config.json IS GENERATED
# THIS FILE IS USED TO DECIDE WHETHER THE STARTUP PROCESS IS FINISHED OR NOT
UI_CONFIG_DIR=$(find /home/user/stable-diffusion-webui -maxdepth 1 -type f -name 'ui-config.json')

echo "STABLE-DIFFUSION-WEBUI IS BEGING SET UP"
echo "PLEASE BE PATIENT SINCE IT WILL TAKE QUITE A LONG TIME"

TIME_START=$(date +%s)
TIME_COUNT=${TIME_START}

while [ -z ${UI_CONFIG_DIR} ];
do
    UI_CONFIG_DIR=$(find /home/user/stable-diffusion-webui -maxdepth 1 -type f -name 'ui-config.json')

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

# If ui-config.json is not mapped, overwrite it to default value
echo "STABLE-DIFFUSION-WEBUI SETUP COMPLETE"