#!/bin/bash

source tmp_var.sh

bash destroy-lxc.sh $JENKINS_HOSTNAME $WEB_HOSTNAME $PROXY_HOSTNAME
bash create-lxc.sh
bash deploy-app.sh