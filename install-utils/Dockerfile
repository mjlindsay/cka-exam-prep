FROM debian:bookworm-slim

RUN apt update
RUN apt install -y tftpd-hpa
RUN apt install -y --reinstall systemd
RUN systemctl disable tftpd

RUN mkdir /tftpboot
RUN chmod -R 777 /tftpboot
RUN chown -R nobody /tftpboot

EXPOSE 69/udp
CMD ["tftpd", "--foreground", "--secure", "--address=0.0.0.0:69", "/tftpboot"]
