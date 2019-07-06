#!/bin/bash
## script to calculate days remaining in licenses from kubernetes config map
## and format them into prometheus-friendly metrics to be used by
## node exporter textfile collector

license_name_array=( $(sudo kubectl describe cm YOURCONFIGMAP | \
awk '/licenceInfo/ {print $3;}' | \
cut -d '"' -f2) )


license_expire_date_array=( $(sudo kubectl describe cm YOURCONFIGMAP | \
awk '/endTime/ {print $2;}' | \
cut -d '"' -f2) )

for i in "${license_name_array[@]}"
do

  clean_name=$(echo $i | sed -e 's/-//g')

  for j in "${license_expire_date_array[@]}"
  do
        days_remain=$( echo $(( ($(date -d $j +%s) - $(date +%s) )/(60*60*24) )) )
        expire_date=$j
  done

  echo "license_days_remaining_$clean_name $days_remain"

done > /var/lib/node_exporter/license_days.prom

chown cloud-user:wheel /var/lib/node_exporter/license_days.prom &&
chmod 744 /var/lib/node_exporter/license_days.prom


