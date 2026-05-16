#!/bin/bash

source tmp_var.sh

ssh -T "$HOST" << EOF

get_ctid_by_name() {
    pct list | awk -v name="\$1" '\$3 == name {print \$1}'
}

name1="$1"
name2="$2"
name3="$3"

id1=\$(get_ctid_by_name "\$name1")
echo "NAME=\$name1 ID=\$id1"
if [ -n "\$id1" ]; then
    pct stop "\$id1" 2>/dev/null
    pct destroy "\$id1" 2>/dev/null
fi

id2=\$(get_ctid_by_name "\$name2")
echo "NAME=\$name2 ID=\$id2"
if [ -n "\$id2" ]; then
    pct stop "\$id2" 2>/dev/null
    pct destroy "\$id2" 2>/dev/null
fi

id3=\$(get_ctid_by_name "\$name3")
echo "NAME=\$name3 ID=\$id3"
if [ -n "\$id3" ]; then
    pct stop "\$id3" 2>/dev/null
    pct destroy "\$id3" 2>/dev/null
fi

EOF