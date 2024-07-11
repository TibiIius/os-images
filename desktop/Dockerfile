ARG IMAGE_MAJOR="${IMAGE_MAJOR:-40}"
ARG BASE_IMAGE="ghcr.io/tibiiius/custom-silverblue-base"
ARG UBLUE_AKMODS_TAG="main-${IMAGE_MAJOR}"

# Hack to be able to use `COPY --from=$VARIABLE`
FROM ghcr.io/ublue-os/akmods-nvidia:${UBLUE_AKMODS_TAG} AS ublue-akmods-full-path

FROM ${BASE_IMAGE}:${IMAGE_MAJOR}

COPY etc/ /etc/

ARG NVIDIA_MAJOR_VERSION
ENV NVIDIA_MAJOR_VERSION=$NVIDIA_MAJOR_VERSION

# Installs additional NVIDIA repositories for stuff like NVIDIA's Container Toolkit
COPY --from=ublue-akmods-full-path /rpms/ /tmp/rpms

RUN source /tmp/rpms/kmods/nvidia-vars && \
  rpm-ostree install /tmp/rpms/ublue-os/ublue-os-nvidia*.rpm && \
  # enables nvidia repos provided by ublue-os-nvidia-addons
  sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/eyecantcu-supergfxctl.repo && \
  sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/negativo17-fedora-nvidia.repo && \
  sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/nvidia-container-toolkit.repo && \
  rpm-ostree install \
  kernel-devel-${KERNEL_VERSION} \
  libva-nvidia-driver \
  libnvidia-fbc \
  libnvidia-ml \
  libnvidia-ml.i686 \
  mesa-vulkan-drivers.i686 \
  nvidia-driver \
  nvidia-driver-cuda \
  nvidia-driver-cuda-libs \
  nvidia-driver-cuda-libs.i686 \
  nvidia-driver-libs \
  nvidia-driver-libs.i686 \
  nvidia-modprobe \
  nvidia-persistenced \
  nvidia-settings \
  nvidia-container-toolkit \
  cuda-devel \
  /tmp/rpms/kmods/kmod-nvidia-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm \
  openrgb-udev-rules i2c-tools libi2c libi2c-devel rEFInd && \
  ln -s /usr/bin/ld.bfd /etc/alternatives/ld && \
  ln -s /etc/alternatives/ld /usr/bin/ld && \
  ln -s /usr/lib/libnvidia-ml.so.1 /usr/lib/libnvidia-ml.so && \
  rm -rf /tmp/* /var/* && \
  rpm-ostree cleanup -m && \
  ostree container commit
