#! /usr/bin/env bash

# Below steps were copied from https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script
# Following repository installation method
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update
sudo apt install docker-ce docker-ce-cli containerd.io

# Create a docker group
sudo groupadd docker
sudo usermod -aG docker "${USER}"
newgrp docker
su -s "${USER}"

# Start docker at boot
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

echo "Docker installation completed successfully."
echo "Please log out or reboot your system to apply the changes."
