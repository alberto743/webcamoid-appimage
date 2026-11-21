#!/bin/bash
# SPDX-FileCopyrightText: 2026 Alberto P
# SPDX-License-Identifier: MPL-2.0
#
# Bumps the pins in tools.env (DeployTools commit, appimagetool release + SHA-256).
# Prints one line per bump and nothing else when everything is current.
# GH_TOKEN is optional (it only raises the GitHub API rate limit).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT/tools.env"
EMPTY_SHA256=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

api() {
  curl -fsSL --retry 3 ${GH_TOKEN:+-H "Authorization: Bearer $GH_TOKEN"} "https://api.github.com/$1"
}
current() { sed -n "s/^$1=//p" "$ENV_FILE"; }
set_var() { sed -i "s|^$1=.*|$1=$2|" "$ENV_FILE"; }

# DeployTools has no releases: follow its default branch, pinned to a commit
commit=$(api repos/webcamoid/DeployTools/commits/HEAD | jq -r '.sha // empty')
[[ "$commit" =~ ^[0-9a-f]{40}$ ]] || { echo "ERROR: cannot resolve DeployTools HEAD" >&2; exit 1; }
if [ "$commit" != "$(current DEPLOYTOOLS_COMMIT)" ]; then
  echo "webcamoid/DeployTools: $(current DEPLOYTOOLS_COMMIT | cut -c1-12) -> ${commit:0:12}"
  set_var DEPLOYTOOLS_COMMIT "$commit"
fi

# appimagetool: newest release, skipping the rolling "continuous" tag whose assets change in place
asset=appimagetool-x86_64.AppImage
release=$(api "repos/AppImage/appimagetool/releases?per_page=20" \
  | jq -c '[.[] | select((.draft | not) and (.prerelease | not) and .tag_name != "continuous")][0] // empty')
[ -n "$release" ] || { echo "ERROR: no appimagetool release found" >&2; exit 1; }
tag=$(jq -r .tag_name <<< "$release")
if [ "$tag" != "$(current APPIMAGETOOL_VERSION)" ]; then
  sha=$(jq -r --arg n "$asset" '.assets[] | select(.name == $n) | .digest // empty' <<< "$release")
  sha="${sha#sha256:}"
  if [ -z "$sha" ]; then
    sha=$(curl -fsSL --retry 3 "https://github.com/AppImage/appimagetool/releases/download/$tag/$asset" | sha256sum | cut -d' ' -f1)
  fi
  if ! [[ "$sha" =~ ^[0-9a-f]{64}$ ]] || [ "$sha" = "$EMPTY_SHA256" ]; then
    echo "ERROR: no valid SHA-256 for $asset $tag" >&2
    exit 1
  fi
  echo "AppImage/appimagetool: $(current APPIMAGETOOL_VERSION) -> $tag"
  set_var APPIMAGETOOL_SHA256_x86_64 "$sha"
  set_var APPIMAGETOOL_VERSION "$tag"
fi
