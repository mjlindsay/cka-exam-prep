#!/bin/bash

ARCHIVE_DOWNLOAD_URL="http://http.us.debian.org/debian/dists/bookworm/main/installer-amd64/current/images/netboot/netboot.tar.gz"
NETBOOT_ARCHIVE="${NETBOOT_ARCHIVE:-/etc/netboot.tar.gz}"
PRESEED_FILE="${PRESEED_FILE:-/etc/preseed.cfg}"
IPXE_EFI="${IPXE_EFI:-/etc/ipxe.efi}"

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
cp -f "$TMP_NETBOOT_DIR/debian-installer/amd64/initrd.gz" /tftpboot/
cp -f "$TMP_NETBOOT_DIR/debian-installer/amd64/linux" /tftpboot/

# echo "Extracting archive to /tftpboot"

# TFTPBOOT_BASE="/tftpboot/"
# INSTALLER_BASE="${TFTPBOOT_BASE}debian-installer/amd64/"

# echo "Tftpboot base: ${TFTPBOOT_BASE}"
# echo "Installer base: ${INSTALLER_BASE}"
# tar -xzf $NETBOOT_ARCHIVE -C $TFTPBOOT_BASE

# INITRD_GZ="${INSTALLER_BASE}initrd.gz"
# INITRD="${INSTALLER_BASE}initrd"

# if [ -f $PRESEED_FILE ]; then
#     echo "Found preseed file"

#     echo "Copying preseed to tftp root"
#     cp $PRESEED_FILE $TFTPBOOT_BASE

#     if [ -f $INITRD_GZ ]; then
#         echo "Found initrd.gz, injecting preseed file"

#         gunzip "$INITRD_GZ"
#         chmod +w "$INITRD"
#         echo "$PRESEED_FILE" | cpio -H newc -o -A -F "$INITRD"
#         gzip "$INITRD"
#     else
#         echo "Could not find initrd.gz to inject preseed file"
#     fi
# else
#     echo "Skipping preseed injection as file not found at $PRESEED_FILE"
# fi

# echo "Copying grubx64.efi for boot requirements"
# cp "${INSTALLER_BASE}grubx64.efi" "${TFTPBOOT_BASE}grubx64.efi"

# echo "Creating revocations file for boot requirements"
# touch "${TFTPBOOT_BASE}revocations.efi"

# if [ -f $IPXE_FILE ]; then
#     echo "Copying $IPXE_FILE to $TFTPBOOT_BASE"
#     cp $IPXE_FILE $TFTPBOOT_BASE
# fi

dnsmasq --no-daemon