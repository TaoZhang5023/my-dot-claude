#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src="${repo_root}/.claude/skills"
dest="${HOME}/.claude/skills"

if [[ ! -d "${src}" ]]; then
  echo "No skills directory found at ${src}" >&2
  exit 1
fi

mkdir -p "${dest}"

for skill_dir in "${src}"/*; do
  [[ -d "${skill_dir}" ]] || continue
  skill_name="$(basename "${skill_dir}")"
  rm -rf "${dest}/${skill_name}"
  cp -R "${skill_dir}" "${dest}/${skill_name}"
  echo "Installed skill: ${skill_name}"
done
