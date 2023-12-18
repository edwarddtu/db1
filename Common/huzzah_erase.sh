#!/bin/bash
esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash
echo "The Huzzah32 board is returned to factory default!"