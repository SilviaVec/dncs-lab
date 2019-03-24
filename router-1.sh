export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
wget -O- https://apps3.cumulusnetworks.com/setup/cumulus-apps-deb.pubkey | apt-key add -
add-apt-repository "deb [arch=amd64] https://apps3.cumulusnetworks.com/repos/deb $(lsb_release -cs) roh-3"
apt-get update
apt-get install -y frr --assume-yes --force-yes
sudo su
ip link set dev eth1 up
ip link add link eth1 name eth1.1 type vlan id 1
ip link add link eth1 name eth1.2 type vlan id 2
ip address add 192.168.137.254/24 dev eth1.1
ip address add 192.168.138.30/27 dev eth1.2
ip link set eth1.1 up
ip link set eth1.2 up
ip address add 192.168.139.1/30 dev eth2
ip link set dev eth2 up
sysctl net.ipv4.ip_forward=1
sed -i "s/\(zebra *= *\).*/\1yes/" /etc/frr/daemons
sed -i "s/\(ospfd *= *\).*/\1yes/" /etc/frr/daemons
service frr restart
service frr status
vtysh -e 'conf t' -e 'router ospf' -e 'redistribute connected' -e 'exit' -e 'interface eth2' -e 'ip ospf area 0.0.0.0' -e 'exit' -e 'exit' -e 'write'
echo " ">>/etc/frr//frr.conf
