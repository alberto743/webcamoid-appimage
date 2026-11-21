#!/bin/bash
# SPDX-FileCopyrightText: 2026 Alberto P
# SPDX-License-Identifier: MPL-2.0
#
# Collects the license notices of what ended up inside the AppImage: Webcamoid's own COPYING plus the
# Debian copyright file of every Ubuntu package that ships a library/plugin/QML file bundled in the image.
# Must run on the build system (the dpkg database of the packages that were bundled is needed).
# Usage: collect-licenses.sh <work-dir> <tag> <commit> <output.tar.gz>

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(realpath "${1:?work dir}")"
TAG="${2:?tag}"
COMMIT="${3:?commit}"
OUTFILE="$(realpath -m "${4:?output file}")"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
appimage=$(find "$WORK/packages" -maxdepth 1 -name '*.AppImage')
(cd "$tmp" && APPIMAGE_EXTRACT_AND_RUN=1 "$appimage" --appimage-extract >/dev/null)

notices="$tmp/Webcamoid-$TAG-licenses"
mkdir -p "$notices/debian-copyright"
cp "$WORK/src/COPYING" "$notices/COPYING-webcamoid.txt"
cp "$ROOT/THIRD-PARTY-NOTICES.md" "$notices/"

# Basenames of every library, plugin and QML file bundled in the image
find "$tmp/squashfs-root" -type f \( -name '*.so' -o -name '*.so.*' -o -name '*.qml' -o -name 'qmldir' \) \
  -printf '%f\n' | sort -u > "$tmp/bundled.txt"

# One pass over the dpkg file lists: a package is included when it ships a file of that name
awk 'NR == FNR { want[$0] = 1; next }
     { n = split($0, p, "/"); if (p[n] in want) { f = FILENAME; sub(".*/", "", f); sub("\\.list$", "", f); sub(":.*", "", f); print f } }' \
  "$tmp/bundled.txt" /var/lib/dpkg/info/*.list | sort -u > "$tmp/packages.txt"

while read -r pkg; do
  src="/usr/share/doc/$pkg/copyright"
  if [ -r "$src" ]; then
    cp "$src" "$notices/debian-copyright/$pkg"
  else
    echo "$pkg: no copyright file found" >> "$notices/debian-copyright/MISSING.txt"
  fi
done < "$tmp/packages.txt"

# shellcheck source=/dev/null
. /etc/os-release
{
  echo "Webcamoid $TAG (upstream commit $COMMIT), built by https://github.com/${GITHUB_REPOSITORY:-OWNER/webcamoid-appimage}"
  echo "Build system: $PRETTY_NAME"
  echo "Bundled Ubuntu packages (name and version):"
  while read -r pkg; do
    dpkg-query -W -f='  ${Package} ${Version}\n' "$pkg" 2>/dev/null || true
  done < "$tmp/packages.txt"
} > "$notices/PACKAGES.txt"

tar -C "$tmp" --sort=name --owner=0 --group=0 --numeric-owner -cf - "Webcamoid-$TAG-licenses" | gzip -n > "$OUTFILE"
