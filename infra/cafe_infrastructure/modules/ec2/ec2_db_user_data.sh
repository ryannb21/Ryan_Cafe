#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y mysql-client curl unzip

#Installing snap if not available
if ! command -v snap >/dev/null 2>&1; then
apt-get install -y snapd
systemctl enable --now snapd.socket || true
fi

#Install/refreshing the amazon-ssm-agent
snap install amazon-ssm-agent --classic || snap refresh amazon-ssm-agent 
snap start --enable amazon-ssm-agent