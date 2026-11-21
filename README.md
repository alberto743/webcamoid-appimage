# webcamoid-appimage (unofficial)

**Unofficial** AppImage builds of [Webcamoid](https://github.com/webcamoid/webcamoid), the camera suite.
Not affiliated with or endorsed by the Webcamoid project. Please report problems with this packaging
here, not to upstream.

A GitHub Actions workflow checks weekly for a new stable upstream tag (`X.Y.Z`, no pre-releases),
compiles it from source on Ubuntu 24.04 with the build recipe from upstream's own CI
(`ports/ci/linux-ubuntu`) and packages it with upstream's
[DeployTools](https://github.com/webcamoid/DeployTools) and `appimagetool`. Only `x86_64` is built.
Upstream does not publish a public AppImage, so nothing is repackaged: the binary is built here.

Releases: `Webcamoid-X.Y.Z-x86_64.AppImage` plus its `.sha256`, `Webcamoid-X.Y.Z.source.tar.gz`
(the upstream tag, for GPL compliance) and `Webcamoid-X.Y.Z-x86_64.licenses.tar.gz`.

## Differences from upstream builds

- Built from the public source only: the private `ExtraPlugins` submodule is not included.
- Built against Ubuntu 24.04 libraries, so the glibc floor is 2.39 (older distributions will not run it).
- Same CMake options as upstream's AppImage CI (`-DNOLIBAVDEVICE=ON`, PipeWire/PulseAudio loaded
  dynamically, `libsvtav1` encoder disabled).
- No AppImage update information (no `appimageupdatetool` support).

## Verify a download

```sh
sha256sum -c Webcamoid-X.Y.Z-x86_64.AppImage.sha256
gh attestation verify Webcamoid-X.Y.Z-x86_64.AppImage --repo alberto743/webcamoid-appimage   # gh 2.49+
```

## Run

```sh
chmod +x Webcamoid-X.Y.Z-x86_64.AppImage
./Webcamoid-X.Y.Z-x86_64.AppImage
```

FUSE 2 is needed; otherwise use `--appimage-extract-and-run`. No sandbox and no signature check
beyond the attestation above. Webcamoid's [privacy policy](https://github.com/webcamoid/webcamoid/blob/master/PRIVACY_POLICY.md)
applies to the application.

## Manual runs

*Actions → Build AppImage → Run workflow*: `tag` builds a specific stable tag, `revision` publishes it as
`X.Y.Z-rN` (use when only this packaging changed), `force` overwrites an existing release. Two failed
scheduled runs in a row stop the schedule and open an issue until a manual run succeeds.
`update-tools.yml` opens a weekly PR bumping the pins in `tools.env`.

## Licensing

- The scripts in this repository: [MPL-2.0](COPYING). The repository follows the [REUSE Specification](https://reuse.software/spec/) (see `REUSE.toml` and `LICENSES/`).
- The AppImage and the source archive: Webcamoid is **GPL-3.0-or-later**, and the image bundles
  Ubuntu libraries under their own licenses (Qt and others, mostly LGPL). Details and the source offer:
  [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) and the `.licenses.tar.gz` asset.
- Redistributing a build: keep the GPL texts and source archive with it, as the release does.

**Disclaimer:** This is an independent, unofficial project. It is not affiliated with, sponsored or
endorsed by the Webcamoid authors. "Webcamoid" and any related names or logos belong to their
respective owners and are used here only to identify the software. The binaries are provided "as is",
without warranty of any kind, and you use them at your own risk. If a rights holder objects to the use
of the name, this project will be renamed on request.
