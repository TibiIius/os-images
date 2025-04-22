ARG IMAGE_MAJOR=${IMAGE_MAJOR:-"latest"}
ARG IMAGE_FLAVOUR=${IMAGE_FLAVOUR:-"base"}
ARG IMAGE_KIND=${IMAGE_KIND:-"main"}
ARG BASE_IMAGE="ghcr.io/ublue-os/${IMAGE_FLAVOUR}-${IMAGE_KIND}"

FROM ${BASE_IMAGE}:${IMAGE_MAJOR}

ARG IMAGE_MAJOR
ENV IMAGE_MAJOR=${IMAGE_MAJOR}
ARG IMAGE_FLAVOUR
ENV IMAGE_FLAVOUR=${IMAGE_FLAVOUR}
ARG IMAGE_KIND
ENV IMAGE_KIND=${IMAGE_KIND}

COPY etc/ /etc/
COPY usr/ /usr/

COPY /nvidia /tmp/nvidia
RUN if [[ "${IMAGE_KIND}" == "nvidia" ]]; then mv /tmp/nvidia/**/* / && \
  ostree container commit; fi

RUN chmod +x /usr/libexec/firstboot/run /usr/libexec/firstboot/scripts.d/*.sh && \
  ostree container commit

# Platformio Udev rules
RUN curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules -o /etc/udev/rules.d/99-platformio-udev.rules && \
  ostree container commit

# Add Docker repo
RUN curl -L https://download.docker.com/linux/fedora/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo && \
  rpm-ostree cleanup -m && \
  ostree container commit

# Fix laggy mouse cursor under Wayland (allows mouse cursor to update independent of the rest of the screen)
# Also, setting MUTTER_DEBUG_FORCE_KMS_MODE is required for GNOMR VRR to work properly
RUN if [[ ${IMAGE_FLAVOUR} = "silverblue" ]]; then echo MUTTER_DEBUG_ENABLE_ATOMIC_KMS=0 >> /etc/environment && \
  echo MUTTER_DEBUG_FORCE_KMS_MODE=simple >> /etc/environment; fi

# Enable HDR
RUN if [[ ${IMAGE_FLAVOUR} = "kinoite" ]]; then echo KWIN_DRM_ALLOW_NVIDIA_COLORSPACE=1 >> /etc/environment; fi

# Add `disk` group to the system
RUN grep -E '^disk:' /usr/lib/group >> /etc/group

# hadolint ignore=SC2115
RUN PKGS="google-noto-sans-cjk-fonts google-noto-serif-cjk-fonts"; [ ${IMAGE_MAJOR} -lt 41 ] && PKGS_REMOVE="${PKGS_REMOVE} power-profiles-daemon"; [ ${IMAGE_FLAVOUR} = "silverblue" ] && PKGS="gnome-tweaks"; \
  rpm-ostree override remove firefox firefox-langpacks toolbox ${PKGS_REMOVE} && \
  rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
  # Install Veracrypt
  rpm-ostree install https://launchpad.net/veracrypt/trunk/1.26.14/+download/veracrypt-1.26.14-Fedora-40-x86_64.rpm && \
  rpm-ostree install \
  distrobox \
  gcc mold \
  flatpak-builder \
  zsh \
  libratbag-ratbagd \
  openssl \
  steam-devices \
  nautilus-python \
  p7zip \
  smartmontools \
  tuned tuned-ppd tuned-utils tuned-utils-systemtap tuned-profiles-atomic \
  ${PKGS} \
  virt-install libvirt-daemon-config-network libvirt-daemon-kvm qemu-kvm virt-manager virt-viewer guestfs-tools python3-libguestfs virt-top \
  vagrant vagrant-libvirt \
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
  openrgb-udev-rules i2c-tools libi2c libi2c-devel && \
  if [ ! -f /etc/alternatives/ld ]; then ln -s /usr/bin/ld.bfd /etc/alternatives/ld; fi && \
  if [ ! -f /usr/bin/ld ]; then ln -s /etc/alternatives/ld /usr/bin/ld; fi && \
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

# Add NVIDIA install script only at build time and only if IMAGE_KIND is nvidia
COPY install-nvidia.sh /tmp/install-nvidia.sh

RUN if [[ "${IMAGE_KIND}" == "nvidia" ]]; then chmod +x /tmp/install-nvidia.sh && \
  /tmp/install-nvidia.sh && \
  ostree container commit; fi
