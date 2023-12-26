#!/bin/bash

DESKTOP_DIR=$HOME/Desktop
rm -rf $DESKTOP_DIR/DB1*.app
rm -f "$HOME/Desktop/DB1 dock files"

#removing all docker images and containers

# Stop all running containers
docker stop $(docker ps -a -q)

#Remove all containers
docker rm $(docker ps -a -q)

#Remove all Docker images
docker rmi $(docker images -q)

# Stop Docker.app
osascript -e 'quit app "Docker"'

# Wait until Docker is fully stopped
echo "Quit Docker Desktop app to continue"
while pgrep -f Docker > /dev/null; do sleep 1; done

# Remove Docker application
/Applications/Docker.app/Contents/MacOS/uninstall
#rm -rf ~/Library/Group\ Containers/group.com.docker
#rm -rf ~/Library/Containers/com.docker.docker
#rm -rf ~/.docker

echo "All docker containers and images were erased."
