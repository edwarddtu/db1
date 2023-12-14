#!/bin/bash
esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 write_flash -z 0x1000 /home/tmp/ESP32_GENERIC-20231005-v1.21.0.bin 
echo "The firmware update for you Huzzah32 board is finished!"