# OpenWrt build workflow

`.github/build-matrix.json` is the single source of truth for devices. The
workflow currently builds `new3`, `ax1800pro`, `n1-docker`, and `n1-flash`.
The retired `r3g` configuration is intentionally not part of the matrix.

Supported modes:

- `router`: normal hardware-router firmware.
- `arm-docker`: ARM rootfs plus the N1 Docker image.
- `arm-flash`: ARM rootfs plus the automatically packaged N1 flash image. The
  packager tracks the latest available `6.12.y` kernel and receives the same
  LAN IP as the compiled rootfs.
- `x86`: normal x86 firmware output; no x86 entry is enabled until an x86
  `.config` is added to the repository.

Example x86 entry:

```json
{
  "device": "x86-64",
  "mode": "x86",
  "source": "lede",
  "source_url": "https://github.com/coolsnowwolf/lede.git",
  "source_branch": "master",
  "config": "x86-64/.config",
  "target": "x86",
  "subtarget": "64",
  "arch": "x86_64",
  "lan_ip": "192.168.123.1"
}
```

The cache is split into host tools, target toolchain, and a rolling 512 MiB
ccache. Only the latest generation of each cache family is retained. Every
restored host/toolchain cache is checked by running the matching OpenWrt make
target before the firmware build continues. Only the compressed firmware
bundle is retained as a workflow artifact; individual files are published to
Releases.

All checkout steps disable persisted Git credentials. Official actions and
external packagers are pinned to full commit SHAs; upstream OpenWrt source
branches are resolved to one immutable commit at the start of each run.
