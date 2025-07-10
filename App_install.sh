#!/bin/bash
#You can change as you needed. 
#Good URL for LibreNMS
#https://github.com/straytripod/LibreNMS-Install/tree/master
# Set timezone to Europe/Stockholm
sudo timedatectl set-timezone Europe/Stockholm

# Log file with timestamp
LOGFILE="$HOME/App_User_Install.log_$(date +'%Y-%m-%d-%H-%M-%S')"

# Redirect stdout and stderr to log file
exec > >(tee -a ${LOGFILE}) 2>&1

echo "Creating an Admin account with password admin123"
sudo useradd -m -d /home/admin -s /bin/bash -g root -G sudo -u 5000 admin
echo 'admin:admin123' | sudo chpasswd

#echo "Creating a Nabi account with password nabi123"
#sudo usermod -aG sudo nabi
#sudo useradd -m -d /home/nabi -s /bin/bash -g root -G sudo -u 2000 nabi
#echo 'nabi:nabi123' | sudo chpasswd
#Update universe repository
sudo apt install software-properties-common
# Add universe repository if not already added
if ! grep -q "^deb .* universe" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    echo "Adding universe repository"
    sudo add-apt-repository universe
else
    echo "Universe repository already exists"
fi  
#echo "Updating universe repository" 
#sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe restricted multiverse"
#sudo apt update

# Ensure installation of dos2unix
sudo apt-get install -y dos2unix
# dos2unix Kubernets_Worker_preparation_Join.sh

echo "Installing necessary applications for Kubernetes PODS"
# Set DNS nameserver
#echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Install applications
sudo apt-get update
#This suppresses all interactive prompts (including service restarts):
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
sudo apt-get install -y sudo sed curl vim joe snmpd snmp openssh-* 
sudo apt-get clean
sleep 3

##Networking Service**
sudo apt-get install netplan.io systemd-networkd systemd-resolved
echo "Disable and Remove Conflicting Network Managers"
sudo systemctl disable --now networking NetworkManager
sudo apt purge -y ifupdown network-manager

##Networking & Troubleshooting Tools**
# Install networking and troubleshooting tools
echo "Installing Networking and Troubleshooting tools"
sudo apt-get install -y iproute2 net-tools iputils-ping iputils-tracepath iputils-arping iputils-clockdiff \
tcpdump nmap traceroute mtr telnet ethtool whois bridge-utils vlan arp-scan iptraf-ng \
hping3 fping netcat-openbsd nethogs
sleep 3

##iperf3 you have to install manually

##Monitoring + Performance
echo "Installing Network Monitoring and performance tools"
sudo apt-get install -y lsof sysstat bmon iftop dstat htop atop
sleep 3

### Install additional tools for VMWARE 
echo "Installing VM tools"
sudo apt-get install -y open-vm-tools
sleep 3

# Create mount point
sudo mkdir -p /mnt/hgfs
sleep 3

# Update fstab for autostart
echo ".host:/ /mnt/hgfs fuse.vmhgfs-fuse allow_other 0 0" | sudo tee -a /etc/fstab
sudo systemctl enable open-vm-tools
sudo systemctl restart open-vm-tools

# Check mount point
echo "Mount Point check"
ls -al /mnt/hgfs/
##DPDK If you need coments out from next line. 
##sudo apt-get install -y build-essential linux-headers-$(uname -r) meson ninja-build pkg-config libnuma-dev libhugetlbfs-dev libibverbs-dev libdpdk-dev dpdk-dev librdmacm-dev libssl-dev libcap-ng-dev libelf-dev ethtool pciutils python3-pyelftools libfdt-dev libpcap-dev libisal-dev joe wget git numactl 
echo "End of bash script"