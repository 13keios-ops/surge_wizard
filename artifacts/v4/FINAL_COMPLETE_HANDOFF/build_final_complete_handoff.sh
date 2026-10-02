#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
COMPONENT_DIR="$REPO_ROOT/artifacts/v4/complete_handoff"
OUT_ROOT="${1:-$REPO_ROOT/.handoff/Surge_Wizard_v4_FINAL_COMPLETE_HANDOFF_2026-10-03}"

PRE="$COMPONENT_DIR/Surge_Wizard_v4_COMPLETE_HANDOFF_CONTENT_2026-10-01.tar.xz"
POST="$COMPONENT_DIR/Surge_Wizard_v4_POST_V3_6_COMPLETE_HANDOFF_2026-10-01.tar.xz"
PRE_SHA="1e3a7b89640377869b9598a92970bfd884a22aa08980d07067a9a76703101792"
POST_SHA="c518cb389d95d0111cbb1d1c4520aed5d6665f4de19b6c5d21b06670c55b5601"

check_sha() {
  local file="$1" expected="$2" actual
  actual="$(sha256sum "$file" | awk '{print $1}')"
  [[ "$actual" == "$expected" ]] || {
    echo "SHA mismatch: $file" >&2
    echo "expected: $expected" >&2
    echo "actual:   $actual" >&2
    exit 1
  }
}

check_sha "$PRE" "$PRE_SHA"
check_sha "$POST" "$POST_SHA"

# Fresh-clone handoff integrity must pass before producing a merged archive.
python3 "$REPO_ROOT/docs/v4/preimplementation/validate_repo_handoff_v8_1.py"

rm -rf "$OUT_ROOT"
mkdir -p   "$OUT_ROOT/01_CURRENT_AUTHORITY"   "$OUT_ROOT/10_DIRECTION_CHANGE_TO_V3_6"   "$OUT_ROOT/20_V3_7_TO_V5_9"   "$OUT_ROOT/30_V6_CURRENT_DESIGN"   "$OUT_ROOT/40_V7_NARRATIVE"   "$OUT_ROOT/50_V8_PREIMPLEMENTATION"

cp "$REPO_ROOT/artifacts/v4/FINAL_COMPLETE_HANDOFF/00_START_HERE.md" "$OUT_ROOT/00_START_HERE.md"
cp "$REPO_ROOT/docs/v4/final/CURRENT_AUTHORITY_2026-10-03.md" "$OUT_ROOT/01_CURRENT_AUTHORITY/CURRENT_AUTHORITY.md"
cp "$REPO_ROOT/docs/v4/preimplementation/FINAL_HANDOFF_RECHECK_v8.1.md" "$OUT_ROOT/01_CURRENT_AUTHORITY/FINAL_HANDOFF_RECHECK_v8.1.md"
cp "$REPO_ROOT/docs/v4/final/MASTER_SPEC.md" "$OUT_ROOT/01_CURRENT_AUTHORITY/MASTER_SPEC.md"
cp "$REPO_ROOT/CLAUDE.md" "$OUT_ROOT/01_CURRENT_AUTHORITY/CLAUDE.md"
cp "$REPO_ROOT/AGENT_START_HERE.md" "$OUT_ROOT/01_CURRENT_AUTHORITY/AGENT_START_HERE.md"

tmp_pre="$(mktemp -d)"
tmp_post="$(mktemp -d)"
trap 'rm -rf "$tmp_pre" "$tmp_post"' EXIT

xz -dc "$PRE" | tar -xf - -C "$tmp_pre"
xz -dc "$POST" | tar -xf - -C "$tmp_post"

cp -a "$tmp_pre/v4_complete_handoff_stage/." "$OUT_ROOT/10_DIRECTION_CHANGE_TO_V3_6/"
cp -a "$tmp_post/Surge_Wizard_v4_FINAL_HANDOFF_2026-10-01/." "$OUT_ROOT/20_V3_7_TO_V5_9/"
cp -a "$REPO_ROOT/docs/v4/design/v6/." "$OUT_ROOT/30_V6_CURRENT_DESIGN/"
cp -a "$REPO_ROOT/docs/v4/narrative/v7/." "$OUT_ROOT/40_V7_NARRATIVE/"
cp -a "$REPO_ROOT/docs/v4/preimplementation/." "$OUT_ROOT/50_V8_PREIMPLEMENTATION/"

cat > "$OUT_ROOT/SOURCE_ARCHIVE_HASHES.md" <<'EOF'
# Source archive provenance

- Direction change through v3.6-era component:
  - `Surge_Wizard_v4_COMPLETE_HANDOFF_CONTENT_2026-10-01.tar.xz`
  - SHA-256: `1e3a7b89640377869b9598a92970bfd884a22aa08980d07067a9a76703101792`
- v3.7 through v5.9 component:
  - `Surge_Wizard_v4_POST_V3_6_COMPLETE_HANDOFF_2026-10-01.tar.xz`
  - SHA-256: `c518cb389d95d0111cbb1d1c4520aed5d6665f4de19b6c5d21b06670c55b5601`

Current v6/v7/v8.1 files are copied from the live repository tree after the fresh-clone validator passes.
EOF

python3 - "$OUT_ROOT" <<'PY'
from pathlib import Path
import hashlib, json, sys

root=Path(sys.argv[1])

def digest(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for chunk in iter(lambda:f.read(1024*1024), b''):
            h.update(chunk)
    return h.hexdigest()

files=sorted(p for p in root.rglob('*') if p.is_file() and p.name!='MANIFEST.json')
entries=[{
    'path':str(p.relative_to(root)),
    'bytes':p.stat().st_size,
    'sha256':digest(p)
} for p in files]
(root/'MANIFEST.json').write_text(
    json.dumps({
        'package':root.name,
        'file_count_excluding_manifest':len(entries),
        'files':entries
    }, ensure_ascii=False, indent=2),
    encoding='utf-8'
)
print('merged files:',len(entries)+1)
PY

PRE_COUNT="$(find "$OUT_ROOT/10_DIRECTION_CHANGE_TO_V3_6" -type f | wc -l | tr -d ' ')"
POST_COUNT="$(find "$OUT_ROOT/20_V3_7_TO_V5_9" -type f | wc -l | tr -d ' ')"
[[ "$PRE_COUNT" == "1681" ]] || { echo "Unexpected pre-v3.7 file count: $PRE_COUNT" >&2; exit 1; }
[[ "$POST_COUNT" == "85" ]] || { echo "Unexpected v3.7-v5.9 file count: $POST_COUNT" >&2; exit 1; }

echo "Merged handoff workspace: $OUT_ROOT"
echo "direction change -> v3.6 files: $PRE_COUNT"
echo "v3.7 -> v5.9 files: $POST_COUNT"
echo "v6 live files: $(find "$OUT_ROOT/30_V6_CURRENT_DESIGN" -type f | wc -l | tr -d ' ')"
echo "v7 live files: $(find "$OUT_ROOT/40_V7_NARRATIVE" -type f | wc -l | tr -d ' ')"
echo "v8/v8.1 live files: $(find "$OUT_ROOT/50_V8_PREIMPLEMENTATION" -type f | wc -l | tr -d ' ')"

if [[ "${BUILD_ARCHIVE:-1}" == "1" ]]; then
  ARCHIVE="${OUT_ROOT}.tar.xz"
  rm -f "$ARCHIVE"
  PARENT="$(dirname "$OUT_ROOT")"
  NAME="$(basename "$OUT_ROOT")"
  (
    cd "$PARENT"
    tar --sort=name --mtime='UTC 2026-10-03' --owner=0 --group=0 --numeric-owner -cf - "$NAME"       | xz -9e -T1 > "$ARCHIVE"
  )
  xz -t "$ARCHIVE"
  echo "Unified archive: $ARCHIVE"
  sha256sum "$ARCHIVE"
fi
