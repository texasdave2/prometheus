
#!/bin/bash
## query rabbit mq pods for unacknowledged messages non zero OR
## number of ready messages are more than 100 for past hour
## and format them into prometheus-friendly metrics to be used by
## node exporter textfile collector


## the code is written to do one single rabbitmq query
#i# take the data and input into and array
## let bash parse it and export to files

mapfile -t messages_data_raw < <( sudo kubectl exec crmq-rabbitmq-0 -- bash -c "rabbitmqctl list_queues name messages_ready messages_unacknowledged" | grep -E "QUEUE1|QUEUE2|QUEUE3")

for i in "${messages_data_raw[@]}"
do

## get the queue name

  queue_name=$(awk '{print $1}' <<< "$i" | sed 's/\./_/g' | sed 's/\-/_/g')

## get the 'message ready' metrics for each message queue name

  messages_ready_count=$(awk '{print $2}' <<< "$i")

## get the 'messages unacknowledged' metrics for each message queue name

  messages_unacknowledged_count=$(awk '{print $3}' <<< "$i")

## print out in prometheus friendly format

  echo "rabbitmq_messages_ready_count_$queue_name $messages_ready_count"
  echo "rabbitmq_messages_unacknowledged_count_$queue_name $messages_unacknowledged_count"

done > /var/lib/node_exporter/crmq_rabbitmq_messages_count.prom

chown cloud-user:wheel /var/lib/node_exporter/crmq_rabbitmq_messages_count.prom &&
chmod 755 /var/lib/node_exporter/crmq_rabbitmq_messages_count.prom
