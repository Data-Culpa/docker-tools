#!/bin/bash -xe
#
# Example script showing the Docker configuration for Data Culpa Validator in 
# a "jumbo" container.
#
#
# Docker quick help for those who may have forgotten:
# $ docker image ls 
#        list images. This script only useful if you have the 'dc' image load.
# 
# $ docker ps
#        show running containers
#
# $ docker stop dc
#        stop the 'dc' container
#
# $ docker image inspect --format='{{.ContainerConfig.Labels.version}}' 
#        Show the Data Culpa Validator version information

# The name of the container image; 'dc' is our default.
container="dc"

###############################################################################
# Ports
###############################################################################

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
# but other topologies will be documented in the future.
#
db_host="127.0.0.1"


###############################################################################
# Slack - Check the support documentation at support.dataculpa.com for help.
###############################################################################

# Your xoxob token - use your secrets vault to inject it here or place it in a tightly scoped file.
# Since we pass this into the command line, it will be visible on your host ps table if you set it
# here. We recommend setting it elsewhere.
#SLACK_TOKEN=

# 
# The channel you want Validator to post to.
SLACK_CHANNEL_ALARM="general"

[ -z "$SLACK_TOKEN" ] && echo "WARNING: SLACK_TOKEN is empty" >&2
[ -z "$SLACK_CHANNEL_ALARM " ] && echo "WARNING: SLACK_TOKEN is empty" >&2

slack_vars=""
if [ ! -z "$SLACK_TOKEN" -a ! -z "$SLACK_CHANNEL_ALARM" ]; then
    slack_vars="--env SLACK_TOKEN --env SLACK_CHANNEL_ALARM"
fi

###############################################################################
# Persistent storage 
###############################################################################

#
# The persistent data is found in /data in the container.
#
persist=1
docker_volume=${docker_volume:="dataculpa-workbench"}
volume=""
if [ $persist -ne 0 ]; then
    volume=("--mount" "type=volume,source=${docker_volume},target=/data")
else
    echo "WARNING: not persisting storage across container restarts" >&2
fi

echo $volume
set +e
vers=`docker image inspect --format='{{.ContainerConfig.Labels.version}}' $container` 
rc=$?
if [ $rc != 0 ]; then 
    echo "docker image inspect $container failed" >&2
    exit $rc
fi
set -e
echo "Starting up Data Culpa Validator ${vers}..."

docker run \
    -d \
    --privileged \
    --rm \
    --name $container \
    --tmpfs /tmp --tmpfs /run --tmpfs /run/lock \
    ${volume[@]} \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --add-host "dc-postgres:${db_host}" \
    $slack_vars \
    -p ${api_port}:7777 \
    -p ${ui_port}:8080 \
    -it $container
rc=$?

if [ $rc != 0 ]; then
	echo "Error starting container" >&2 
	exit $rc
fi

docker ps --filter name=$container
