ARG IMAGE_MAJOR="${IMAGE_MAJOR:-latest}"

FROM ghcr.io/tibiiius/custom-silverblue-base:${IMAGE_MAJOR}

RUN rpm-ostree install openrgb-udev-rules rEFInd && \
  rpm-ostree cleanup -m && \
  ostree container commit
