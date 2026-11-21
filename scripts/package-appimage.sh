#!/bin/bash
# SPDX-FileCopyrightText: 2026 Alberto P
# SPDX-License-Identifier: MPL-2.0
#
# Turns the installed Webcamoid prefix into an AppImage with upstream's DeployTools, and collects the
# source archive and license notices that must accompany the binary (GPL-3.0-or-later).
# Usage: package-appimage.sh --work DIR --tag X.Y.Z --arch x86_64 --out DIR
# Needs appimagetool on PATH and the output of build-webcamoid.sh in --work.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../tools.env
. "$ROOT/tools.env"

WORK="" TAG="" ARCH="" OUT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --work) WORK="$(realpath -m "$2")"; shift 2 ;;
    --tag)  TAG="$2"; shift 2 ;;
    --arch) ARCH="$2"; shift 2 ;;
    --out)  OUT="$(realpath -m "$2")"; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done
if [ -z "$WORK" ] || [ -z "$TAG" ] || [ -z "$ARCH" ] || [ -z "$OUT" ]; then
  echo "missing option" >&2
  exit 2
fi
[ "$ARCH" = x86_64 ] || { echo "only x86_64 is supported" >&2; exit 2; }
command -v appimagetool >/dev/null || { echo "appimagetool not on PATH" >&2; exit 1; }

mkdir -p "$OUT"
DT="$WORK/DeployTools"
git clone --quiet https://github.com/webcamoid/DeployTools "$DT"
git -C "$DT" checkout --quiet "$DEPLOYTOOLS_COMMIT"

# Only the AppImage is wanted (upstream's config also lists a tar.xz and a QtIFW installer)
cat > "$WORK/override.conf" <<CONF
[Package]
outputFormats = AppImage

[Qt]
extraPlugins = egldeviceintegrations, multimedia, xcbglintegrations, wayland-decoration-client, wayland-graphics-integration-client, wayland-graphics-integration-server, wayland-shell-integration
CONF

mkdir -p "$WORK/packages"
PYTHONPATH="$DT" xvfb-run --auto-servernum python3 "$DT/deploy.py" \
  -d "$WORK/prefix" \
  -c "$WORK/build/package_info.conf" \
  -c "$WORK/override.conf" \
  -o "$WORK/packages"

built=$(find "$WORK/packages" -maxdepth 1 -name '*.AppImage')
if [ -z "$built" ] || [ "$(wc -l <<< "$built")" != 1 ]; then
  echo "expected exactly one AppImage in $WORK/packages" >&2
  ls -l "$WORK/packages" >&2
  exit 1
fi
cp "$built" "$OUT/Webcamoid-$TAG-$ARCH.AppImage"
chmod +x "$OUT/Webcamoid-$TAG-$ARCH.AppImage"

# Corresponding source: the exact upstream tag (the commit is recorded by build-webcamoid.sh)
commit="$(cat "$WORK/commit")"
git -C "$WORK/src" archive --format=tar --prefix="webcamoid-$TAG/" "$commit" | gzip -n > "$OUT/Webcamoid-$TAG.source.tar.gz"

"$ROOT/scripts/collect-licenses.sh" "$WORK" "$TAG" "$commit" "$OUT/Webcamoid-$TAG-$ARCH.licenses.tar.gz"
