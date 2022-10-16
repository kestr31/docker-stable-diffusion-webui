#! /bin/sh
cd /home/user/stable-diffusion-webui
/home/user/stable-diffusion-webui/webui-user.sh
/home/user/stable-diffusion-webui/webui.sh &

# Wait unti ui-config.json is generated
# This is necessary since webui.sh overwrites existing ui-config.json to default value when startup
UI_CONFIG_DIR=$(find /home/user/stable-diffusion-webui -maxdepth 1 -type f -name 'ui-config.json')

while [[ -z ${UI_CONFIG_DIR} ]];
do
    UI_CONFIG_DIR=$(find /home/user/stable-diffusion-webui -maxdepth 1 -type f -name 'ui-config.json')
	echo "Waiting until Stable-Diffusion-WebUI starts up..."
	sleep 1s
done

# If ui-config.json is generated, overwrite it
echo "Stable-Diffusion-WebUI Configured!"
echo "Restoring backup ui-config.json"
mv /home/user/ui-config.json.bak /home/user/stable-diffusion-webui/ui-config.json

# Leave container to be persistent
sleep infinity
