#!/bin/bash
file_size=1
file_name=random.bin

size=${1:-$file_size}
name=${2:-$file_name}

echo "Generating random file of size $size KB"
dd if=/dev/urandom of=$name bs=1K count=$size
echo "File $name of size $size KB was generated"

