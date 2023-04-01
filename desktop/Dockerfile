ARG IMAGE_MAJOR="${IMAGE_MAJOR:-38}"
ARG BASE_IMAGE="ghcr.io/tibiiius/custom-silverblue-base"

FROM ${BASE_IMAGE}:${IMAGE_MAJOR} as builder

RUN rpm-ostree install \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
  fedora-repos-archive

RUN rpm-ostree install \
        akmods \
        mock \
        xorg-x11-drv-nvidia{,-cuda,-devel,-kmodsrc,-power} \
        binutils \
        kernel-devel-$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')

# I totally know why this is needed
RUN ln -s /usr/bin/ld.bfd /etc/alternatives/ld && ln -s /etc/alternatives/ld /usr/bin/ld

RUN NVIDIA_PACKAGE_NAME="nvidia" \
  KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')" \
  NVIDIA_VERSION="$(basename "$(rpm -q "xorg-x11-drv-nvidia" --queryformat '%{VERSION}-%{RELEASE}')" ".fc$(rpm -E '%fedora')")"  && \ 
  chmod -R 1777 /tmp && \
  chmod -R 1777 /var/tmp && \
  akmods --force --kernels "${KERNEL_VERSION}" --kmod "${NVIDIA_PACKAGE_NAME}" && \
  modinfo /usr/lib/modules/${KERNEL_VERSION}/extra/${NVIDIA_PACKAGE_NAME}/nvidia{,-drm,-modeset,-peermem,-uvm}.ko.xz > /dev/null || \
  (cat /var/cache/akmods/${NVIDIA_PACKAGE_NAME}/${NVIDIA_VERSION}-for-${KERNEL_VERSION}.failed.log && exit 1)

RUN rpm -q "xorg-x11-drv-nvidia" \
  --queryformat '%{EPOCH}:%{VERSION}-%{RELEASE}.%{ARCH}' > /var/cache/akmods/nvidia-full-version.txt

FROM ${BASE_IMAGE}:${IMAGE_MAJOR}

COPY --from=builder /var/cache/akmods /tmp/akmods

RUN KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')" \
  NVIDIA_FULL_VERSION="$(cat /tmp/akmods/nvidia-full-version.txt)" \
  NVIDIA_PACKAGE_NAME="nvidia" && \
  rpm-ostree install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/{fedora-{cisco-openh264,modular,updates-modular},rpmfusion-free{,-updates}}.repo && \
  rpm-ostree install \
    xorg-x11-drv-${NVIDIA_PACKAGE_NAME}{,-cuda,-devel,-kmodsrc,-power}-${NVIDIA_FULL_VERSION} \
    kernel-devel-${KERNEL_VERSION} \
    "/tmp/akmods/${NVIDIA_PACKAGE_NAME}/kmod-${NVIDIA_PACKAGE_NAME}-${KERNEL_VERSION}-${NVIDIA_FULL_VERSION#*:}.rpm" && \
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-nonfree{,-updates}.repo && \
  ln -s /usr/bin/ld.bfd /etc/alternatives/ld && \
  ln -s /etc/alternatives/ld /usr/bin/ld && \
  rm -rf /tmp/* /var/* && \
  rpm-ostree install openrgb-udev-rules rEFInd && \
  rpm-ostree cleanup -m && \
  ostree container commit
