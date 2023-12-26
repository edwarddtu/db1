#!/bin/bash
echo "Establishing communication to the Huzzah32 board"
while true; do
#    socat -v -x pty,link=/dev/ttyS0,waitslave,raw,user=root,group=dialout,mode=666 TCP:host.docker.internal:12345
    socat -v -x -b 8192 pty,link=/dev/ttyS0,waitslave,raw,user=root,group=dialout,mode=666 TCP:host.docker.internal:12345
    echo "Serial port closed, reconnecting..."
    sleep 1
done
