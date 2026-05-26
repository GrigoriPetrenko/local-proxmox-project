#!/bin/bash

source tmp_var.sh

ssh $HOST << EOF

pct create $JENKINS_CT_ID $TEMPLATE \
  --hostname $JENKINS_HOSTNAME \
  --memory 1024 \
  --cores 1 \
  --net0 name=eth0,bridge=vmbr0,ip=$JENKINS_IP/24,gw=$GATEWAY \
  --rootfs local-lvm:20

#Last fix
pct set $JENKINS_CT_ID -features nesting=1,keyctl=1
pct set $JENKINS_CT_ID -unprivileged 0

pct start $JENKINS_CT_ID

pct create $WEB_CT_ID $TEMPLATE \
  --hostname $WEB_HOSTNAME \
  --memory 512 \
  --cores 1 \
  --net0 name=eth0,bridge=vmbr0,ip=$WEB_IP/24,gw=$GATEWAY \
  --rootfs local-lvm:4

pct start $WEB_CT_ID

pct create $PROXY_CT_ID $TEMPLATE \
  --hostname $PROXY_HOSTNAME \
  --memory 512 \
  --cores 1 \
  --net0 name=eth0,bridge=vmbr0,ip=$PROXY_IP/24,gw=$GATEWAY \
  --rootfs local-lvm:4

pct start $PROXY_CT_ID

EOF