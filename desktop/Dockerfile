ARG IMAGE_MAJOR="${IMAGE_MAJOR:-39}"
ARG BASE_IMAGE="ghcr.io/tibiiius/custom-silverblue-base"
ARG NVIDIA_MAJOR_VERSION="${NVIDIA_MAJOR_VERSION:-535}"
ARG UBLUE_AKMODS_TAG="main-${IMAGE_MAJOR}-${NVIDIA_MAJOR_VERSION}"

# Hack to be able to use `COPY --from=$VARIABLE`
FROM ghcr.io/ublue-os/akmods-nvidia:${UBLUE_AKMODS_TAG} as ublue-akmods-full-path

FROM ${BASE_IMAGE}:${IMAGE_MAJOR} as builder

ARG NVIDIA_MAJOR_VERSION

ENV NVIDIA_PACKAGE_NAME "nvidia"

# Building NVIDIA kernel modules otherwise fails... Just why?
RUN ln -s /usr/bin/rpm-ostree /usr/bin/dnf

RUN rpm-ostree install fedora-repos-archive

RUN RELEASE="$(rpm -E '%fedora.%_arch')" && \
  rpm-ostree install \
  akmods \
  akmod-${NVIDIA_PACKAGE_NAME}*:${NVIDIA_MAJOR_VERSION}.*.fc${RELEASE} \
  mock \
  xorg-x11-drv-nvidia{,-cuda,-devel,-kmodsrc,-power} \
  binutils \
  kernel-devel-$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')

# I totally know why this is needed
RUN ln -s /usr/bin/ld.bfd /etc/alternatives/ld && ln -s /etc/alternatives/ld /usr/bin/ld

RUN RELEASE="$(rpm -E '%fedora.%_arch')" \
  KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')" \
  NVIDIA_AKMOD_VERSION="$(basename "$(rpm -q "akmod-${NVIDIA_PACKAGE_NAME}" --queryformat '%{VERSION}-%{RELEASE}')" ".fc${RELEASE%%.*}")" && \
  chmod -R 1777 /tmp && \
  chmod -R 1777 /var/tmp && \
  printf "NVIDIA_PACKAGE_NAME=${NVIDIA_PACKAGE_NAME}\nKERNEL_VERSION=${KERNEL_VERSION}\nNVIDIA_AKMOD_VERSION=${NVIDIA_AKMOD_VERSION}\nRELEASE=${RELEASE}\n" > /var/cache/akmods/nvidia-vars && \
  akmods --force --kernels "${KERNEL_VERSION}" --kmod "${NVIDIA_PACKAGE_NAME}" && \
  modinfo /usr/lib/modules/${KERNEL_VERSION}/extra/${NVIDIA_PACKAGE_NAME}/nvidia{,-drm,-modeset,-peermem,-uvm}.ko.xz > /dev/null || \
  (cat /var/cache/akmods/${NVIDIA_PACKAGE_NAME}/${NVIDIA_AKMOD_VERSION}-for-${KERNEL_VERSION}.failed.log && exit 1)

RUN NVIDIA_FULL_VERSION="$(rpm -q "xorg-x11-drv-nvidia" --queryformat '%{EPOCH}:%{VERSION}-%{RELEASE}.%{ARCH}')" && \
  printf "NVIDIA_FULL_VERSION=${NVIDIA_FULL_VERSION}" >> /var/cache/akmods/nvidia-vars

FROM ${BASE_IMAGE}:${IMAGE_MAJOR}

# Installs additional NVIDIA repositories for stuff like NVIDIA's Container Toolkit
COPY --from=ublue-akmods-full-path /rpms/ /tmp/rpms
RUN rpm-ostree install /tmp/rpms/ublue-os/ublue-os-nvidia*.rpm && \
  ostree container commit

COPY --from=builder /var/cache/akmods /tmp/akmods
RUN source /tmp/akmods/nvidia-vars && \
  rpm-ostree install \
  xorg-x11-drv-${NVIDIA_PACKAGE_NAME}{,-cuda,-devel,-kmodsrc,-power}-${NVIDIA_FULL_VERSION} \
  kernel-devel-${KERNEL_VERSION} \
  "/tmp/akmods/${NVIDIA_PACKAGE_NAME}/kmod-${NVIDIA_PACKAGE_NAME}-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm" \
  nvidia-vaapi-driver libva-utils \
  nvidia-container-toolkit \
  openrgb-udev-rules i2c-tools libi2c libi2c-devel rEFInd && \
  ln -s /usr/bin/ld.bfd /etc/alternatives/ld && \
  ln -s /etc/alternatives/ld /usr/bin/ld && \
  rm -rf /tmp/* /var/* && \
  rpm-ostree cleanup -m && \
  ostree container commit
