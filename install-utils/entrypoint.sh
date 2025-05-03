#!/bin/bash

NETBOOT_ARCHIVE="${NETBOOT_ARCHIVE:-/etc/netboot.tar.gz}"

if [ -f $NETBOOT_ARCHIVE ]; then
    echo "Found archive at $NETBOOT_ARCHIVE"
else
    ARCHIVE_DOWNLOAD_URL="http://http.us.debian.org/debian/dists/bookworm/main/installer-amd64/current/images/netboot/netboot.tar.gz"
    echo "Downloading archive ${ARCHIVE_DOWNLOAD_URL}"

    wget -O $NETBOOT_ARCHIVE $ARCHIVE_DOWNLOAD_URL
fi

echo "Extracting archive to /tftpboot"

TFTPBOOT_BASE_DIR="/tftpboot/"

tar -C $TFTPBOOT_BASE_DIR -xzf $NETBOOT_ARCHIVE

/usr/sbin/in.tftpd --foreground --secure --address=0.0.0.0:69 -v --verbosity 3 --create --port-range 35000:35000 /tftpboot