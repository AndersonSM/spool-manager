#!/bin/bash

quotas_path="/var/local/print-quotas"
max_quota_path="/var/local/print-max-quota"
max_quota=`cat $max_quota_path`

if ! [ $(id -u) = 0 ]; then
    echo "Esse script deve ser executado pelo root!"
    exit 1
fi

# $1 = user, $2 = new quota
function set_quota(){
    sed -i "s/^\($1\s*=\s*\).*\$/\1$2/" $quotas_path
}

while read -r line; do
    user=`echo "$line" | awk -F "=" '{print $1}'`
    quota=`echo "$line" | awk -F "=" '{print $2}'`
    if [ $quota -ge 0 ]; then
	# cota maior que zero
	set_quota $user $max_quota
    else
	new_quota=`expr $max_quota + $quota`
	# cota atual menor que zero
	if [ $new_quota -ge 0 ]; then
            # nova cota maior que 0
	    set_quota $user $new_quota
	else
            # nova cota menor que 0
	    set_quota $user 0
	fi
    fi
done < $quotas_path
