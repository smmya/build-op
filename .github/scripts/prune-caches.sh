#!/usr/bin/env bash
set -euo pipefail

prefix="${1:?usage: prune-caches.sh <key-prefix> [keep]}"
keep="${2:-1}"

mapfile -t cache_ids < <(
  gh api --paginate "repos/${GITHUB_REPOSITORY}/actions/caches?per_page=100" \
    --jq '.actions_caches[] | [.created_at, (.id | tostring), .key] | @tsv' |
    awk -F '\t' -v prefix="$prefix" 'index($3, prefix) == 1 { print }' |
    sort -r |
    tail -n "+$((keep + 1))" |
    cut -f2
)

for cache_id in "${cache_ids[@]}"; do
  [[ -n "$cache_id" ]] || continue
  echo "Deleting old cache id ${cache_id} (${prefix}*)"
  gh api --method DELETE "repos/${GITHUB_REPOSITORY}/actions/caches/${cache_id}"
done
