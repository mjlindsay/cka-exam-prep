# Automated Network Install of Debian using DHCP/TFTP
This folder contains scripts and containers to automatically (hands-free)
install Debian 12 using DHCP and TFTP. As with most things in this
repository, it was primarily a learning experience and may not
be suitable for production use (though, everything has been configured
with security and repeatability in mind).

This is designed to work on x86_64 architectures on UEFI-enabled machines,
though should be adaptable to other architectures.

## Getting Started
### 1. Preparing your TFTP Root Directory
You will need to prepare a TFTP root directory to serve your files. You will need:
- **`initrd.gz`**: This is the ramdisk image for booting Debian.
- **`linux`**: This is the Debian kernel binary.
- **`ipxe.efi` or `snponly.efi`**: The iPXE firmware your system will
    boot from initially.
- **`install.pxe`**: The iPXE script executed after your machine
    downloads the iPXE firmware.
- **`preseed.cfg`**: This is the preseed file that customizes your
    Debian installation.

You can prepare these files yourself, or use the `bootstrap-tftpboot.sh` directory. The `bootstrap-tftpboot.sh` will create a `tftpboot` sub-directory
in the current directory and download/copy initial versions of the required
files. There is a `-f` flag that removes the current `tftpboot` directory if you want a fresh start. The script is commented, and I suggest you read it if you have questions.

You will likely need to customize the `preseed.cfg` file. I recommend
reading the [Debian Installation](#debian-installation) section for more information on this. You may also need to customize `ipxe.cfg`, in which
case you should consult the [iPXE](#ipxe) section of this document.

### 2. Configure dnsmasq    
In this directory, there is a `dnsmasq.conf.example` file that contains some basic configurations for dnsmasq. You should copy this to `dnsmasq.conf`, which will not be tracked by source control. You can include special configurations for your host network here, such as providing static IP assignments or
assigning hostnames to MAC addresses. If you do not need additional
customizations, simply copying the file will suffice.

### 3. Building and Running dnsmasq container
There is a provided `Dockerfile` which builds a container running dnsmasq as
a non-daemon process. The `compose.yaml` file contains a Docker compose definition for running this container. It is set to build the container image from the `Dockerfile` automatically, so you do not need to build and tag it yourself. If you need to make changes to the `Dockerfile`, you will need to run `docker-compose build` to get it to re-build the image followed by `docker restart dnsmasq` to get dnsmasq to take the update configurations..

The service itself can be run using the `docker-compose up -d` command. The `-d` flag runs the container detached from the current shell process. If you need logs, you may run `docker logs dnsmasq` or `docker logs dnsmasq --follow`

## DHCP and TFTP Configuration
This uses [dnsmasq](https://thekelleys.org.uk/dnsmasq/doc.html) for both
DHCP and TFTP functionality. In this repository, a custom Dockerfile and
Docker compose file have been provided for running dnsmasq, though it is
easy to run this as a standalone dnsmasq instance. In fact, DHCP and TFTP
are protocols that are typically not run in containers and you may run
in to issues with protected ports on some platforms (i.e., Docker on
Windows/WSL) that necessitate running dnsmasq as a standalone instance.

This repository does not provide information on installing dnsmasq
on a baremetal machine, though the commands in the Dockerfile should serve
as a good starting point.

### A Security Note on Running a TFTP Server Directly on Your Host
TFTP is not a secure protocol. One of the reasons I wanted to run
my server as a container is because many of the risks of TFTP are
mitigated simply by running it this way. However, if you need or
want to run it on your host machine, you should enable secure
mode, whhich limits access to only the TFTP root directory. It
is not enabled in the container environment as I was running
into an issue with file permissions and decided that it was not
worth messing with. I may attempt to resolve this issue in the future.

### Configuring dnsmasq
dnsmasq is an old program, and its documentation is reminiscent of many
old FOSS applications. The provided example configuration should be a
sufficient starting point, as I built the configuration to work with
my own home network system which uses a TP-Link router + ISP Modem.

If you want to do additional configurations, one of the best resources
is the [dnsmasq.conf.example](https://thekelleys.org.uk/dnsmasq/docs/).
There is a copy available on
[dnsmasq's GitHub](https://github.com/imp/dnsmasq/blob/master/dnsmasq.conf.example)
as well.

## Debian Installation
Configuring Debian for automatic installation was the most difficult
part. I believe many online guides assume knowledge and familiarity
with the system that you may or may not have. I recommend familiarizing
yourself with the documentation listed below before attempting to
make extensive modifications:
- [Official Debian GNU/Linux Installation Images - Chapter 4. Obtaining System Installation Media](https://www.debian.org/releases/stable/amd64/ch04s01.en.html):
    I recommend reading the entire chapter. I attempted to make the
    method described in this work extensively before using iPXE
    firmware.
- [Official Debian GNU/Linux Installation Images - Appendix B. Automating the installation using preseeding](https://www.debian.org/releases/stable/amd64/apbs01.en.html)
    Preseeding is Debian's way to do custom, unattended installs of
    the operating system. The `preseed.example.cfg` file within this
    repository is based on [https://www.debian.org/releases/bookworm/example-preseed.txt](https://www.debian.org/releases/bookworm/example-preseed.txt),
    which is referenced in this appendix. This appendix also
    describes different methods of using the preseed file, which I
    attempted before settling on this.

## iPXE
To me, iPXE was the most difficult to get information on. The
documentation is not always easily findable and navigable. I
ended up building 
- [iPXE - Application Note on Debian Preseeding](https://ipxe.org/appnote/debian_preseed)
- [iPXE - Download and select an executable image](https://ipxe.org/cmd/kernel)
- [iPXE - Build targets](https://ipxe.org/appnote/buildtargets)

### Building iPXE from Source
According to many members of the iPXE forums that I browsed while
putting this together, it is often desirable to build your own
boot firmware from the source code. In fact, I had to do this
for this project as I needed a version of the firmware that
relied on the built-in drivers for my NIC rather than iPXE's
drivers (see the "Problems downloading files and booting with ipxe.efi"
note in the [Errors](#errors) section below).

This sounds scary but it was actually quite an easy process. Most
of the packages I already had installed from previous projects,
and the Makefile made things easy. After being built, I just
needed to copy the compiled firmware. The - [iPXE - Build targets](https://ipxe.org/appnote/buildtargets)
documentation from iPXE provides some good information for this.

If you specifically need to build `snponly` for your system,
this was the exact process I used:
- Clone `https://github.com/ipxe/ipxe.git`
- Navigate to `src` folder
- Run `make bin-x86_64-efi/snponly.efi` (you may need to replace with your architecture)
- Copy `bin-x86_64-efi/snponly.efi` to my TFTP root.

## Errors
Below are some errors I encountered while setting this project up,
and notes on how I resolved them.

- **Secure Boot Failed to Load iPXE Firmware**: You need a signed
    EFI file in order to resolve this. I could not find sufficient
    information on how to self-sign or add keys to my system,
    so I simply disabled Secure Boot. I plan to add this in the
    future.
- **autoexec.ipxe not found**: You can Google this and see some
    interesting discussions. Essentially, the autoexec.ipxe file
    can be included in order to do exactly what we have set up
    the `install.ipxe` script to do, without the need to
    specifically configure our DHCP server to avoid a bootloop.
    Unfortunately, it did not work and would result in the
    machine being unable to load further files from TFTP.
- **Problems downloading files and booting with ipxe.efi**: 
    This is the issue I remember the least about, but I had
    an issue where I could not get my system to boot after
    booting from ipxe.efi. I had to build my own `snponly.efi`
    file from the iPXE source code and use this as the boot
    firmware instead of `ipxe.efi`. YMMV.