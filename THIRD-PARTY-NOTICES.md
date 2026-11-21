# Third-party notices

The AppImage is an **unofficial** build of the unmodified upstream Webcamoid source tag. This
repository only contains the build scripts (MPL-2.0); it does not relicense anything below.
This file is shipped in each release inside `Webcamoid-<version>-<arch>.licenses.tar.gz`.

## Webcamoid

| Component | License |
|---|---|
| Webcamoid (<https://github.com/webcamoid/webcamoid>) | GPL-3.0-or-later (`COPYING-webcamoid.txt` in the tarball) |
| Upstream-bundled assets and algorithms | Their own licenses, installed by Webcamoid under `share/3rd-party/licenses` inside the image |

The private `ExtraPlugins` submodule of upstream is **not** part of this build.

Corresponding source (GPL-3.0 section 6): the `Webcamoid-<version>.source.tar.gz` release asset is an
archive of the exact upstream tag; the scripts that produced the binary are in this repository at the
commit named in the release notes.

## Libraries bundled from Ubuntu 24.04

DeployTools copies the shared libraries, Qt plugins and QML modules that Webcamoid needs from the
Ubuntu 24.04 build system into the AppImage. They are unmodified distribution packages (Qt 6, FFmpeg,
PipeWire/PulseAudio client libraries, libv4l, and their dependencies) and keep their own licenses,
typically LGPL-2.1/LGPL-3.0 (Qt, GPL/LGPL FFmpeg build as shipped by Ubuntu, libv4l, PipeWire) or
permissive licenses. The exact package list and version of each bundled package and its Debian
`copyright` file are in the `PACKAGES.txt` and `debian-copyright/` entries of the tarball, generated at
build time. Their sources are available from Ubuntu (`apt-get source <package>` or
<https://packages.ubuntu.com/noble/>).

LGPL notes: the libraries are bundled as separate, dynamically linked shared objects inside the
AppImage; you can extract it (`--appimage-extract`), replace a library, and repack with `appimagetool`.

## Trademarks

"Webcamoid" is the name of the upstream project. This repository is not affiliated with or endorsed by
it. Qt is a trademark of The Qt Company; Ubuntu of Canonical; AppImage of its respective owners.
