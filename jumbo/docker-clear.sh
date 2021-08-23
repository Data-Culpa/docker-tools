#!/bin/bash
#
# Script to shutdown and clear the container.
# 
docker stop dc

docker volume ls
docker volume rm dataculpa-workbench

