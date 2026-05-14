#!/bin/bash

source variables.sh

ssh $HOST << EOF

# STOP OLD CT
pct stop $WEB_CT_ID 2>/dev/null
pct stop $PROXY_CT_ID 2>/dev/null

# REMOVE OLD CT
pct destroy $WEB_CT_ID 2>/dev/null
pct destroy $PROXY_CT_ID 2>/dev/null

EOF