#!/usr/bin/env bash
set -euo pipefail

# GitHub-hosted runners contain several large SDKs which OpenWrt does not use.
sudo rm -rf \
  /usr/local/lib/android \
  /usr/local/.ghcup \
  /usr/share/dotnet \
  /usr/share/swift \
  /opt/ghc
docker system prune --all --force >/dev/null 2>&1 || true

sudo apt-get -qq update
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends \
  asciidoc autoconf automake autopoint binutils bison build-essential bzip2 \
  ccache clang cmake cpio curl device-tree-compiler file flex g++ g++-multilib \
  diffutils findutils gawk gcc-multilib gettext git gperf help2man intltool jq \
  libelf-dev libffi-dev \
  libfuse-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev \
  libncurses-dev libreadline-dev libssl-dev libtool libzstd-dev ninja-build \
  p7zip-full patch perl pigz pkgconf python3 python3-dev python3-pip \
  python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools \
  subversion swig texinfo time uglifyjs unzip util-linux vim-common wget xmlto \
  xsltproc xz-utils zip zlib1g-dev zstd genisoimage
sudo apt-get -qq clean
