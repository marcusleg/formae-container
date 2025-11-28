FROM fedora:43 AS builder

WORKDIR /opt/pel/

ARG FORMAE_VERSION=0.75.4
RUN dnf -y install wget tar ca-certificates && \
    dnf clean all && rm -rf /var/cache/dnf
RUN wget -q "https://hub.platform.engineering/binaries/pkgs/formae@${FORMAE_VERSION}_linux-x8664.tgz" -O formae.tgz && \
    tar -xzf formae.tgz && \
    rm formae.tgz
ENV PATH="$PATH:/opt/pel/formae/bin/"

CMD ["formae", "agent", "start"]
