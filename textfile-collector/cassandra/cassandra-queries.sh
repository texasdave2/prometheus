#! /bin/bash
## this is the master list of cql cassandra query files to run
## no direct queries are run in this script
## this script simply tells cassandra to run premade cql files referenced in this file
## rather than point to single files, we run all of them in a cronjob at once


## command queue count query extract data then output in prometheus friendly format for node exporter to pick up
cqlsh -f cassandra-command-queue-count.cql -u CASSANDRA-USER -p CASSANDRA-PASSWORD $HOSTNAME | grep -m 1 -o '[0-9]\+' | xargs echo 'cassandra_command_queue_count' > /var/lib/node_exporter/cassandra_command_queue_count.prom

wait

## command queue distinct endpoint total rows count
cqlsh -f cassandra-distinct-endpoint-count.cql -u CASSANDRA-USER -p CASSANDRA-PASSWORD $HOSTNAME | grep rows | tail -1 | grep -m 1 -o '[0-9]\+' | xargs echo 'cassandra_command_queue_distinct_endpoint_count' > /var/lib/node_exporter/cassandra_distinct_endpoint_count.prom

## place additional queries below this line in the same format as the ones above

wait

## change permissions and ownership of newly created files to openstack cloud-user, group wheel

sudo chown -R cloud-user:wheel /var/lib/node_exporter/ &&
sudo chmod -R 775 /var/lib/node_exporter/

