#!/usr/bin/env bash

echo "Installing Mono"
sudo apt-get install ca-certificates gnupg
sudo gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
sudo apt-get update
sudo apt-get install mono-complete -y

echo "Installing Dependencies"
sudo apt-get install policykit-1 libgtk2.0-0 screen uml-utilities gtk-sharp2 libc6-dev gcc python3 python3-pip -y

echo "Installing Renode"
wget https://github.com/renode/renode/releases/download/v1.14.0/renode_1.14.0_amd64.deb -O renode.deb
sudo dpkg -i renode.deb
rm renode.deb

echo "Installing Robot Framework"
git clone https://github.com/renode/renode.git renode-repo
python3 -m pip install -r renode-repo/tests/requirements.txt
rm -fr renode-repo
