#!/bin/bash

# Detect operating system
OS=$(uname)

# Set DB1HOST based on the operating system
if [ "$OS" = "Darwin" ]; then
    DB1HOST="MAC"
#elif [ "$OS" = "Linux" ]; then
else
    DB1HOST="LIN"
fi
#else
#    echo "Unsupported operating system: $OS"
#    exit 1
#fi

# Export the DB1HOST variable if needed outside the script
export DB1HOST

# Display the value (for verification)
echo "DB1HOST is set to $DB1HOST"


#building the docker with local userID and groupID 
docker build --build-arg HOST_GID=$(id -g) --build-arg HOST_UID=$(id -u) \
  --build-arg DB1HOST=$DB1HOST -f Dockerfile2 -t db1 .

# --add-host db1_vm:127.0.0.1

# Check if the home directory is empty
#if [ -z "$(ls -A $(pwd)/user)" ]; then
#    echo "Home directory is empty. Copying default files..."
#    cp -r $(pwd)/tmp $(pwd)/user1
    #chown -R $(id -u):$(id -g) $(pwd)/user1
#fi



