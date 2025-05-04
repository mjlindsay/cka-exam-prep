#!/bin/bash

NETBOOT_ARCHIVE="${NETBOOT_ARCHIVE:-/etc/netboot.tar.gz}"
PRESEED_FILE="${PRESEED_FILE:-/etc/preseed.cfg}"

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

if [ -f $PRESEED_FILE ]; then
    echo "Found preseed file"

    if [-f /tftpboot/debian-installer/initrd.gz ]; then
        echo "Found initrd.gz, injecting preseed file"

        gunzip /tftpboot/debian-installer/amd64/initrd.gz
        chmod +w /tftpboot/debian-installer/initrd
        echo $PRESEED_FILE | cpio -H newc -o -A -F /tftpboot/debian-installer/amd64/initrd.gz
        gzip /tftpboot/debian-installer/amd64/initrd
    else
        echo "Could not find initrd.gz to inject preseed file"
    fi
else
    echo "Skipping preseed injection as file not found at $PRESEED_FILE"
fi

dnsmasq --no-daemon