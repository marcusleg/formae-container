FROM fedora:43

WORKDIR /opt/pel/

ARG TARGETOS
ARG TARGETARCH

ARG FORMAE_VERSION=0.75.4
RUN dnf -y install wget tar ca-certificates && \
    dnf clean all && rm -rf /var/cache/dnf

RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) ARCH_SUFFIX="x8664" ;; \
      arm64) ARCH_SUFFIX="arm64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    wget -q "https://hub.platform.engineering/binaries/pkgs/formae@${FORMAE_VERSION}_linux-${ARCH_SUFFIX}.tgz" -O formae.tgz && \
    tar -xzf formae.tgz && \
    rm formae.tgz

ENV PATH="$PATH:/opt/pel/formae/bin/"

CMD ["formae", "agent", "start"]
