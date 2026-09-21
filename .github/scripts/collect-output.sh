#!/usr/bin/env bash
set -euo pipefail

device="${1:?usage: collect-output.sh <device> <target> <subtarget> <build-id>}"
target="${2:?}"
subtarget="${3:?}"
build_id="${4:?}"
source_dir="openwrt/bin/targets/${target}/${subtarget}"
release_dir="output/${device}"
bundle_dir="artifacts"

[[ -d "$source_dir" ]] || {
  echo "Target output directory not found: $source_dir" >&2
  exit 1
}

rm -rf "$release_dir"
mkdir -p "$release_dir" "$bundle_dir"

# Only top-level target outputs are publishable. bin/packages and the target's
# packages/ directory are deliberately excluded from workflow artifacts.
find "$source_dir" -maxdepth 1 -type f -print0 |
  while IFS= read -r -d '' file; do
    cp -f "$file" "$release_dir/"
  done

if ! find "$release_dir" -maxdepth 1 -type f -print -quit | grep -q .; then
  echo "No firmware files were collected from $source_dir" >&2
  exit 1
fi

(
  cd "$release_dir"
  find . -maxdepth 1 -type f ! -name SHA256SUMS -printf '%P\0' |
    sort -z |
    xargs -0 -r sha256sum > SHA256SUMS
)

bundle="${bundle_dir}/${device}-${build_id}.tar.zst"
tar --zstd -cf "$bundle" -C "$release_dir" .
echo "BUNDLE=$bundle" >> "$GITHUB_ENV"
echo "RELEASE_DIR=$release_dir" >> "$GITHUB_ENV"

