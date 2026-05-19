#!/bin/bash

source tmp_var.sh

ssh $HOST << EOF

sleep 5

pct exec $JENKINS_CT_ID -- bash -c "
apt update &&
apt install -y openjdk-17-jdk curl &&
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null &&
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list &&
apt update &&
apt install -y jenkins &&

systemctl enable jenkins &&
systemctl start jenkins &&

sleep 30 &&

jenkins-cli plugins install configuration-as-code &&
systemctl restart jenkins
"

pct exec $WEB_CT_ID -- bash -c "
apt update &&
apt install -y nginx &&
echo 'TEST' > /var/www/html/index.html &&
systemctl enable nginx &&
systemctl start nginx
"

pct exec $PROXY_CT_ID -- bash -c "
apt update &&
apt install -y nginx &&
cat > /etc/nginx/sites-available/default <<EOL
server {
    listen 80;
    location / {
        proxy_pass http://$WEB_IP;
    }
}
EOL
systemctl enable nginx &&
systemctl restart nginx
"
EOF