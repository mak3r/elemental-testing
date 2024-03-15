#!/bin/sh

ISO=$1
DEVICE=$2

usage() {
        echo "Usage:"
        echo "$0 <path to iso> <device e.g. /dev/sda>"
        echo ""
        echo "Warning: Make sure you pass the device you really want to overwrite."
        echo "\tIT WILL GET WIPED."
}

# Check that we have 2 arguments
if [ -z "$1" ] || [ -z "$2" ]; then
        usage
fi

# Check that pv is installed
[ -n $(command -v pv) ] && echo "pv is installed. copying to usb .." || (echo "Please install pv to continue."; exit 1)

SIZE=$(find $ISO -printf "%s")

sudo /bin/sh -c "dd if=$ISO ibs=1M status=none | pv -s $SIZE | dd of=$DEVICE obs=1M oflag=direct status=none"
