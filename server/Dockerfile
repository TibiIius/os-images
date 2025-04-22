ARG IMAGE_MAJOR=${IMAGE_MAJOR:-"testing"}
ARG IMAGE_KIND=${IMAGE_FLAVOUR:-"zfs"}
ARG IMAGE_FLAVOUR=${IMAGE_KIND:-"fedora-coreos"}

FROM ghcr.io/ublue-os/${IMAGE_FLAVOUR}:${IMAGE_MAJOR}-${IMAGE_KIND}

RUN rpm-ostree install \
  borgbackup \
  htop \
  nfs-utils \
  policycoreutils-python-utils \
  powertop \
  smartmontools \
  tmux \
  unzip \
  zsh && \
  systemctl disable firewalld.service && \
  ostree container commit
