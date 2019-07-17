#! /bin/bash

## this script queries the logstash host and pipes the output to
## prometheus node exporter metrics directory to feed into prometheus data stream

username="USER"
password="PASS"

curl -u "${username}:${password}" -H 'Content-Type: application/json' http://ELASTICHOST.com:9200/YOUR-INDEX/_count -d '{"query": {"bool": {"must": [{"query_string": {"query": "\"QUERY-CONTENTS-HERE\""} },{"range" : {"@timestamp" : {"from" : "2019-07-16T00:00:01","to" : "2019-07-17T23:59:59"}}}]}}}' | jq '.count' | xargs echo "logstash_query_results" > /var/lib/node_exporter/logstash_query_results.prom


chown cloud-user:wheel /var/lib/node_exporter/logstash_query_results.prom &&
chmod 755 /var/lib/node_exporter/logstash_query_results.prom

