ARG IMAGE_MAJOR="${IMAGE_MAJOR:-40}"

FROM ghcr.io/tibiiius/custom-silverblue-base:${IMAGE_MAJOR}

COPY etc/ /etc/

RUN rpm-ostree install touchegg && \
  rpm-ostree cleanup -m && \
  ostree container commit
