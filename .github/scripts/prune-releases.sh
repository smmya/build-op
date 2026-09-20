#!/usr/bin/env bash
set -euo pipefail

tag_prefix="${1:?usage: prune-releases.sh <tag-prefix> [keep]}"
keep="${2:-7}"
count=0

while IFS=$'\t' read -r created_at release_id tag_name; do
  [[ "$tag_name" == "$tag_prefix"* ]] || continue
  count=$((count + 1))
  (( count > keep )) || continue

  echo "Deleting old release ${tag_name} (${created_at})"
  gh api --method DELETE "repos/${GITHUB_REPOSITORY}/releases/${release_id}"
  gh api --method DELETE "repos/${GITHUB_REPOSITORY}/git/refs/tags/${tag_name}" || true
done < <(
  gh api --paginate --slurp "repos/${GITHUB_REPOSITORY}/releases?per_page=100" \
    --jq 'add | sort_by(.created_at) | reverse | .[] | [.created_at, (.id | tostring), .tag_name] | @tsv'
)

