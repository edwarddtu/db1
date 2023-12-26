#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

CONTAINER_NAME="db1container"

# Check if Docker daemon is running
if ! docker info >/dev/null 2>&1; then
    echo "Docker daemon is not running. Attempting to start Docker..."

    # Start Docker Desktop using AppleScript
    osascript -e 'tell application "Docker" to activate' &

    # Wait for Docker daemon to start
    echo "Waiting for Docker daemon to start..."
    while ! docker info >/dev/null 2>&1; do
        sleep 1
    done

    echo "Docker daemon is now running."
else
    echo "Docker daemon is already running."
fi

# Check if the container is running
if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "Container $CONTAINER_NAME is already running. We restart it."
    docker stop $CONTAINER_NAME
    docker start $CONTAINER_NAME
else
    # Check if the container exists but is not running
    if [ "$(docker ps -aq -f status=exited -f name=^/${CONTAINER_NAME}$)" ]; then
        echo "Starting the existing container $CONTAINER_NAME."
        docker start $CONTAINER_NAME
    else
        echo "Container $CONTAINER_NAME does not exist. Creating and starting it."
        docker create --name $CONTAINER_NAME -p 8080:8080 -v $SCRIPT_DIR/user:/home/user db1:latest
        docker start $CONTAINER_NAME
    fi
fi

# Wait for the container to be in the "running" state
while [ "$(docker inspect --format="{{.State.Running}}" $CONTAINER_NAME 2>/dev/null)" != "true" ]; do
  echo "Waiting for container $CONTAINER_NAME to start..."
  sleep 0.1
done
sleep 1

open "http://localhost:8080"

# Let's kill the process that starts the container serial
SCRIPT_NAME="container_serial.sh"

# Find the PID of the process
# This command looks for the process running your script and extracts its PID
PID=$(ps aux | grep "$SCRIPT_NAME" | grep -v grep | awk '{print $2}')

# Check if PID is not empty
if [ ! -z "$PID" ]; then
    echo "Killing process with PID: $PID"
    kill $PID

    # Optional: Check if the process is successfully killed
    if kill -0 $PID 2>/dev/null; then
        echo "Process $PID could not be killed. Trying with force kill."
        kill -9 $PID
    else
        echo "Process $PID killed successfully."
    fi
else
    echo "No process found for $SCRIPT_NAME"
fi


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

# Making sure that nobody is using the port for serial connection
# Port to check
PORT=12345

# Find the process ID listening on the port
PID=$(lsof -i TCP:$PORT | awk 'NR>1 {print $2}' | uniq)

# Check if any process was found
if [ -z "$PID" ]; then
    echo "No process is listening on port $PORT."
else
    echo "Killing process $PID listening on port $PORT."
    kill -9 $PID
    sleep 0.1 

    # Optionally, you can check if the process was successfully killed
    if kill -0 $PID 2>/dev/null; then
        echo "Failed to kill process $PID."
    else
        echo "Process $PID killed successfully."
    fi
fi

# Connecting the serial port to the container
#docker exec -u root db1container killall container_serial
#docker exec -u root db1container killall socat
docker exec -u root db1container /home/tmp/container_serial.sh&
serial2container.py


