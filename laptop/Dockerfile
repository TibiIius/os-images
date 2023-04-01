ARG IMAGE_MAJOR="${IMAGE_MAJOR:-38}"

FROM ghcr.io/tibiiius/custom-silverblue-base:${IMAGE_MAJOR}

RUN rpm-ostree install touchegg && \
  rpm-ostree cleanup -m && \
  ostree container commit
