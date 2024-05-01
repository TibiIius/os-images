ARG IMAGE_MAJOR="${IMAGE_MAJOR:-40}"
ARG BASE_IMAGE="ghcr.io/tibiiius/custom-silverblue-base"
ARG UBLUE_AKMODS_TAG="main-${IMAGE_MAJOR}"

# Hack to be able to use `COPY --from=$VARIABLE`
FROM ghcr.io/ublue-os/akmods-nvidia:${UBLUE_AKMODS_TAG} as ublue-akmods-full-path

FROM ${BASE_IMAGE}:${IMAGE_MAJOR}

ARG NVIDIA_MAJOR_VERSION
ENV NVIDIA_MAJOR_VERSION $NVIDIA_MAJOR_VERSION

# Installs additional NVIDIA repositories for stuff like NVIDIA's Container Toolkit
COPY --from=ublue-akmods-full-path /rpms/ /tmp/rpms

RUN source /tmp/rpms/kmods/nvidia-vars && \
  rpm-ostree install /tmp/rpms/ublue-os/ublue-os-nvidia*.rpm && \
  rpm-ostree install \
  xorg-x11-drv-${NVIDIA_PACKAGE_NAME}{,-cuda,-devel,-kmodsrc,-power}-${NVIDIA_FULL_VERSION} \
  xorg-x11-drv-${NVIDIA_PACKAGE_NAME}-libs.i686 \
  kernel-devel-${KERNEL_VERSION} \
  /tmp/rpms/kmods/kmod-${NVIDIA_PACKAGE_NAME}-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm \
  nvidia-vaapi-driver libva-utils \
  nvidia-container-toolkit \
  openrgb-udev-rules i2c-tools libi2c libi2c-devel rEFInd && \
  ln -s /usr/bin/ld.bfd /etc/alternatives/ld && \
  ln -s /etc/alternatives/ld /usr/bin/ld && \
  rm -rf /tmp/* /var/* && \
  rpm-ostree cleanup -m && \
  ostree container commit
