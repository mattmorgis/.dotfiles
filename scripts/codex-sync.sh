#!/usr/bin/env bash
set -euo pipefail

# a little ridiculous that this script needs to exist

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
base_config="${repo_root}/config/codex/config.toml"
dest_config="${HOME}/.codex/config.toml"

tmp_file="$(mktemp)"
trap 'rm -f "${tmp_file}"' EXIT

if [[ ! -f "${base_config}" ]]; then
  echo "Base config not found: ${base_config}" >&2
  exit 1
fi

# Start with the base config, expanding $HOME
sed "s|\\$HOME|${HOME}|g" "${base_config}" > "${tmp_file}"

# Append any existing per-project trust blocks.
if [[ -f "${dest_config}" ]]; then
  awk '
    BEGIN { in_projects = 0 }
    /^\[projects\./ { in_projects = 1; print; next }
    /^\[/ { in_projects = 0 }
    { if (in_projects) print }
  ' "${dest_config}" >> "${tmp_file}"
fi

mkdir -p "$(dirname "${dest_config}")"

# Replace the destination config.
cat "${tmp_file}" > "${dest_config}"

echo "Synced Codex config to ${dest_config}"
