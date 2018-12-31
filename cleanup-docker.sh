#!/bin/bash

# remove exited containers:
sudo docker ps --filter status=dead --filter status=exited -aq | xargs -r sudo docker rm -v
    
# remove unused images:
sudo docker images --no-trunc | grep '<none>' | awk '{ print $3 }' | xargs -r sudo docker rmi

# remove unused volumes:
sudo find '/var/lib/docker/volumes/' -mindepth 1 -maxdepth 1 -type d | grep -vFf <(
  sudo docker ps -aq | xargs sudo docker inspect | sudo jq -r '.[] | .Mounts | .[] | .Name | select(.)'
) | xargs -r sudo rm -fr