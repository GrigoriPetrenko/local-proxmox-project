#!/bin/bash

source tmp_var.sh

ssh $HOST << EOF

sleep 5

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