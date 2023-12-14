#!/bin/bash

#cd $HOME/dock

DIRECTORY="$(pwd)"/user

if [ -d "$DIRECTORY" ]; then
    echo "Directory exists: $DIRECTORY"
else
    echo "Directory does not exist. Creating: $DIRECTORY"
    mkdir -p "$DIRECTORY"
fi



#Stoppint the db1container in case it's already running
docker stop db1container

#Now lets see on which serial port is the Huzzah32 board connected
# Initialize HUZZAH as an empty string
HUZZAH=""

# Check if /dev/ttyUSB0 exists
if [ -e "/dev/ttyUSB0" ]; then
    echo "Huzzah32 board found when starting the db1container"
    HUZZAH="--device /dev/ttyUSB0:/dev/ttyUSB0"
# Check if /dev/tty.SLAB_USBtoUART exists
#elif [ -e "/dev/tty.SLAB_USBtoUART" ]; then
#    echo "Huzzah32 board found on a MAC computer when starting the db1container"
#    HUZZAH="--device=/dev/tty.SLAB_USBtoUART:/dev/ttyUSB0"
#    #HUZZAH="--device /dev/tty.usbserial-017473C3:/dev/ttyUSB0"
#    echo "$HUZZAH"
else
    echo "!!!!Huzzah32 board NOT found!!! Starting the db1container without Huzzah32!!!!"
    sleep 1
fi


docker run -it --rm\
  -v "$(pwd)"/user:/home/user/ \
  -p 127.0.0.1:8080:8080 \
  $HUZZAH \
  --net=host \
  --name db1container \
  db1 

#  --device=/dev/ttyUSB0:/dev/ttyUSB0 \
#  -h db1_vm \

