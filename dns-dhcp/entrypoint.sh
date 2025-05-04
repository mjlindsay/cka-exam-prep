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
cp /tftpboot/debian-installer/amd64/grubx64.efi /tftpboot/grubx64.efi
touch /tftpboot/revocations.efi

tar -C $TFTPBOOT_BASE_DIR -xzf $NETBOOT_ARCHIVE

dnsmasq --no-daemon