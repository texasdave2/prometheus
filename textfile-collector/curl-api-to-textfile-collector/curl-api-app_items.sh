#!/bin/bash
## script to iterate and export text from API
## and format them into prometheus-friendly metrics to be used by
## node exporter textfile collector

## need API credentials
username=
password=

app_url=YOUR-API.com

IFS=""
app_items_array=( $(curl -u $username:$password -X GET --header "Accept: application/json" "https://$app_url/rest/about/" \
| sed -e 's/,"/\n/g;s/\"//g;s/{//g;s/}//g;s/:/ /g;'\
| grep -Ei "license|current" \
| grep -Ev "^licenseInfo |^licenseType |^licenseExpirationDate " \
| sed -e 's/^/app/') )

date_raw=( $(curl -u $username:$password -X GET --header "Accept: application/json" "https://$app_url/rest/about/" \
| sed -e 's/,"/\n/g;s/\"//g;s/{//g;s/}//g;s/:/ /g;'\
| grep 'licenseExpirationDate' \
| sed -e 's,^[^ ]* ,,;s, ,:,4;s, ,:,4') )

days_remain=$( echo $(( ($(date -d $date_raw +%s) - $(date +%s) )/(60*60*24) )) )

for i in "${app_items_array[@]}"
do

  echo "${i}"
done
echo "app_license_days_remaining $days_remain") | tee /var/lib/node_exporter/app_items.prom

chown cloud-user:wheel /var/lib/node_exporter/app_items.prom &&
chmod 755 /var/lib/node_exporter/app_items.prom
