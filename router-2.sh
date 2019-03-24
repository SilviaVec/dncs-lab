export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
wget -O- https://apps3.cumulusnetworks.com/setup/cumulus-apps-deb.pubkey | apt-key add -
add-apt-repository "deb [arch=amd64] https://apps3.cumulusnetworks.com/repos/deb $(lsb_release -cs) roh-3"
apt-get update
apt-get install -y frr --assume-yes --force-yes
sudo su
ip link set dev eth1 up
ip address add 192.168.140.2/30 dev eth1
ip link set dev eth2 up
ip address add 192.168.139.2/30 dev eth2
sysctl net.ipv4.ip_forward=1
sed -i "s/\(zebra *= *\).*/\1yes/" /etc/frr/daemons
sed -i "s/\(ospfd *= *\).*/\1yes/" /etc/frr/daemons
service frr restart
service frr status
vtysh -e 'conf t' -e 'router ospf' -e 'redistribute connected' -e 'exit' -e 'interface eth2' -e 'ip ospf area 0.0.0.0' -e 'exit' -e 'exit' -e 'write'
echo " ">>/etc/frr//frr.conf