#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_root="${repo_root}/.claude/skills"

if [[ ! -d "${skills_root}" ]]; then
  echo "Missing skills directory: ${skills_root}" >&2
  exit 1
fi

found=0

for skill_file in "${skills_root}"/*/SKILL.md; do
  [[ -f "${skill_file}" ]] || continue
  found=1

  if ! sed -n '1p' "${skill_file}" | grep -qx -- '---'; then
    echo "Missing opening front matter marker: ${skill_file}" >&2
    exit 1
  fi

  if ! sed -n '2,20p' "${skill_file}" | grep -q '^name: '; then
    echo "Missing name field: ${skill_file}" >&2
    exit 1
  fi

  if ! sed -n '2,20p' "${skill_file}" | grep -q '^description: '; then
    echo "Missing description field: ${skill_file}" >&2
    exit 1
  fi

  if ! grep -q 'cmux identify' "${skill_file}"; then
    echo "Missing cmux identify workflow: ${skill_file}" >&2
    exit 1
  fi

  if ! grep -q 'cmux rename-workspace' "${skill_file}"; then
    echo "Missing cmux rename-workspace workflow: ${skill_file}" >&2
    exit 1
  fi
done

if [[ "${found}" -eq 0 ]]; then
  echo "No skills found under ${skills_root}" >&2
  exit 1
fi

echo "Skill validation passed."
