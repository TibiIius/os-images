ARG IMAGE_MAJOR

FROM ghcr.io/tibiiius/custom-silverblue-base:${IMAGE_MAJOR}

COPY etc/ /etc/

RUN ostree container commit
