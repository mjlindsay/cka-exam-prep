FROM debian:bookworm-slim

RUN apt update
RUN apt install -y dnsmasq

EXPOSE 53/udp
EXPOSE 68/udp

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir /tftpboot
RUN chmod -R 777 /tftpboot
RUN chown -R nobody /tftpboot

ENTRYPOINT [ "/entrypoint.sh" ]
