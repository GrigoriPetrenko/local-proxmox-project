#!/bin/bash

source tmp_var.sh
echo "$HOST"

ssh -T $HOST << EOF

echo "SCRIPT START"

get_ctid_by_name() {
    pct list | awk -v name="\$1" '$3 == name {print \$1}'
}

for name in "\${WEB_HOSTNAMES[@]}"; do
    id=\$(get_ctid_by_name "\$name")

    if [ -n "\$id" ]; then
        pct stop "\$id" 2>/dev/null
        pct destroy "\$id" 2>/dev/null
    fi
done

echo "SCRIPT END"

EOF