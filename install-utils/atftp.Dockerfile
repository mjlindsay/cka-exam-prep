FROM debian:bookworm-slim

RUN apt update
RUN apt install -y atftpd
RUN apt install -y --reinstall systemd
RUN mkdir /tftpboot
RUN chmod -R 777 /tftpboot
RUN chown -R nobody /tftpboot
RUN systemctl disable atftpd

EXPOSE 69/udp
CMD ["atftpd", "--daemon", "--no-fork", "-v=2", "/tftpboot"]
