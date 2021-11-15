FROM debian:buster-slim

# /usr/share/man/man1 required for default-jre-headless install
ARG DEBIAN_FRONTEND=noninteractive
RUN mkdir -p /usr/share/man/man1 \
    && apt update \
    && apt upgrade -y \
    && apt install -y --no-install-recommends \
        curl \
        default-jre-headless \
        libglu1-mesa \
        libxi6 \
        libxrender1 \
    && apt -y autoremove \
    && apt -y clean \
    && rm -rf /tmp/* \
        /var/lib/apt/lists/*

# Available Options
ENV SHOW_GPU="FALSE"
ENV VERBOSE="FALSE"
ENV CACHE_DIR="/tmp/sheepit-cache"
ENV COMPUTE_METHOD=""
ENV CORES=""
ENV EXTRAS=""
ENV GPU=""
ENV HOSTNAME=""
ENV LOGIN=""
ENV MEMORY=""
ENV PASSWORD=""
ENV PRIORITY=""
ENV PROXY=""
ENV RENDERBUCKET_SIZE=""
ENV RENDERTIME=""
ENV REQUEST_TIME=""
ENV SERVER=""
ENV SHARED_ZIP="/sheepit/share"
ENV SHUTDOWN=""
ENV SHUTDOWN_MODE=""
ENV UI=""
ENV CUSTOM=""

ADD docker-sheepit.sh /sheepit.sh


WORKDIR /
VOLUME /sheepit

CMD /bin/bash sheepit.sh
