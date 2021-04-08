#!/bin/bash
#
# Example script showing the Docker configuration for Data Culpa Validator in 
# a "jumbo" container.
#

#
# The API port is used by the client libraries and connectors to push data into
# Data Culpa Validator.
# 
api_port=7778

#
# The UI port (HTTP) is for web browsers to access the UI.
#
ui_port=8081

#
# The DB host is the host for postgres. Right now we include postgres in the container,
# but of course other topologies are supported and will be documented in the future.
#
db_host="127.0.0.1"

echo "Starting up Data Culpa Validator..."
docker run \
    -d \
    --privileged \
    --rm \
    --name dc \
    --tmpfs /tmp --tmpfs /run --tmpfs /run/lock \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --add-host "dc-postgres:${db_host}" \
    -p ${api_port}:7777 \
    -p ${ui_port}:8080 \
    -it dc
rc=$?

if [ $rc != 0 ]; then
	echo "Error starting container"; 
	exit $rc; 
fi

docker ps --filter name=dc
