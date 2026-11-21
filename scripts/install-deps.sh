#!/bin/bash
# SPDX-FileCopyrightText: 2026 Alberto P
# SPDX-License-Identifier: MPL-2.0
#
# Installs the Webcamoid build dependencies (Ubuntu 24.04, run as root) and the pinned appimagetool.
# Package list adapted from webcamoid/ports/ci/linux-ubuntu/install_deps.sh (GPL-3.0-or-later).
# Usage: install-deps.sh <tools-dir>   (appimagetool ends up in <tools-dir>/bin)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../tools.env
. "$ROOT/tools.env"
TOOLS="$(realpath -m "${1:?usage: install-deps.sh <tools-dir>}")"

export DEBIAN_FRONTEND=noninteractive
apt-get -qq -y update
apt-get -qq -y install --no-install-recommends \
    ca-certificates ccache cmake curl dpkg file g++ git libasound2-dev libavcodec-dev libavdevice-dev \
    libavformat-dev libavutil-dev libdbus-1-3 libfontconfig1 libgl1 libgl1-mesa-dev libkmod-dev \
    libpipewire-0.3-dev libpipewire-0.3-modules libpulse-dev libqt6multimediaquick6 libqt6opengl6-dev \
    libqt6svg6-dev libswresample-dev libswscale-dev libusb-1.0-0-dev libv4l-dev libvulkan-dev \
    libwebpdemux2 libx11-xcb1 libxcb-cursor0 libxcb-glx0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
    libxcb-randr0 libxcb-render-util0 libxcb-shape0 libxcb-xinerama0 libxext-dev libxext6 libxfixes-dev \
    libxkbcommon-x11-0 libxrender1 linux-libc-dev make ninja-build patchelf pkg-config portaudio19-dev \
    python3 python3-pip qmake6 qml6-module-qt-labs-folderlistmodel qml6-module-qt-labs-platform \
    qml6-module-qt-labs-settings qml6-module-qtcore qml6-module-qtmultimedia qml6-module-qtqml \
    qml6-module-qtqml-models qml6-module-qtqml-workerscript qml6-module-qtquick-controls \
    qml6-module-qtquick-dialogs qml6-module-qtquick-layouts qml6-module-qtquick-nativestyle \
    qml6-module-qtquick-shapes qml6-module-qtquick-templates qml6-module-qtquick-window \
    qml6-module-qtquick3d-spatialaudio qml6-module-qttest qml6-module-qtwayland-compositor \
    qt6-declarative-dev qt6-l10n-tools qt6-multimedia-dev qt6-wayland wget xvfb

mkdir -p "$TOOLS"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
url="https://github.com/AppImage/appimagetool/releases/download/${APPIMAGETOOL_VERSION}/appimagetool-x86_64.AppImage"
curl -fsSL --retry 3 -o "$tmp/appimagetool.AppImage" "$url"
echo "${APPIMAGETOOL_SHA256_x86_64}  $tmp/appimagetool.AppImage" | sha256sum -c -
chmod +x "$tmp/appimagetool.AppImage"
(cd "$tmp" && ./appimagetool.AppImage --appimage-extract >/dev/null)
cp -a "$tmp/squashfs-root/usr/." "$TOOLS/"
