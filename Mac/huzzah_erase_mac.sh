#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Freeing the Serial device in case anybody is using it
# Device to check
DEVICE="/dev/tty.SLAB_USBtoUART"

# Find processes using the device
PIDS=$(lsof $DEVICE | awk 'NR>1 {print $2}')

# Check if any processes were found
if [ -z "$PIDS" ]; then
    echo "No processes are using $DEVICE."
else
    # Kill the processes
    echo "Killing processes using $DEVICE:"
    for PID in $PIDS; do
        echo "Killing process $PID"
        kill -9 $PID
    done
fi

echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!! WARNING! This will erase all the data from the microcontroller        !!!!"
echo "!!!! Make sure that you've backed up all the data from the microcontroller !!!!"
echo "!!!! before you proceed.                                                   !!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "Do you want to continue (yes/no)?"

# Read the user's input
read answer

# Convert the input to lowercase
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

# Check if the input is 'yes'
if [ "$answer" = "yes" ]; then
    echo "OK. We continue"
	esptool.py --chip esp32 --port /dev/tty.SLAB_USBtoUART erase_flash
	echo "The Huzzah32 board is returned to factory default!"
else
    echo "OK. We exit"
fi
