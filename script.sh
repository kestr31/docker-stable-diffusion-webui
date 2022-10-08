apt update && apt install git python -y
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
adduser user
su -c ./webui.sh user
apt install python3.8-venv
python3 -m venv ./venv
apt install libgl1-mesa-glx -y
apt-get install libglib2.0-0