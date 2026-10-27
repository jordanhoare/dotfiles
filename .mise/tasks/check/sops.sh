#!/bin/sh
#MISE description="fail when a tracked *.sops file is not encrypted or its plaintext is tracked beside it"
#MISE hide=true
set -eu

status=0
for source in $(git ls-files '*.sops'); do
  # sops filestatus exits non-zero on plaintext it cannot parse; the output decides.
  file_status=$(sops filestatus "${source}" 2>/dev/null || true)
  if [ "${file_status}" != '{"encrypted":true}' ]; then
    echo "error: ${source} is not sops-encrypted; encrypt it with: sops edit ${source}" >&2
    status=1
  fi
  if git ls-files --error-unmatch "${source%.sops}" >/dev/null 2>&1; then
    echo "error: ${source%.sops} is the decrypted copy of ${source}; run: git rm --cached ${source%.sops}" >&2
    status=1
  fi
done
exit "${status}"
