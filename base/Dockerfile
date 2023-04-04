ARG IMAGE_MAJOR="${IMAGE_MAJOR:-38}"

FROM quay.io/fedora-ostree-desktops/silverblue:${IMAGE_MAJOR}
# See https://pagure.io/releng/issue/11047 for final location


COPY etc/ /etc/
COPY usr/ /usr/

RUN chmod +x /usr/libexec/firstboot/run /usr/libexec/firstboot/scripts.d/*.sh && \
  ostree container commit

RUN rpm-ostree override remove firefox firefox-langpacks toolbox && \
  rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/{fedora-{cisco-openh264,modular,updates-modular},rpmfusion-free{,-updates}}.repo && \
  rpm-ostree install distrobox gnome-tweaks zsh libratbag-ratbagd openssl podman-compose steam-devices && \
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-nonfree{,-updates}.repo && \
  sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
  systemctl enable rpm-ostreed-automatic.timer && \
  systemctl enable firstboot.service && \
  rpm-ostree cleanup -m && \
  ostree container commit
