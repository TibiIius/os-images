ARG IMAGE_MAJOR="${IMAGE_MAJOR:-38}"

FROM quay.io/fedora-ostree-desktops/silverblue:${IMAGE_MAJOR}

COPY etc/ /etc/
COPY usr/ /usr/

RUN chmod +x /usr/libexec/firstboot/run /usr/libexec/firstboot/scripts.d/*.sh && \
  ostree container commit

# Platformio Udev rules
RUN curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules && \
  ostree container commit

RUN rpm-ostree override remove firefox firefox-langpacks toolbox && \
  rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/{fedora-{cisco-openh264,modular,updates-modular},rpmfusion-free{,-updates}}.repo && \
  rpm-ostree install \
  distrobox \
  gnome-tweaks \
  zsh \
  libratbag-ratbagd \
  openssl \
  podman-compose \
  steam-devices \
  google-noto-serif-cjk-vf-fonts google-noto-sans-cjk-fonts google-noto-serif-cjk-fonts google-noto-sans-cjk-jp-fonts google-noto-serif-cjk-jp-fonts \
  virt-install libvirt-daemon-config-network libvirt-daemon-kvm qemu-kvm virt-manager virt-viewer guestfs-tools python3-libguestfs virt-top && \
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-nonfree{,-updates}.repo && \
  sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
  systemctl enable rpm-ostreed-automatic.timer && \
  systemctl enable firstboot.service && \
  # virt-install needs unbound, but that creates a key in /var/unbound
  # rpm-ostree doesn't like that, so we need to remove it
  rm -rf /var/* && \
  rpm-ostree cleanup -m && \
  ostree container commit
