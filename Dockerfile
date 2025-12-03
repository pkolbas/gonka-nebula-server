FROM python:3.12-slim

ARG NEBULA_VERSION=1.9.3

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates iproute2 && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/nebula && \
    cd /tmp/nebula && \
    wget -q "https://github.com/slackhq/nebula/releases/download/v${NEBULA_VERSION}/nebula-linux-amd64.tar.gz" && \
    tar -xzf "nebula-linux-amd64.tar.gz" && \
    mv nebula /usr/local/bin/nebula && \
    mv nebula-cert /usr/local/bin/nebula-cert && \
    cd / && rm -rf /tmp/nebula

RUN mkdir -p /etc/nebula/pki /app

COPY config-lighthouse.yml /etc/nebula/config.yml

COPY port_proxy.py /app/port_proxy.py
COPY issue-node-cert.sh /usr/local/bin/issue-node-cert.sh
RUN chmod +x /usr/local/bin/issue-node-cert.sh

WORKDIR /app

EXPOSE 4242/udp
EXPOSE 8001-8099
EXPOSE 5001-5099

CMD nebula -config /etc/nebula/config.yml & \
    python /app/port_proxy.py
