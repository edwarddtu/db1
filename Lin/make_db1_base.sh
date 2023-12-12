#!/bin/bash

# Save the original directory
original_dir=$(pwd)
# Change directory to the script's location
cd "$(dirname "$0")"

docker build -f Dockerfile1 -t db1_base .

# Return to the original directory
cd "$original_dir"