#!/bin/bash
dockerid=`docker ps | grep mapservermr | cut -f1 -d' '`
echo id docker $dockerid
docker exec -t -i $dockerid bash
exit 0
