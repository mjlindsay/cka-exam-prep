FROM debian:bookworm-slim

RUN apt update
RUN apt install -y dnsmasq

EXPOSE 53/udp
EXPOSE 68/udp

CMD ["dnsmasq", "--no-daemon"]
