export DEBIAN_FRONTEND=noninteractive
sudo su
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce --assume-yes --force-yes
ip link set dev eth1 up
ip add add 192.168.140.1/30 dev eth1
ip route add 192.168.136.0/21 via 192.168.140.2
docker rm $(docker ps -a -q)
docker ps
docker run --name mywebsite -p 8080:80 -v /home/user/website/:/usr/share/nginx/html:ro -d nginx
docker ps

echo "<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Progetto di Silvia e Emanuele</title>
</head>
<body>
    <h1>Pagina web</h1>   
</body>
</html>" > /home/user/website/docker.html

