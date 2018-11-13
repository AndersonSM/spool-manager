#!/bin/bash

set -e

if ! [ $(id -u) = 0 ]; then
    echo "Esse script deve ser executado pelo root!"
    exit 1
fi

user=`/usr/bin/logname`
options="$@"
copies=1
filename="${@: -1}"
filewc=`wc $filename -lc`
lines=`echo $filewc | awk '{print $1}'` 
filesize=`echo $filewc | awk '{print $2}'`
total_pages=0

while [ -n "$1" ]; do # while loop starts
    case "$1" in
        -n) copies=$2 # verify number of copies
	    shift
	    ;;
    esac
    shift
done

quotas_path="/var/local/print-quotas"
logs_path="/var/local/print-logs"

# $1 = user, $2 = new quota
function set_quota(){
    sed -i "s/^\($1\s*=\s*\).*\$/\1$2/" $quotas_path
}

# $1 = pages, $2 = file name
function log(){
    echo "`date +\%m/%Y` $user $1 $2" | tee --append $logs_path
}

function calculate_total_pages(){
    # verify file size
    total_pages=$(echo "($filesize+3600-1)/3600" | bc)
    # verify lines
    pages_by_line=$(echo "($lines+60-1)/60" | bc)
    if [ $pages_by_line -gt $total_pages ]; then
	total_pages=$pages_by_line
    fi
    total_pages=`expr $total_pages \* $copies`
}

function verify_user_permission(){
    source $quotas_path
    echo $1
    if [ ${!user} -gt 0 ]; then
	# call lp
	lp $options
	log $total_pages $filename
	# update quota for user
	updated_quota=`expr ${!user} - $total_pages`
	echo "Cota restante: $updated_quota"
	set_quota $user $updated_quota
    else
	echo "Cota excedida!"
    fi
}

calculate_total_pages
verify_user_permission
