#!/bin/bash

#cd $HOME/dock

#DIRECTORY="$(pwd)"/user
DIRECTORY=$HOME/dock/user


if [ -d "$DIRECTORY" ]; then
    echo "Directory exists: $DIRECTORY"
else
    echo "Directory does not exist. Creating: $DIRECTORY"
    mkdir -p "$DIRECTORY"
fi


# Name of the container
CONTAINER_NAME="db1container"

# Check if the container is already running
if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "Container $CONTAINER_NAME is already running. Stopping it now..."
    docker stop $CONTAINER_NAME
    echo "Container $CONTAINER_NAME has been stopped."
fi

#Now lets see on which serial port is the Huzzah32 board connected
# Initialize HUZZAH as an empty string
HUZZAH=""

# Check if /dev/ttyUSB0 exists
if [ -e "/dev/ttyUSB0" ]; then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!!!! Huzzah32 board found when starting the db1container !!!!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    HUZZAH="--device /dev/ttyUSB0:/dev/ttyUSB0"
else
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!!!!Huzzah32 board NOT found!!! Starting the db1container without Huzzah32!!!!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    sleep 1
fi

echo "Starting container: $CONTAINER_NAME"

docker run -it --rm\
  -v $DIRECTORY:/home/user/ \
  $HUZZAH \
  --net=host \
  --name $CONTAINER_NAME \
  db1 

#  -p 127.0.0.1:8080:8080 \
