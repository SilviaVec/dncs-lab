# DESIGN OF NETWORKS AND COMMUNICATION SYSTEM ASSIGNMENT(2018-2019)
Project by Vecchietti Silvia and Emanuele Riccardo Gallo.

# ASSIGMENT
Design a functioning network where any host configured and attached to router-1 (through switch) can browse a website hosted on host-2-c.
Limitations and specific requirement:
1. Up to 130 hosts in the same subnet of host-1-a
2. Up to 25 hosts in the same subnet of host-1-b
3. Consume as few IP addresses as possible

The network configuration is:
```

        +-----------------------------------------------------+
        |                                                     |
        |                                                     |eth0
        +--+--+                +------------+             +------------+
        |     |                |            |             |            |
        |     |            eth0|            |eth2     eth2|            |
        |     +----------------+  router-1  +-------------+  router-2  |
        |     |                |            |             |            |
        |     |                |            |             |            |
        |  M  |                +------------+             +------------+
        |  A  |                      |eth1                    |eth1
        |  N  |                      |                        |
        |  A  |                      |                        |
        |  G  |                      |                     +--+-------+
        |  E  |                      |eth1                 |          |
        |  M  |            +-------------------+           |          |
        |  E  |        eth0|                   |           | host-2-c |
        |  N  +------------+      SWITCH       |           |          |
        |  T  |            |                   |           |          |
        |     |            +-------------------+           +----------+
        |  V  |               |eth2         |eth3               |eth0
        |  A  |               |             |                   |
        |  G  |               |             |                   |
        |  R  |               |eth1         |eth1               |
        |  A  |        +----------+     +----------+            |
        |  N  |        |          |     |          |            |
        |  T  |    eth0|          |     |          |            |
        |     +--------+ host-1-a |     | host-1-b |            |
        |     |        |          |     |          |            |
        |     |        |          |     |          |            |
        ++-+--+        +----------+     +----------+            |
        | |                              |eth0                  |
        | |                              |                      |
        | +------------------------------+                      |
        |                                                       |
        |                                                       |
        +-------------------------------------------------------+


```

# Requirements
 1. 10GB disk storage
 2. 2GB free RAM
 3. Virtualbox
 4. Vagrant (https://www.vagrantup.com)
 5. Internet
 
VirtualBox is basically inception for computer. You can use VirtualBox to run entire sandboxed operating systems with your own computer.
Vagrant is a software that is used to manage a development environment. Through the command line, you can, for example, grab any available OS, install it, configure it, run it, work inside of it and shut it down.
 
# OUR WORK 

# Ip address
After the installation of vitualbox and vagrant we clone the repository to the following website: https://github.com/dustnic/dncs-lab.
First of all we thought about the network configuration and how to choose ip addresses.
We have assigned ip addresses in this way (When possible the first available ip adress is used to the host and the last for the router)
```
	router-1                  eth1.1: 192.168.137.254/24    eth1.2: 192.168.138.30/27	eth2: 192.168.139.1/30
	router-2                  eth1:   192.168.140.2/30	    eth2: 192.168.139.2/30
	host-1-a                  eth1:   192.168.137.1/24 	
	host-1-b                  eth1:   192.168.138.1/27	
	host-2-c                  eth1:   192.168.140.1/30	

```

We have three subnettings:
1. Subnetting with host-1-a, host-1-b, switch and router-1. We split it in two VLANs: VLAN 1 for router-1 and host-1-a and VLAN 2 for router-1 and host-1-b. 
2. Subnetting with router-1 and router-2.
3. Subnetting with router-2 and host-2-c.
The ip addresses have been calculated in order to respect the requests.
Regarding this calculation we have taken into account that every subnettings have two reserved ip adresses: the ip adress with all the bits of the host setting on 0 and the ip adress with all the bits of the host setting on 1.
In particoular:
 - the VLAN named VLAN 1 has 8 bits for the hosts and so 24 for the network. The subnet mask is 255.255.255.0. The first and the last ip addresses are reserved so in this subnet we have (2^8) -2 = 254 ip addresses for the hosts.
   We have some more ip adresses than required but it is the only correct solution because if we had chosen 7 bits for hosts: (2^7) -2 = 126 ip addresses which are not enaugh.
 - the VLAN named VLAN 2 has 5 bits for the hosts. The subnet mask is 255.255.255.224. Here we have (2^5)-2= 30 available ip addresses for the hosts.
 - In the subnetting with router-1 and router-2 we use only 2 bits for the hosts. We have 2 ip adresses free so we assigned the first to port eth-2 of router-1 and the second to port eth-2 of router-1.
 - In the last subnetting we also have (2^2)-2 = 2 free ip adresses. The first to port eth-1 of router-2 and the second to port eth-1 of host-2-c.

# host-1-a.sh and host-1-b.sh 
 host-1-a.sh: 
```
 
1. export DEBIAN_FRONTEND=noninteractive
2. apt-get update
3. apt-get install -y tcpdump --assume-yes
4. apt-get install -y curl --assume-yes
5. sudo su
6. ip link set dev eth1 up
7. ip address add 192.168.137.1/24 dev eth1
8. ip route add 192.168.136.0/21 via 192.168.137.254 

```

host-1-b.sh: 
```
 
1. export DEBIAN_FRONTEND=noninteractive
2. apt-get update
3. apt-get install -y tcpdump --assume-yes
4. apt-get install -y curl --assume-yes
5. sudo su
6. ip link set dev eth1 up
7. ip address add 192.168.138.1/27 dev eth1
8. ip route add 192.168.136.0/21 via 192.168.138.30 

```

-Line 4: installation of curl. 
-Line 6: link port eth1 to the switch
-Line 7: assignment the ip address at the port.
-Line 8: assignment of a static route for all the packets that fall into 192.168.136.0/21. 
In the case of host-1-a all this packets have as destination the ip adress of eth1.1 (router 1), In the case of host-1-b all this packets have as destination the ip adress of eth1.2 (router 1).

# switch.sh
```

1. export DEBIAN_FRONTEND=noninteractive
2. apt-get update
3. apt-get install -y tcpdump --assume-yes
4. apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common
5. sudo su
6. ovs-vsctl --if-exists del-br switch
7. ovs-vsctl add-br switch
8. ovs-vsctl add-port switch eth1
9. ovs-vsctl add-port switch eth2 tag=1
10. ovs-vsctl add-port switch eth3 tag=2
11. ip link set dev eth1 up
12. ip link set dev eth2 up
13. ip link set dev eth3 up
14. ip link set ovs-system up
 
 
 ```
 
	-Line 4: installation of openvswitch.
	-Line 7: addition of a bridge called switch.
	-Line 8: addition of a eth1 port.
	-Line 9: addition of a eth2 port tagged 1 (VLAN).
	-Line 10: addition of a eth3 port tagged 2 (VALN).
	-Line 11,12,13: set eth1, eth2 and eth3 up.
	-Line 14: set ovs-system up.
 
# router-1.sh
  ```
  
1. export DEBIAN_FRONTEND=noninteractive
2. apt-get update
3. apt-get install -y tcpdump apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
4. wget -O- https://apps3.cumulusnetworks.com/setup/cumulus-apps-deb.pubkey | apt-key add -
5. add-apt-repository "deb [arch=amd64] https://apps3.cumulusnetworks.com/repos/deb $(lsb_release -cs) roh-3"
6. apt-get update
7. apt-get install -y frr --assume-yes --force-yes
8. sudo su
9. ip link set dev eth1 up
10. ip link add link eth1 name eth1.1 type vlan id 1
11. ip link add link eth1 name eth1.2 type vlan id 2
12. ip address add 192.168.137.254/24 dev eth1.1
13. ip address add 192.168.138.30/27 dev eth1.2
14. ip link set eth1.1 up
15. ip link set eth1.2 up
16. ip address add 192.168.139.1/30 dev eth2
17. ip link set dev eth2 up
18. sysctl net.ipv4.ip_forward=1
19. sed -i "s/\(zebra *= *\).*/\1yes/" /etc/frr/daemons
20. sed -i "s/\(ospfd *= *\).*/\1yes/" /etc/frr/daemons
21. service frr restart
22. service frr status
23. vtysh -e 'conf t' -e 'router ospf' -e 'redistribute connected' -e 'exit' -e 'interface eth2' -e 'ip ospf area 0.0.0.0' -e 'exit' -e 'exit' -e 'write'
24. echo " ">>/etc/frr//frr.conf

```

	-Line 9: link eth1 port to the switch.
	-Line 10,11: creation of two VLANs: eth1 is splitted in eth1.1 and eth1.2. 
	-Line 12,13: assignment the ip address at the ports.
	-Line 14,15: link eth1.1 and eth1.2 port to the switch.
	-Line 16,17: assignment the ip address at the port eth2 and link port to the switch.
	-Line 18,19,20,21,22,23,24: dinamic routing. This lines is used to connect router-1 and router-2.

# router-2.sh

```

1. export DEBIAN_FRONTEND=noninteractive
2. apt-get update
3. apt-get install -y tcpdump apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
4. wget -O- https://apps3.cumulusnetworks.com/setup/cumulus-apps-deb.pubkey | apt-key add -
5. add-apt-repository "deb [arch=amd64] https://apps3.cumulusnetworks.com/repos/deb $(lsb_release -cs) roh-3"
6. apt-get update
7. apt-get install -y frr --assume-yes --force-yes
8. sudo su
9. ip link set dev eth1 up
10. ip address add 192.168.140.2/30 dev eth1
11. ip link set dev eth2 up
12. ip address add 192.168.139.2/30 dev eth2
13. sysctl net.ipv4.ip_forward=1
14. sed -i "s/\(zebra *= *\).*/\1yes/" /etc/frr/daemons
15. sed -i "s/\(ospfd *= *\).*/\1yes/" /etc/frr/daemons
16. service frr restart
17. service frr status
18. vtysh -e 'conf t' -e 'router ospf' -e 'redistribute connected' -e 'exit' -e 'interface eth2' -e 'ip ospf area 0.0.0.0' -e 'exit' -e 'exit' -e 'write'
19. echo " ">>/etc/frr//frr.conf

```

The same of router-1 except that in this case we have only two simple ports eth1 and eth2 and we don't split.

# host-2-c.sh

```

1. export DEBIAN_FRONTEND=noninteractive
2. sudo su
3. apt-get update
4. apt-get install -y apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
5. curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
6. add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
7. apt-get update
8. apt-get install -y docker-ce --assume-yes --force-yes
9. ip link set dev eth1 up
10. ip add add 192.168.140.1/30 dev eth1
11. ip route add 192.168.136.0/21 via 192.168.140.2
12. docker rm $(docker ps -a -q)
13. docker ps
14. docker run --name mywebsite -p 8080:80 -v /home/user/website/:/usr/share/nginx/html:ro -d nginx
15. docker ps
16. echo "<!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Progetto di Silvia e Emanuele</title>
    </head>
    <body>
        <h1>Pagina web</h1>   
    </body>
    </html>" > /home/user/website/index.html

```
  
	-Line 8: installation of docker.
	-Line 9: link eth1 port to the switch.
	-Line 10: assignment the ip address at the port.
	-Line 11: assignment of a static route for all the packets that fall into 192.168.136.0/21.
	-Line 12: delete all the docker containers.
	-Line 14: creation of web server.
	-Line 16: simple html code.

# TEST THE NETWORK
Clone the repository: git clone https://github.com/SilviaVec/dncs-lab
You should be able to launch the lab from within the cloned repo folder.
```
cd dncs-lab
[~/dncs-lab] vagrant up

```
Once you launch the vagrant script, it may take a while for the entire topology to become available.
 - Verify the status of the 6 VMs: we have one machine for all the components of the network.
```

 [dncs-lab]$ vagrant status                                                                                                                                                                
Current machine status:

router-1                  running (virtualbox)
router-2                  running (virtualbox)
switch                    running (virtualbox)
host-1-a                  running (virtualbox)
host-1-b                  running (virtualbox)
host-2-c                  running (virtualbox)

```
In this moment in the virtual box there are the six virtual machies running.

- Once all the VMs are running verify you can log into all of them, open six terminals and use these commands:
`vagrant ssh router-1`
`vagrant ssh router-2`
`vagrant ssh switch`
`vagrant ssh host-1-a`
`vagrant ssh host-1-b`
`vagrant ssh host-2-c`
  
 
Now use 
`sudo su`
With this command you have permissions to execute all the commands we need.

A useful commands is:
`ifconfig`
with this command you can have some informations about the ethernet interfaces.

we can also use the commands `ping` and `curl`

# Example with host-1-a
`vagrant ssh host-1-a`:
```

Welcome to Ubuntu 14.04.3 LTS (GNU/Linux 3.16.0-55-generic x86_64)

 * Documentation:  https://help.ubuntu.com/
Development Environment
 
```

`sudo su`

`ifconfig`:
```

eth0      Link encap:Ethernet  HWaddr 08:00:27:20:c5:44
          inet addr:10.0.2.15  Bcast:10.0.2.255  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fe20:c544/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:8762 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2913 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:7088320 (7.0 MB)  TX bytes:244379 (244.3 KB)

eth1      Link encap:Ethernet  HWaddr 08:00:27:7d:22:05
          inet addr:192.168.137.1  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fe7d:2205/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:20 errors:0 dropped:0 overruns:0 frame:0
          TX packets:28 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:2088 (2.0 KB)  TX bytes:2456 (2.4 KB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:16 errors:0 dropped:0 overruns:0 frame:0
          TX packets:16 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1184 (1.1 KB)  TX bytes:1184 (1.1 KB)
		  
```

ping host-1-b:
`ping 192.168.138.1`:
```

PING 192.168.138.1 (192.168.138.1) 56(84) bytes of data.
64 bytes from 192.168.138.1: icmp_seq=1 ttl=63 time=37.8 ms
64 bytes from 192.168.138.1: icmp_seq=2 ttl=63 time=45.5 ms
64 bytes from 192.168.138.1: icmp_seq=3 ttl=63 time=15.2 ms
64 bytes from 192.168.138.1: icmp_seq=4 ttl=63 time=54.1 ms
64 bytes from 192.168.138.1: icmp_seq=5 ttl=63 time=8.89 ms
64 bytes from 192.168.138.1: icmp_seq=6 ttl=63 time=47.0 ms
^C
--- 192.168.138.1 ping statistics ---
6 packets transmitted, 6 received, 0% packet loss, time 5068ms
rtt min/avg/max/mdev = 8.893/34.805/54.197/16.843 ms
 
```

ping host-2-c:
`ping 192.168.140.1`

```
 
PING 192.168.140.1 (192.168.140.1) 56(84) bytes of data.
64 bytes from 192.168.140.1: icmp_seq=1 ttl=62 time=30.4 ms
64 bytes from 192.168.140.1: icmp_seq=2 ttl=62 time=36.1 ms
64 bytes from 192.168.140.1: icmp_seq=3 ttl=62 time=10.3 ms
64 bytes from 192.168.140.1: icmp_seq=4 ttl=62 time=9.21 ms
64 bytes from 192.168.140.1: icmp_seq=5 ttl=62 time=10.6 ms
64 bytes from 192.168.140.1: icmp_seq=6 ttl=62 time=19.0 ms
^C
--- 192.168.140.1 ping statistics ---
6 packets transmitted, 6 received, 0% packet loss, time 5024ms
rtt min/avg/max/mdev = 9.214/19.301/36.116/10.531 ms 
 
```

`curl 192.168.40.1:8080/docker.html`
This command send a request for "docker.html" on port 8080 of the server running on host-2-c.

```
 
 <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Progetto di Silvia e Emanuele</title>
</head>
<body>
    <h1>Pagina web</h1>   
</body>
</html>
 
```

# Example with host-2-c
`vagrant ssh host-2-c`

```

 Welcome to Ubuntu 14.04.3 LTS (GNU/Linux 3.16.0-55-generic x86_64)

 * Documentation:  https://help.ubuntu.com/
Development Environment

```

`sudo su`

`docker ps -a`

```
 
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                  NAMES
190b9b2e7ed7        nginx               "nginx -g 'daemon of…"   19 minutes ago      Created             0.0.0.0:8080->80/tcp   mywebsite

```





