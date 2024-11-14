ARG IMAGE_MAJOR
ARG IMAGE_FLAVOUR

FROM ghcr.io/tibiiius/custom-${IMAGE_FLAVOUR}-base:${IMAGE_MAJOR}

COPY etc/ /etc/

RUN ostree container commit
