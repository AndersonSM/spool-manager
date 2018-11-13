#!/bin/bash

logs_path="/var/local/print-logs"
user=$1
period=$2

echo "Páginas: `awk '$period $user {total += $3} END {print total}' $logs_path` | Arquivos: `grep \"$period $user\" $logs_path | wc -l`"
