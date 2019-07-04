#!/bin/bash
## script to calculate days remaining of an application license inside a kubernetes config map
## and format them into prometheus-friendly metrics to be used by
## node exporter textfile collector


license_name_array=( $(sudo kubectl describe cm license-config | \
awk '/licenceInfo/ {print $3;}' | \
cut -d '"' -f2) )


license_expire_date_array=( $(sudo kubectl describe cm license-config | \
awk '/endTime/ {print $2;}' | \
cut -d '"' -f2) )

for i in "${license_name_array[@]}"
do
  for j in "${license_expire_date_array[@]}"
  do
        days_remain=$( echo $(( ($(date -d $j +%s) - $(date +%s) )/(60*60*24) )) )
        expire_date=$j
  done

  echo "license_days_remaining_$i $days_remain"

done
