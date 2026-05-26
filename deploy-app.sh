#!/bin/bash
set -e

source tmp_var.sh

ssh "$HOST" << EOF
set -e

echo "=== START DEPLOYMENT ==="
sleep 15

echo "=== INSTALL DOCKER ==="

pct exec $JENKINS_CT_ID -- bash -c "
apt update &&
apt install -y docker.io &&
systemctl enable docker &&
systemctl restart docker
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
  jenkins/jenkins:lts
"

echo "=== WAIT FOR JENKINS ==="
sleep 20

echo "JENKINS PASSWORD:"
#pct exec $JENKINS_CT_ID -- cat /var/lib/jenkins/secrets/initialAdminPassword
pct exec $JENKINS_CT_ID -- docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

echo "=== INSTALL WEB ==="

pct exec $WEB_CT_ID -- bash -c "
apt update &&
apt install -y nginx &&
echo 'WEB OK' > /var/www/html/index.html &&
systemctl enable nginx &&
systemctl restart nginx
"

echo "=== INSTALL PROXY ==="

pct exec $PROXY_CT_ID -- bash -c "
apt update &&
apt install -y nginx &&
cat > /etc/nginx/sites-available/default <<EOL
server {
    listen 80;

    location / {
        proxy_pass http://$JENKINS_IP:8080;
    }
}
EOL
systemctl enable nginx &&
systemctl restart nginx
"

echo "=== DEPLOYMENT DONE ==="

EOF