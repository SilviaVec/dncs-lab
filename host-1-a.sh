export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump --assume-yes
apt-get install -y curl --assume-yes
sudo su
ip link set dev eth1 up
ip address add 192.168.137.1/24 dev eth1
ip route add 192.168.136.0/21 via 192.168.137.254 
