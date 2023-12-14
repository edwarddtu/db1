#!/bin/bash

#First we scheck if the docker daemon is running
if ! service docker status > /dev/null 2>&1; then
    echo "Starting Docker daemon..."
    service docker start
else
    echo "Docker daemon is already running."
fi