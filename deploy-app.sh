#!/bin/bash
set -e

source tmp_var.sh

ssh "$HOST" << EOF
set -e

echo "=== START DEPLOYMENT ==="
sleep 15

echo "=== INSTALL JENKINS (DEB METHOD) ==="

pct exec $JENKINS_CT_ID -- bash -c "
apt update &&
apt install -y openjdk-17-jre wget ca-certificates &&
cd /root &&
wget -O jenkins.deb https://get.jenkins.io/debian-stable/jenkins_2.492.1_all.deb &&
apt install -y ./jenkins.deb &&
systemctl enable --now jenkins
"

echo "=== DONE ==="

echo "JENKINS PASSWORD:"
pct exec $JENKINS_CT_ID -- cat /var/lib/jenkins/secrets/initialAdminPassword

# echo "=== INSTALL WEB ==="

# pct exec $WEB_CT_ID -- bash -c "
# apt update &&
# apt install -y nginx &&
# echo 'WEB OK' > /var/www/html/index.html &&
# systemctl enable nginx &&
# systemctl restart nginx
# "

# echo "=== INSTALL PROXY ==="

# pct exec $PROXY_CT_ID -- bash -c "
# apt update &&
# apt install -y nginx &&
# cat > /etc/nginx/sites-available/default <<EOL
# server {
#     listen 80;

#     location / {
#         proxy_pass http://$JENKINS_IP:8080;
#     }
# }
# EOL
# systemctl enable nginx &&
# systemctl restart nginx
# "

echo "=== DEPLOYMENT DONE ==="

EOF