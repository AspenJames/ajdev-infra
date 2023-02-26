#!/usr/bin/env bash

script_dir=$(readlink -f "$(dirname -- "$0")")
tf_dir=$(readlink -f "$script_dir/..")

keyfile="$script_dir/ssh_key"

# Update state
TFSTATE=$(cd "$tf_dir" && terraform show -json)

# Extract ip from terraform state
instance_ip=$(echo "$TFSTATE"|jq -r '.values.outputs.public_ip.value')

# Set ssh keyfile
rm -f "$keyfile"
echo "$TFSTATE"|jq -r '.values.outputs.private_key.value' - > "$keyfile"
chmod 400 "$keyfile"

# Connect!
echo -e "Connecting...:\n\t$ ssh -i \"$keyfile\" \"alpine@$instance_ip\""
ssh -i "$keyfile" "alpine@$instance_ip"
