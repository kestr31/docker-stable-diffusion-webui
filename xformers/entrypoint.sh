#! /bin/sh
cd /root/xformers
pip install -r requirements.txt ninja
pip install --upgrade --extra-index-url https://download.pytorch.org/whl/cu113 torch torchvision torchaudio
python3 setup.py build
python3 setup.py bdist_wheel --universal
