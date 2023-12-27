#!/bin/bash

#Removing all the icons from desktop and application folder
DESKTOP_DIR=$HOME/Desktop
rm -rf $DESKTOP_DIR/DB1*.app
rm -rf $/Applications/DB1*.app
rm -f "$HOME/Desktop/DB1 dock files"


#removing all docker images and containers

# Stop all running containers
docker stop $(docker ps -a -q)

#Remove all containers
docker rm $(docker ps -a -q)

#Remove all Docker images
docker rmi $(docker images -q)

# Remove Docker application
#/Applications/Docker.app/Contents/MacOS/uninstall

echo "All docker containers and images were erased."

uninstall_syslab_serial_driver(){
	if [ -d /System/Library/Extensions/SiLabsUSBDriver.kext ]; then
	sudo kextunload /System/Library/Extensions/SiLabsUSBDriver.kext
	sudo rm -rf /System/Library/Extensions/SiLabsUSBDriver.kext
	fi

	if [ -d /System/Library/Extensions/SiLabsUSBDriver64.kext ]; then
	sudo kextunload /System/Library/Extensions/SiLabsUSBDriver64.kext
	sudo rm -rf /System/Library/Extensions/SiLabsUSBDriver64.kext
	fi

	if [ -d /Library/Extensions/SiLabsUSBDriverYos.kext ]; then
	sudo kextunload /Library/Extensions/SiLabsUSBDriverYos.kext
	sudo rm -rf /Library/Extensions/SiLabsUSBDriverYos.kext
	fi

	if [ -d /Library/Extensions/SiLabsUSBDriver.kext ]; then
	sudo kextunload /Library/Extensions/SiLabsUSBDriver.kext
	sudo rm -rf /Library/Extensions/SiLabsUSBDriver.kext
	fi

	if [ -d /Applications/CP210xVCPDriver.app/Contents/Library/SystemExtensions/com.silabs.cp210x.dext ]; then
	/Applications/CP210xVCPDriver.app/Contents/MacOS/CP210xVCPDriver uninstall
	sudo rm -rf /Applications/CP210xVCPDriver.app
	fi
}

uninstall_syslab_serial_driver

#We try to kill all the processes associated with docker
pkill -9 -f "Docker"


#Removing docker if it was installed using brew
brew remove --cask --force docker

#Removing all the other programs installed with brew
brew remove --force $(brew list)

#Removing brew itself
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"




