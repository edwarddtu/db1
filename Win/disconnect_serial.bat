@echo off
usbipd detach -a
usbipd unbind -a

echo "Serial port for Huzzah32 is disconnected from WSL"
pause