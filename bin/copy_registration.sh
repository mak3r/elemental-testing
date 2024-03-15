#!/bin/sh

REGISTRATION=$1
IMAGE=rpi.raw
DEST=$(mktemp -d)

SECTORSIZE=$(sudo sfdisk -J ${IMAGE} | jq '.partitiontable.sectorsize')
DATAPARTITIONSTART=$(sudo sfdisk -J ${IMAGE} | jq '.partitiontable.partitions[1].start')
sudo mount -o rw,loop,offset=$((${SECTORSIZE}*${DATAPARTITIONSTART})) ${IMAGE} ${DEST}
sudo cp ${REGISTRATION}-registration.yaml ${DEST}/livecd-cloud-config.yaml
sudo umount ${DEST}
rmdir ${DEST}