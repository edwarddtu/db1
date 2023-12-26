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


# Export the DB1HOST variable if needed outside the script
export DB1HOST

# Display the value (for verification)
echo "DB1HOST is set to $DB1HOST"


#building the docker with local userID and groupID 
docker build --build-arg HOST_GID=$(id -g) --build-arg HOST_UID=$(id -u) \
  --build-arg DB1HOST=$DB1HOST -f Dockerfile2 -t db1 .





