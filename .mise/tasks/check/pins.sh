#!/bin/sh
#MISE description="fail when a baseline mise pin does not resolve, or win/mise.toml drifts from the baseline"
#MISE hide=true
set -eu

# Nothing in ci installs the baseline, so this is the only build a bumped baseline pin gets.
baseline=config/mise/config.toml
windows=win/mise.toml
status=0

pins() { sed -n '/^\[tools\]/,/^\[/p' "$1" | grep -E '^[a-z0-9-]+ = "[^"]+"' | sed 's/ = "/ /; s/"$//'; }

expected=$(mktemp)
actual=$(mktemp)
trap 'rm -f "${expected}" "${actual}"' EXIT

for file in "${baseline}" "${windows}"; do
  pins "${file}" >"${actual}"
  while read -r tool pin; do
    resolved=$(mise latest "${tool}@${pin}" 2>/dev/null || true)
    if [ "${resolved}" != "${pin}" ]; then
      echo "error: ${file}: ${tool} = \"${pin}\" resolves to '${resolved}'" >&2
      status=1
    fi
  done <"${actual}"
done

# dotnet and cmake come from winget on Windows; localstack runs only in WSL.
pins "${baseline}" | grep -Ev '^(dotnet|cmake|localstack) ' | sort >"${expected}"
pins "${windows}" | sort >"${actual}"
if ! diff -u "${expected}" "${actual}" >&2; then
  echo "error: ${windows} [tools] drifts from ${baseline} (above: - baseline, + windows)" >&2
  status=1
fi
exit "${status}"
