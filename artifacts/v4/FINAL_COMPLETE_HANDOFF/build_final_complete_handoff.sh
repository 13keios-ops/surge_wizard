#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
OUT_ROOT="${1:-$REPO_ROOT/.handoff/Surge_Wizard_v4_FINAL_COMPLETE_HANDOFF_2026-10-03}"

python3 "$REPO_ROOT/docs/v4/preimplementation/validate_repo_handoff_v8_2.py"

rm -rf "$OUT_ROOT"
mkdir -p "$OUT_ROOT"

copy_dir() {
  local src="$1" dst="$2"
  [[ -e "$src" ]] || return 0
  mkdir -p "$dst"
  cp -a "$src/." "$dst/"
}

mkdir -p "$OUT_ROOT/00_ENTRY" "$OUT_ROOT/10_DOCS" "$OUT_ROOT/20_SOURCE" "$OUT_ROOT/30_TEST_TOOL" "$OUT_ROOT/40_DATA" "$OUT_ROOT/90_LEGACY"

cp "$REPO_ROOT/CLAUDE.md" "$OUT_ROOT/00_ENTRY/"
cp "$REPO_ROOT/README.md" "$OUT_ROOT/00_ENTRY/"
cp "$REPO_ROOT/AGENT_START_HERE.md" "$OUT_ROOT/00_ENTRY/"
cp "$REPO_ROOT/pubspec.yaml" "$OUT_ROOT/00_ENTRY/"
[[ -f "$REPO_ROOT/analysis_options.yaml" ]] && cp "$REPO_ROOT/analysis_options.yaml" "$OUT_ROOT/00_ENTRY/"

copy_dir "$REPO_ROOT/docs/v4/final" "$OUT_ROOT/10_DOCS/final"
copy_dir "$REPO_ROOT/docs/v4/design/v6" "$OUT_ROOT/10_DOCS/design_v6"
copy_dir "$REPO_ROOT/docs/v4/narrative/v7" "$OUT_ROOT/10_DOCS/narrative_v7"
copy_dir "$REPO_ROOT/docs/v4/preimplementation" "$OUT_ROOT/10_DOCS/preimplementation"

copy_dir "$REPO_ROOT/lib" "$OUT_ROOT/20_SOURCE/lib"
copy_dir "$REPO_ROOT/test" "$OUT_ROOT/30_TEST_TOOL/test"
copy_dir "$REPO_ROOT/tool" "$OUT_ROOT/30_TEST_TOOL/tool"
copy_dir "$REPO_ROOT/assets/data" "$OUT_ROOT/40_DATA/assets_data"

cp "$REPO_ROOT/HANDOFF.md" "$OUT_ROOT/90_LEGACY/HANDOFF.md"
cp "$REPO_ROOT/GAME_DESIGN.md" "$OUT_ROOT/90_LEGACY/GAME_DESIGN.md"

cp "$REPO_ROOT/artifacts/v4/FINAL_COMPLETE_HANDOFF/00_START_HERE.md" "$OUT_ROOT/00_START_HERE.md"
cp "$REPO_ROOT/artifacts/v4/FINAL_COMPLETE_HANDOFF/COMPONENT_MANIFEST.json" "$OUT_ROOT/COMPONENT_MANIFEST.json"

python3 - "$OUT_ROOT" <<'PY'
from pathlib import Path
import hashlib, json, sys
root=Path(sys.argv[1])
def digest(p):
    h=hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda:f.read(1024*1024),b""): h.update(chunk)
    return h.hexdigest()
files=sorted(p for p in root.rglob("*") if p.is_file() and p.name!="MANIFEST.json")
entries=[{"path":str(p.relative_to(root)),"bytes":p.stat().st_size,"sha256":digest(p)} for p in files]
(root/"MANIFEST.json").write_text(json.dumps({"package":root.name,"file_count_excluding_manifest":len(entries),"files":entries},ensure_ascii=False,indent=2),encoding="utf-8")
print("handoff files:",len(entries)+1)
PY

echo "Implementation handoff workspace: $OUT_ROOT"

if [[ "${BUILD_ARCHIVE:-1}" == "1" ]]; then
  ARCHIVE="${OUT_ROOT}.tar.xz"
  rm -f "$ARCHIVE"
  PARENT="$(dirname "$OUT_ROOT")"
  NAME="$(basename "$OUT_ROOT")"
  (
    cd "$PARENT"
    tar --sort=name --mtime='UTC 2026-10-03' --owner=0 --group=0 --numeric-owner -cf - "$NAME" | xz -9e -T1 > "$ARCHIVE"
  )
  xz -t "$ARCHIVE"
  echo "Unified archive: $ARCHIVE"
  sha256sum "$ARCHIVE"
fi
