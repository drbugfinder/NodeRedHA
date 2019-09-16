#!/bin/bash
echo "This script will setup the cluster node. It will not join the cluster and will not make crm configuration. Please remember to set up 'yast lan' first."
read -p "Continue (y/n)?" CONT
if [ "$CONT" = "y" ]; then
echo "OK."
else
  exit 1
fi
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "Turning Off SWAP"
swapoff --all
sudo free -h

echo "Adding User"
useradd -ou 0 -g 0 hausr
mkdir /home/hausr
echo "Please Enter User Password For 'hausr'"
passwd hausr

echo "Creating Cluster Mount"
mkdir /data

echo "Installing Needed Packages"
zypper -n refresh
zypper -n update
zypper -n install nfs-utils hawk2

echo "Installing Node-Red"
npm install -g npm
npm install -g node-red
npm install

echo "Creating Node-Red Service"
#####
cat >/usr/lib/systemd/system/nodered.service <<EOL
# systemd service file to start Node-RED
  
[Unit]
Description=NodeRed graphical event wiring tool.
Documentation=http://nodered.org/docs/

[Service]
Type=simple
Nice=5
ExecStart=/usr/bin/env node-red --max-old-space-size=128 --userDir /data/nodered 

# Use SIGINT to stop
KillSignal=SIGINT
# Auto restart on crash
Restart=on-failure
# Tag things in the log
SyslogIdentifier=Node-RED
#StandardOutput=syslog

[Install]
WantedBy=multi-user.target
EOL
#####
systemctl daemon-reload
echo Done

echo "HOSTNAME"
cat /etc/hostname
echo "IP configuration"
ip a
echo "CRM status"
crm status

echo "Testing NFS Mount"
mount -t nfs IPofyourNFSserver:/path/to/your/share /data/
ls -lah /data
umount /data

reboot  
