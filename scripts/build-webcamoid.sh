#!/bin/bash
# SPDX-FileCopyrightText: 2026 Alberto P
# SPDX-License-Identifier: MPL-2.0
#
# Fetches an upstream Webcamoid release tag and builds + installs it with CMake/Ninja.
# Options adapted from webcamoid/ports/ci/linux-ubuntu/build.sh (GPL-3.0-or-later).
# Usage: build-webcamoid.sh <tag> <work-dir>
# Produces <work-dir>/src (sources), <work-dir>/build, <work-dir>/prefix and <work-dir>/commit.

set -euo pipefail

TAG="${1:?usage: build-webcamoid.sh <tag> <work-dir>}"
WORK="$(realpath -m "${2:?usage: build-webcamoid.sh <tag> <work-dir>}")"
[[ "$TAG" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "invalid tag: $TAG" >&2; exit 1; }

mkdir -p "$WORK"
# No submodules: libAvKys/ExtraPlugins is private upstream and not part of the public build
git clone --quiet --depth 1 --branch "$TAG" https://github.com/webcamoid/webcamoid "$WORK/src"
commit="$(git -C "$WORK/src" rev-parse HEAD)"
echo "$commit" > "$WORK/commit"

cd "$WORK/src"
cmake -LA -S . -B "$WORK/build" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$WORK/prefix" \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DQT_QMAKE_EXECUTABLE=/usr/lib/qt6/bin/qmake \
    -DLRELEASE_TOOL=/usr/lib/qt6/bin/lrelease \
    -DLUPDATE_TOOL=/usr/lib/qt6/bin/lupdate \
    -DGIT_COMMIT_HASH="$commit" \
    -DNOLIBAVDEVICE=ON \
    -DPIPEWIRE_DYNLOAD=ON \
    -DPULSEAUDIO_DYNLOAD=ON \
    -DFFMPEG_DISABLED_VIDEO_ENCODERS=libsvtav1 \
    -DDAILY_BUILD=0
cmake --build "$WORK/build" --parallel "$(nproc)"
cmake --install "$WORK/build"
