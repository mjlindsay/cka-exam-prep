#!/bin/bash

###############################################################################
# Bootstrap Script
###############################################################################
# This is a basic script that downloads and moves the necessary files into a
# ./tftpboot directory inside this folder. Additional customiaztion will be
# necessary once bootstraped; for example, the preseed file will likely
# need to include any SSH public keys and specific packages.

if [[ ("$1" -eq "--force" || "$1" -eq "-f") && -d $TFTPBOOT_DIR ]]; then
    echo "force overwrite flag specified, removing tftpboot directory"
    rm -rf $TFTPBOOT_DIR
fi

mkdir -p ./tftpboot

###############################################################################
# Debian Netboot Files
###############################################################################
ARCHIVE_DOWNLOAD_URL="http://http.us.debian.org/debian/dists/bookworm/main/installer-amd64/current/images/netboot/netboot.tar.gz"
TFTPBOOT_DIR="./tftpboot"
NETBOOT_ARCHIVE="${NETBOOT_ARCHIVE:-./netboot.tar.gz}"
INITRD_GZ="$TFTPBOOT_DIR/initrd.gz"
NETBOOT_KERNEL="$TFTPBOOT_DIR/linux"

if [ -f $NETBOOT_ARCHIVE ]; then
    echo "Found archive at $NETBOOT_ARCHIVE"
else
    echo "Downloading archive ${ARCHIVE_DOWNLOAD_URL}"

    wget -O $NETBOOT_ARCHIVE $ARCHIVE_DOWNLOAD_URL
fi

echo "Extracting initrd and kernel from netboot archive"
TMP_NETBOOT_DIR=/tmp/netboot/
mkdir $TMP_NETBOOT_DIR

tar -C /tmp/netboot -xzf $NETBOOT_ARCHIVE
cp -f "$TMP_NETBOOT_DIR/debian-installer/amd64/initrd.gz" $INITRD_GZ
cp -f "$TMP_NETBOOT_DIR/debian-installer/amd64/linux" $NETBOOT_KERNEL

rm -rf $TMP_NETBOOT_DIR

PRESEED_SOURCE_FILE="${PRESEED_FILE:-./preseed.example.cfg}"
PRESEED_DEST_FILE="$TFTPBOOT_DIR/preseed.cfg"

cp $PRESEED_SOURCE_FILE $PRESEED_DEST_FILE

###############################################################################
# Copy iPXE Firmware &  Scripts
###############################################################################
cp *.efi "$TFTPBOOT_DIR/"

IPXE_SCRIPT="${PRESEED_FILE:-./install.ipxe}"
cp $IPXE_SCRIPT "$TFTPBOOT_DIR/"