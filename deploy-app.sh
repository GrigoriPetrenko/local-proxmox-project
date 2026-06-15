#!/bin/bash
set -e

source tmp_var.sh

echo "=== UPLOAD DOCKERFILE TO PROXMOX ==="
scp Dockerfile $HOST:/tmp/Dockerfile
echo "=== UPLOAD JENKINS CASC TO PROXMOX ==="
scp jenkins-casc.yaml $HOST:/tmp/jenkins-casc.yaml
echo "=== UPLOAD Seed JOB TO PROXMOX ==="
scp seed.groovy $HOST:/tmp/seed.groovy

ssh "$HOST" << EOF
set -e

echo "=== START DEPLOYMENT ==="
sleep 15

echo "=== COPY JENKINS CASC TO LXC ==="

pct exec $JENKINS_CT_ID -- mkdir -p /opt
pct push $JENKINS_CT_ID /tmp/jenkins-casc.yaml /opt/jenkins-casc.yaml
pct exec $JENKINS_CT_ID -- mkdir -p /opt/jenkins
pct push $JENKINS_CT_ID /tmp/Dockerfile /opt/jenkins/Dockerfile

echo "=== COPY Seed JOB CASC TO LXC ==="
pct push $JENKINS_CT_ID /tmp/seed.groovy /opt/jenkins/seed.groovy

echo "=== INSTALL DOCKER ==="

pct exec $JENKINS_CT_ID -- bash -c "
apt update &&
apt install -y docker.io &&
systemctl enable docker &&
systemctl restart docker
"

echo "=== BUILD JENKINS IMAGE WITH PLUGINS ==="

pct exec $JENKINS_CT_ID -- bash -c "
cd /opt/jenkins &&
docker build -t my-jenkins .
"

echo "=== RUN JENKINS ==="

pct exec $JENKINS_CT_ID -- bash -c "
docker volume create jenkins_home || true

docker rm -f jenkins || true

docker run -d \
  --name jenkins \
  --restart unless-stopped \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /opt/jenkins-casc.yaml:/var/jenkins_home/casc.yaml \
  -e CASC_JENKINS_CONFIG=/var/jenkins_home/casc.yaml \
  -v /opt/jenkins/seed.groovy:/var/jenkins_home/seed.groovy \
  my-jenkins
"

echo "=== WAIT FOR JENKINS ==="
sleep 60

echo "JENKINS PASSWORD:"
#pct exec $JENKINS_CT_ID -- cat /var/lib/jenkins/secrets/initialAdminPassword
#pct exec $JENKINS_CT_ID -- docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
pct exec $JENKINS_CT_ID -- docker ps

echo "=== INSTALL WEB ==="

pct exec $WEB_CT_ID -- bash -c "
apt update &&
apt install -y nginx"

scp $HOST:/var/tmp/index.html /tmp/index.html
pct push $WEB_CT_ID /tmp/index.html /var/www/html/index.html

pct exec $WEB_CT_ID -- bash -c "
systemctl enable nginx &&
systemctl restart nginx
"

echo "=== INSTALL PROXY ==="

pct exec $PROXY_CT_ID -- bash -c "
apt update &&
apt install -y nginx &&
cat > /etc/nginx/conf.d/proxy.conf <<EOL
server {
    listen 80 default_server;
    server_name _;

    location / {
        proxy_pass http://$WEB_IP;
    }

    location /jenkins/ {
        proxy_pass http://$JENKINS_IP:8080/;
    }
}
EOL

rm -f /etc/nginx/sites-enabled/default || true
systemctl enable nginx &&
systemctl restart nginx
"

echo "=== DEPLOYMENT DONE ==="

EOF