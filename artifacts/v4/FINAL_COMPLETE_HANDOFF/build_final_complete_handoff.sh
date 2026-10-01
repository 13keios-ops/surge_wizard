#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
COMPONENT_DIR="$REPO_ROOT/artifacts/v4/complete_handoff"
OUT_ROOT="${1:-$REPO_ROOT/.handoff/Surge_Wizard_v4_FINAL_COMPLETE_HANDOFF_2026-10-01}"

PRE="$COMPONENT_DIR/Surge_Wizard_v4_COMPLETE_HANDOFF_CONTENT_2026-10-01.tar.xz"
POST="$COMPONENT_DIR/Surge_Wizard_v4_POST_V3_6_COMPLETE_HANDOFF_2026-10-01.tar.xz"

PRE_SHA="1e3a7b89640377869b9598a92970bfd884a22aa08980d07067a9a76703101792"
POST_SHA="c518cb389d95d0111cbb1d1c4520aed5d6665f4de19b6c5d21b06670c55b5601"

check_sha() {
  local file="$1"
  local expected="$2"
  local actual
  actual="$(sha256sum "$file" | awk '{print $1}')"
  if [[ "$actual" != "$expected" ]]; then
    echo "SHA mismatch: $file" >&2
    echo "expected: $expected" >&2
    echo "actual:   $actual" >&2
    exit 1
  fi
}

check_sha "$PRE" "$PRE_SHA"
check_sha "$POST" "$POST_SHA"

rm -rf "$OUT_ROOT"
mkdir -p   "$OUT_ROOT/01_CURRENT_AUTHORITY"   "$OUT_ROOT/10_DIRECTION_CHANGE_TO_V3_6"   "$OUT_ROOT/20_V3_7_TO_V5_9"

cp "$REPO_ROOT/artifacts/v4/FINAL_COMPLETE_HANDOFF/00_START_HERE.md"    "$OUT_ROOT/00_START_HERE.md"
cp "$REPO_ROOT/docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md"    "$OUT_ROOT/01_CURRENT_AUTHORITY/CURRENT_AUTHORITY.md"
cp "$REPO_ROOT/docs/v4/final/FINAL_AUDIT_2026-10-01.md"    "$OUT_ROOT/01_CURRENT_AUTHORITY/FINAL_AUDIT_2026-10-01.md"
cp "$REPO_ROOT/docs/v4/final/MASTER_SPEC.md"    "$OUT_ROOT/01_CURRENT_AUTHORITY/MASTER_SPEC.md"

tmp_pre="$(mktemp -d)"
tmp_post="$(mktemp -d)"
trap 'rm -rf "$tmp_pre" "$tmp_post"' EXIT

xz -dc "$PRE" | tar -xf - -C "$tmp_pre"
xz -dc "$POST" | tar -xf - -C "$tmp_post"

cp -a "$tmp_pre/v4_complete_handoff_stage/."       "$OUT_ROOT/10_DIRECTION_CHANGE_TO_V3_6/"
cp -a "$tmp_post/Surge_Wizard_v4_FINAL_HANDOFF_2026-10-01/."       "$OUT_ROOT/20_V3_7_TO_V5_9/"

cat > "$OUT_ROOT/SOURCE_ARCHIVE_HASHES.md" <<EOF
# Source archive provenance

- Pre/post direction-change component:
  - `Surge_Wizard_v4_COMPLETE_HANDOFF_CONTENT_2026-10-01.tar.xz`
  - SHA-256: `$PRE_SHA`
- v3.7 through v5.9 component:
  - `Surge_Wizard_v4_POST_V3_6_COMPLETE_HANDOFF_2026-10-01.tar.xz`
  - SHA-256: `$POST_SHA`
EOF

python3 - "$OUT_ROOT" <<'PY'
from pathlib import Path
import hashlib, json, sys
root=Path(sys.argv[1])

def digest(p):
    h=hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda:f.read(1024*1024), b""):
            h.update(chunk)
    return h.hexdigest()

files=sorted(p for p in root.rglob("*") if p.is_file() and p.name!="MANIFEST.json")
entries=[
    {"path":str(p.relative_to(root)),"bytes":p.stat().st_size,"sha256":digest(p)}
    for p in files
]
(root/"MANIFEST.json").write_text(
    json.dumps({
        "package":root.name,
        "file_count_excluding_manifest":len(entries),
        "files":entries
    }, ensure_ascii=False, indent=2),
    encoding="utf-8"
)
print("merged files:", len(entries)+1)
PY

PRE_COUNT="$(find "$OUT_ROOT/10_DIRECTION_CHANGE_TO_V3_6" -type f | wc -l | tr -d ' ')"
POST_COUNT="$(find "$OUT_ROOT/20_V3_7_TO_V5_9" -type f | wc -l | tr -d ' ')"

if [[ "$PRE_COUNT" != "1681" ]]; then
  echo "Unexpected pre-v3.7 file count: $PRE_COUNT (expected 1681)" >&2
  exit 1
fi
if [[ "$POST_COUNT" != "85" ]]; then
  echo "Unexpected post-v3.6 file count: $POST_COUNT (expected 85)" >&2
  exit 1
fi

echo "Merged handoff workspace:"
echo "  $OUT_ROOT"
echo "Source file counts:"
echo "  direction change -> v3.6: $PRE_COUNT"
echo "  v3.7 -> v5.9:          $POST_COUNT"

if [[ "${BUILD_ARCHIVE:-1}" == "1" ]]; then
  ARCHIVE="${OUT_ROOT}.tar.xz"
  rm -f "$ARCHIVE"
  PARENT="$(dirname "$OUT_ROOT")"
  NAME="$(basename "$OUT_ROOT")"
  (
    cd "$PARENT"
    tar --sort=name --mtime='UTC 2026-10-01' --owner=0 --group=0 --numeric-owner -cf - "$NAME"       | xz -9e -T1 > "$ARCHIVE"
  )
  xz -t "$ARCHIVE"
  echo "Unified archive:"
  echo "  $ARCHIVE"
  sha256sum "$ARCHIVE"
fi
