#!/bin/bash

# Save the current directory
current_dir=$(pwd)

script_dir=$current_dir

# Get the full path of the current script
parent_dir=$(dirname $current_dir)

# Get the name of the parent directory of the script
proj_dir_name=$(basename $parent_dir)

#cp Dockerfile1 "$current_dir/../"
parent_dir_name=$(basename $current_dir)
echo $parent_dir_name

# Change to the parent directory of the script
cd "$current_dir/../../"

# Run the docker build command with the parent directory name as a build argument
docker build --build-arg PROJ_DIR_NAME="$proj_dir_name" --build-arg PARENT_DIR_NAME="$parent_dir_name" -f "$current_dir/Dockerfile1" -t db1_base .


# Check the exit status of the Docker command
exit_status=$?
if [ $exit_status -ne 0 ]; then
    echo "Docker build failed with exit status $exit_status"
    # Return to the original directory before exiting
    cd "$current_dir"
    exit $exit_status
fi

# Change back to the original directory
cd "$current_dir"

#docker build -f Dockerfile1 -t db1_base .

