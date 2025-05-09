ARG IMAGE_MAJOR=${IMAGE_MAJOR:-"testing"}
ARG IMAGE_FLAVOUR=${IMAGE_FLAVOUR:-"fedora-coreos"}

FROM ghcr.io/ublue-os/${IMAGE_FLAVOUR}:${IMAGE_MAJOR}

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

# When there are updates, not only download them, also restart the server automatically
RUN sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=apply/' /etc/rpm-ostreed.conf

RUN systemctl disable firewalld.service && \
  systemctl disable zfs-import-cache.service && \
  systemctl enable zfs-import-scan.service && \
  systemctl enable backup-volumes.timer && \
  ostree container commit
