ARG IMAGE_MAJOR

FROM quay.io/fedora-ostree-desktops/silverblue:${IMAGE_MAJOR}

ARG IMAGE_MAJOR=${IMAGE_MAJOR}

COPY etc/ /etc/
COPY usr/ /usr/

RUN chmod +x /usr/libexec/firstboot/run /usr/libexec/firstboot/scripts.d/*.sh && \
  ostree container commit

# Platformio Udev rules
RUN curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules -o /etc/udev/rules.d/99-platformio-udev.rules && \
  ostree container commit

# Add Docker repo
RUN curl -L https://download.docker.com/linux/fedora/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo && \
  rpm-ostree cleanup -m && \
  ostree container commit

# GNOME VRR (from https://github.com/ublue-os/bluefin/pull/481/files)
# Disable on Fedora 40 as we will get VRR with 46 (hopefully)
# hadolint ignore=SC2015
RUN [ "${IMAGE_MAJOR}" -lt "40" ] && \
  { curl -L https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/repo/fedora-"${FEDORA_MAJOR_VERSION}"/kylegospo-gnome-vrr-fedora-"${FEDORA_MAJOR_VERSION}".repo -o /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo && \
  rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:gnome-vrr mutter mutter-common gnome-control-center gnome-control-center-filesystem && \
  rm -f /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo; } || true

# Fix laggy mouse cursor under Wayland (allows mouse cursor to update independent of the rest of the screen)
# Also, setting MUTTER_DEBUG_FORCE_KMS_MODE is required for GNOMR VRR to work properly
RUN echo MUTTER_DEBUG_ENABLE_ATOMIC_KMS=0 >> /etc/environment && \
  echo MUTTER_DEBUG_FORCE_KMS_MODE=simple >> /etc/environment

# Add `disk` group to the system
RUN grep -E '^disk:' /usr/lib/group >> /etc/group

# hadolint ignore=SC2115
RUN PKGS="google-noto-sans-cjk-fonts google-noto-serif-cjk-fonts"; PKGS_REMOVE="google-noto-sans-cjk-vf-fonts google-noto-sans-mono-cjk-vf-fonts google-noto-serif-cjk-vf-fonts default-fonts-cjk-sans default-fonts-cjk-serif default-fonts-cjk-mono"; [ ${IMAGE_MAJOR} -lt 41 ] && PKGS_REMOVE="${PKGS_REMOVE} power-profiles-daemon"; \
  rpm-ostree override remove firefox firefox-langpacks toolbox ${PKGS_REMOVE} && \
  rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
  rpm-ostree install \
  distrobox \
  gcc mold \
  flatpak-builder \
  gnome-tweaks \
  zsh \
  libratbag-ratbagd \
  openssl \
  steam-devices \
  nautilus-python \
  NetworkManager-sstp \
  NetworkManager-sstp-gnome \
  neovim \
  p7zip \
  smartmontools \
  tuned tuned-ppd tuned-utils tuned-utils-systemtap tuned-profiles-atomic \
  ${PKGS} \
  virt-install libvirt-daemon-config-network libvirt-daemon-kvm qemu-kvm virt-manager virt-viewer guestfs-tools python3-libguestfs virt-top \
  vagrant vagrant-libvirt \
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
  ln -s "/usr/share/fonts/google-noto-sans-cjk-fonts" "/usr/share/fonts/noto-cjk" && \
  sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
  systemctl enable rpm-ostreed-automatic.timer && \
  systemctl enable firstboot.service && \
  systemctl enable docker.service && \
  systemctl enable tuned.service && \
  # virt-install needs unbound, but that creates a key in /var/unbound
  # rpm-ostree doesn't like that, so we need to remove it
  rm -rf /var/* && \
  rpm-ostree cleanup -m && \
  ostree container commit
