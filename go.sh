#!/bin/sh

mkdir -p bin


if [[ $(uname) == 'Darwin' ]]; then
  gcc bdu.c -o bdu -lusb-1.0.0 -framework CoreFoundation -framework IOKit -I./include -I/opt/local/include
else
  gcc bdu.c -o bdu -lusb-1.0
fi

arm-elf-gcc -mthumb -c -o bin/payload.o main.c
arm-elf-objcopy -O binary bin/payload.o bin/payload.bin
xxd bin/payload.bin

./bdu

