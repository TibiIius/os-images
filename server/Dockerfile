ARG IMAGE_MAJOR=${IMAGE_MAJOR:-"testing"}
ARG IMAGE_FLAVOUR=${IMAGE_FLAVOUR:-"fedora-coreos"}

FROM ghcr.io/ublue-os/${IMAGE_FLAVOUR}:${IMAGE_MAJOR}

COPY var/ /var/
COPY usr/ /usr/

RUN rpm-ostree install \
  borgbackup \
  htop \
  policycoreutils-python-utils \
  powertop \
  smartmontools \
  tmux \
  unzip \
  zsh && \
  rpm-ostree cleanup -m

RUN systemctl disable firewalld.service && \
  systemctl enable backup-volumes.timer && \
  ostree container commit
