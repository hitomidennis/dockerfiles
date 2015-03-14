#
# (C) Copyright 2014 Hardkernel Co,.Ltd
#
#!/bin/sh

BL1=bl1.bin.hardkernel
UBOOT=u-boot.bin

if [ -z $1 ]; then
        echo "usage ./sd_fusing.sh <SD card reader's device file>"
        exit 0
fi

if [ ! -f $BL1 ]; then
        echo "Error: $BL1 does not exist."
        exit 0
fi

if [ ! -f $UBOOT ]; then
        echo "Error: $UBOOT does not exist."
        exit 0
fi

dd if=$BL1 of=$1 bs=1 count=442
dd if=$BL1 of=$1 bs=512 skip=1 seek=1
dd if=$UBOOT of=$1 bs=512 seek=64
sync
echo "Successfully wrote U-Boot to $1"
