#!/usr/bin/env bash

set -ex

sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/eyecantcu-supergfxctl.repo && \
  sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/negativo17-fedora-nvidia.repo && \
  sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/nvidia-container-toolkit.repo &&

rpm-ostree install \
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
  cuda-devel

ln -s /usr/lib/libnvidia-ml.so.1 /usr/lib/libnvidia-ml.so

rm -rf /tmp/* /var/* && \
rpm-ostree cleanup -m
