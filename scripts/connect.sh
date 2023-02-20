#/usr/bin/env bash

script_dir=$(readlink -f $(dirname -- "$0"))
tf_dir=$(readlink -f "$script_dir/..")

keyfile="$script_dir/ssh_key"
statefile="$script_dir/state"

# Update state
cd $tf_dir && terraform show -json > $statefile && cd -

# Extract ip from terraform state
instance_ip=$(jq -r '.values.outputs.public_ip.value' $statefile)

# Set ssh keyfile
rm -f $keyfile
jq -r '.values.outputs.private_key.value' $statefile > $keyfile
chmod 400 $keyfile

# Connect!
ssh -i $keyfile "alpine@$instance_ip"
