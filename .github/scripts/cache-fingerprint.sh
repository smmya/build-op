#!/usr/bin/env bash
set -euo pipefail

kind="${1:?usage: cache-fingerprint.sh <host|toolchain> [config]}"
config="${2:-}"

hash_git_path() {
  local path="$1"
  git rev-parse "HEAD:${path}" 2>/dev/null || printf 'missing:%s\n' "$path"
}

case "$kind" in
  host)
    {
      hash_git_path tools
      hash_git_path include
      hash_git_path scripts
      hash_git_path rules.mk
      hash_git_path Config.in
    } | sha256sum | cut -d' ' -f1
    ;;
  toolchain)
    [[ -f "$config" ]] || {
      echo "Config not found: $config" >&2
      exit 1
    }
    {
      hash_git_path toolchain
      hash_git_path include
      hash_git_path scripts
      hash_git_path rules.mk
      hash_git_path Config.in
      grep -E \
        '^(CONFIG_TARGET_.*=y|CONFIG_TARGET_(BOARD|SUBTARGET|ARCH_PACKAGES)=|CONFIG_ARCH=|CONFIG_CPU_TYPE=|CONFIG_(GCC|BINUTILS|USE_MUSL|USE_GLIBC|LIBC)[A-Z0-9_]*=)' \
        "$config" || true
    } | sha256sum | cut -d' ' -f1
    ;;
  *)
    echo "Unknown fingerprint kind: $kind" >&2
    exit 2
    ;;
esac

