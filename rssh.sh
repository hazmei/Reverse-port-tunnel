#!/bin/bash
# this file automates the process to create reverse ssh on the RPi
# this file must be in same directory as config_template and create_ssh_tunnel.sh files

echo "Starting configuration for Reverse SSH..."
echo -n "Remote hostname: "
read remoteHostname

echo -n "Enter remote username to login to: "
read remoteUsername

echo -n "Enter remote port number(>=2000) for reverse SSH: "
read remotePort
monitoringPort=$((uniquePort + 1))

echo -n "Enter local port number to port forward: "
read localPort

mv create_ssh_tunnel.sh create_ssh_tunnel.sh.bak
sudo sed 's/MONITORPORT/'"$monitoringPort"'/' < create_ssh_tunnel.sh.bak | tee create_ssh_tunnel.sh > /dev/null
rm create_ssh_tunnel.sh.bak

echo "Checking connection to remote host"
ssh -o StrictHostKeyChecking=no $remoteUsername@$remoteHostname "lsb_release -a"

echo "Installing autossh now..."
sudo apt-get install autossh -y

echo "Backing up /etc/ssh/ssh_config file..."
sudo cp /etc/ssh/ssh_config /etc/ssh/ssh_config.bak

mv config_template config_template.bak
sed 's/USERNAME/'$(whoami)'/' < config_template.bak | sudo tee config_template > /dev/null
sudo sed 's/REMOTE_PORT/'"$remotePort"'/' < config_template | sudo tee -a /etc/ssh/ssh_config > /dev/null
sudo sed 's/LOCAL_PORT/'"$remotePort"'/' < ssh_config | sudo tee -a /etc/ssh/ssh_config > /dev/null
sudo rm config_template config_template.bak

sudo crontab -l > mycron
echo '*/1 * * * * sudo -H -u '$(whoami)' /home/'$(whoami)'/create_ssh_tunnel.sh' >> mycron
sudo crontab mycron
sudo rm mycron

chmod 700 create_ssh_tunnel.sh

sudo rm rssh.sh