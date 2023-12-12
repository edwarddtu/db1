#!/bin/bash

DIRECTORY="$(pwd)"/user

if [ -d "$DIRECTORY" ]; then
    echo "Directory exists: $DIRECTORY"
else
    echo "Directory does not exist. Creating: $DIRECTORY"
    mkdir -p "$DIRECTORY"
fi

docker run -it --rm\
  --device=/dev/ttyUSB0:/dev/ttyUSB0 \
  -v "$(pwd)"/user:/home/user/ \
  --net=host \
  --name db1container \
  db1 

#  
#  -h db1_vm \

