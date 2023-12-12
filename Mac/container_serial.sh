#!/bin/bash

while true; do
    #socat pty,link=/dev/ttyUSB0,waitslave,raw,user=root,mode=777 TCP:host.docker.internal:12345
    socat pty,link=/dev/ttyS0,waitslave,raw,user=root,group=dialout,mode=666 TCP:host.docker.internal:12345
    echo "Serial port closed, reconnecting..."
    sleep 1
done
