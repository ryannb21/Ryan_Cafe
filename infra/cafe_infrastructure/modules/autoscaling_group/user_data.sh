#!/bin/bash
set -xe

#Updating and installing the required packages
apt-get update -y
apt-get install -y software-properties-common tzdata git

#Adding deadsnakes PPA to install a newer Python version
add-apt-repository ppa:deadsnakes/ppa -y
apt-get update -y
apt-get install -y python3.11 python3.11-venv python3.11-distutils

#Setting up the app under the ubuntu user
sudo -u ubuntu bash <<'EOF'
cd /home/ubuntu
mkdir -p Ryan_Cafe_App
cd Ryan_Cafe_App

#Cloning the repo
git clone https://github.com/ryannb21/SSJ_Cafe.git .

#Setting up the Python environment and dependencies
/usr/bin/python3.11 -m venv venv
source venv/bin/activate

pip install --upgrade pip
pip install -r requirements.txt
pip install gunicorn

deactivate
EOF

#Creating a Gunicorn systemd service file
cat >/etc/systemd/system/ryan-cafe.service <<EOF
[Unit]
Description=Gunicorn instance to serve Ryan Cafe App
After=network.target
StartLimitIntervalSec=60
StartLimitBurst=5

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu/Ryan_Cafe_App
Environment="PATH=/home/ubuntu/Ryan_Cafe_App/venv/bin"
ExecStart=/home/ubuntu/Ryan_Cafe_App/venv/bin/gunicorn --workers ${GUNICORN_WORKERS:-3} --bind 0.0.0.0:5000 app:app
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


# Reload systemd and enable the service
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable ryan-cafe.service
systemctl start ryan-cafe.service