ARG IMAGE_MAJOR="${IMAGE_MAJOR:-39}"

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
  # This is certainly a good idea and won't break, it won't break it won't break it won't break
  if [[ ${IMAGE_MAJOR} -eq "39" ]]; then sed -i "s/\$releasever/38/g" /etc/yum.repos.d/docker-ce.repo; fi && \
  rpm-ostree cleanup -m && \
  ostree container commit

RUN FONTS="google-noto-sans-cjk-fonts google-noto-serif-cjk-fonts"; FONTS_REMOVE="google-noto-sans-cjk-vf-fonts"; if [[ ${IMAGE_MAJOR} -eq "39" ]]; then FONTS_REMOVE="${FONTS_REMOVE} google-noto-sans-mono-cjk-vf-fonts google-noto-serif-cjk-vf-fonts default-fonts-cjk-sans default-fonts-cjk-serif default-fonts-cjk-mono"; fi && \
  rpm-ostree override remove firefox firefox-langpacks toolbox ${FONTS_REMOVE} && \
  rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
  rpm-ostree install \
  distrobox \
  flatpak-builder \
  gnome-tweaks \
  zsh \
  libratbag-ratbagd \
  openssl \
  podman-compose \
  steam-devices \
  nautilus-python \
  NetworkManager-sstp \
  NetworkManager-sstp-gnome \
  ${FONTS} \
  virt-install libvirt-daemon-config-network libvirt-daemon-kvm qemu-kvm virt-manager virt-viewer guestfs-tools python3-libguestfs virt-top \
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
  ln -s "/usr/share/fonts/google-noto-sans-cjk-fonts" "/usr/share/fonts/noto-cjk" && \
  sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
  systemctl enable rpm-ostreed-automatic.timer && \
  systemctl enable firstboot.service && \
  systemctl enable docker.service && \
  # virt-install needs unbound, but that creates a key in /var/unbound
  # rpm-ostree doesn't like that, so we need to remove it
  rm -rf /var/* && \
  rpm-ostree cleanup -m && \
  ostree container commit
