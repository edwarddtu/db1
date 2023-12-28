#!/bin/bash
BUFFER_SIZE=1048576
echo "Establishing communication to the Huzzah32 board"
while true; do
#    socat -v -x pty,link=/dev/ttyS0,waitslave,raw,user=root,group=dialout,mode=666 TCP:host.docker.internal:12345
    socat -v -x -b $BUFFER_SIZE pty,link=/dev/ttyS0,waitslave,raw,user=root,group=dialout,mode=666 TCP:host.docker.internal:12345
    echo "Serial port closed, reconnecting..."
    sleep 1
done
