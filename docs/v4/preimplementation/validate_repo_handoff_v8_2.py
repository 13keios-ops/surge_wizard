from pathlib import Path
import json, re, subprocess, sys, hashlib

ROOT=Path(__file__).resolve().parents[3]

def fail(msg): raise AssertionError(msg)
def read(rel):
    p=ROOT/rel
    if not p.exists(): fail(f"missing: {rel}")
    return p.read_text(encoding="utf-8")
def load(rel): return json.loads(read(rel))

# Current entry and authority.
required=[
    "CLAUDE.md","README.md","AGENT_START_HERE.md",
    "docs/v4/final/CURRENT_AUTHORITY_2026-10-03.md",
    "docs/v4/final/MASTER_SPEC.md",
    "docs/v4/preimplementation/LOCAL_AGENT_BOOTSTRAP_v8.0.md",
    "docs/v4/preimplementation/FINAL_HANDOFF_RECHECK_v8.2.md",
    "docs/v4/preimplementation/CANONICAL_FLAG_MAP_v8.0.json",
    "docs/v4/preimplementation/M08_WEST_ANCHOR_RESTORATION_v8.0.md",
    "lib/main_v4_preview.dart",
]
for p in required:
    if not (ROOT/p).exists(): fail(f"missing required path: {p}")
for p in ["CLAUDE.md","README.md","AGENT_START_HERE.md","docs/v4/final/MASTER_SPEC.md"]:
    t=read(p)
    if "CURRENT_AUTHORITY_2026-10-03.md" not in t: fail(f"{p}: missing current authority")
    if "FINAL_HANDOFF_RECHECK_v8.2.md" not in t: fail(f"{p}: missing v8.2 recheck")
bootstrap=read("docs/v4/preimplementation/LOCAL_AGENT_BOOTSTRAP_v8.0.md")
if "CURRENT_AUTHORITY_2026-10-03.md" not in bootstrap or "Historical / legacy only" not in bootstrap:
    fail("bootstrap authority/history mismatch")

# Legacy quarantine.
for p in ["HANDOFF.md","GAME_DESIGN.md"]:
    top="\n".join(read(p).splitlines()[:6])
    if "LEGACY PRE-v4" not in top: fail(f"{p}: legacy banner missing")
    if "FINAL_HANDOFF_RECHECK_v8.2.md" not in top: fail(f"{p}: legacy banner points to stale recheck")
preaudit_top="\n".join(read("docs/v4/preimplementation/PREIMPLEMENTATION_FULL_AUDIT_v8.0.md").splitlines()[:6])
if "FINAL_HANDOFF_RECHECK_v8.2.md" not in preaudit_top: fail("pre-repair audit points to stale current recheck")
for p in ["docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md","docs/v4/final/FINAL_AUDIT_2026-10-01.md","docs/v4/final/CURRENT_AUTHORITY_2026-10-02.md"]:
    if "SUPERSEDED" not in "\n".join(read(p).splitlines()[:6]): fail(f"{p}: superseded banner missing")

v6=ROOT/"docs/v4/design/v6"; v7=ROOT/"docs/v4/narrative/v7"; v8=ROOT/"docs/v4/preimplementation"
for name in [
"A_v6.0_ACT_III_DATA.json","A_v6.0_CHECKPOINT_AUDIT.md",
"B_v6.1_ACT_IV_COMPANION_DATA.json","B_v6.1_CHECKPOINT_AUDIT.md",
"C_v6.2_ACT_V_ENDING_DATA.json","C_v6.2_CHECKPOINT_AUDIT.md",
"D_v6.3_COMPANION_QUEST_INTEGRATION.json","D_v6.3_FULL_WALKTHROUGH_STATE_TRACE.json",
"D_v6.3_LATE_GEAR_SPELL_HUB_DATA.json","D_v6.3_STATE_FLAG_MATRIX.json",
"D_v6.3_TACTICAL_MAP_LAYOUTS.json","D_v6.3_WORLD_EVENT_POOL_98.json","D_v6.3_XP_ECONOMY_AUDIT.json",
"validate_v6_campaign.py","VALIDATION_RUN.txt","MANIFEST.json"]:
    if not (v6/name).exists(): fail(f"v6 package missing {name}")
for name in [
"N1_v7.0_CHARACTER_NPC_VOICE_DATA.json","N2_v7.1_ACT_I_II_SCRIPT_DATA.json",
"N3_v7.2_ACT_III_SCRIPT_DATA.json","N4_v7.3_ACT_IV_SCRIPT_DATA.json",
"N5_v7.4_ACT_V_SCRIPT_DATA.json","N6_v7.5_COMPANION_PQ_SCRIPT_DATA.json",
"N7_v7.6_HUB_NPC_DIALOGUE_DATA.json","N8_v7.7_COMPANION_REACTIONS_BANTER_BARK_DATA.json",
"N9_v7.8_FULL_DIALOGUE_CATALOG.json","N9_v7.8_NARRATIVE_AUDIT_DATA.json",
"validate_v7_narrative.py","VALIDATION_RUN.txt","MANIFEST.json"]:
    if not (v7/name).exists(): fail(f"v7 package missing {name}")
for n in range(1,9):
    if not list(v7.glob(f"N{n}_v*_CHECKPOINT_AUDIT.md")): fail(f"v7 checkpoint N{n} missing")

# Parse every current JSON.
for base in [v6,v7,v8]:
    for p in base.glob("*.json"):
        try: json.loads(p.read_text(encoding="utf-8"))
        except Exception as e: fail(f"JSON parse failed {p.relative_to(ROOT)}: {e}")

# Key invariants.
flags=load("docs/v4/preimplementation/CANONICAL_FLAG_MAP_v8.0.json")
if set(flags["exclusive_choice_groups"])!={"M01","M02","M03","M04","M05","M06","M07","M08","C01"}: fail("choice groups mismatch")
if len(flags["exclusive_choice_groups"]["M08"])!=3: fail("M08 mismatch")
xp=load("docs/v4/preimplementation/XP_TRANSITION_FLOOR_v8.0.json")["transitionMinimumXp"]
if (xp["ACT_II_TO_III"],xp["ACT_III_TO_IV"],xp["ACT_IV_TO_V"])!=(1640,4130,7030): fail("XP floors mismatch")
poi=load("docs/v4/preimplementation/POI_EVENT_AUTHORITY_v8.0.json")
if len(poi["canonicalPOIs"])!=20 or len(poi["canonicalSideEventIds"])!=24: fail("POI counts mismatch")
cat=load("docs/v4/narrative/v7/N9_v7.8_FULL_DIALOGUE_CATALOG.json")["dialogue"]
ids=[x["id"] for x in cat]
if len(cat)!=1152 or len(ids)!=len(set(ids)) or any(not x["text_ko"].strip() for x in cat): fail("dialogue catalog invariant failed")
pubspec=read("pubspec.yaml")
if "google_mobile_ads" in pubspec: fail("google_mobile_ads still present")
if "GAME_DESIGN 8절" in pubspec: fail("pubspec still cites legacy GAME_DESIGN as current authority")

# Package manifests must describe the exact committed/copied bytes.
def verify_manifest(rel_dir):
    manifest=load(f"{rel_dir}/MANIFEST.json")
    entries=manifest["files"] if isinstance(manifest,dict) else manifest
    base=ROOT/rel_dir
    for e in entries:
        p=base/e["file"]
        if not p.exists(): fail(f"manifest missing file: {rel_dir}/{e['file']}")
        b=p.read_bytes()
        if len(b)!=e["bytes"]: fail(f"manifest byte mismatch: {rel_dir}/{e['file']}")
        expected=e.get("git_blob_sha")
        if expected:
            actual=hashlib.sha1(b"blob "+str(len(b)).encode()+b"\0"+b).hexdigest()
            if actual!=expected: fail(f"manifest git blob mismatch: {rel_dir}/{e['file']}")
    return len(entries)
v6_manifest_entries=verify_manifest("docs/v4/design/v6")
v7_manifest_entries=verify_manifest("docs/v4/narrative/v7")

# Current reference integrity. Bare filenames resolve relative to the document.
def check_refs(rel):
    txt=read(rel); base=(ROOT/rel).parent
    for token in re.findall(r"`([^`\n]+)`",txt):
        token=token.strip()
        if any(c in token for c in "<>|*{}[]") or " " in token: continue
        if token.endswith("/"):
            target=(ROOT/token).resolve() if "/" in token else (base/token).resolve()
        elif re.search(r"\.(md|json|py|txt|xz|dart|yaml|yml|sh)$",token):
            if token.startswith(("docs/","lib/","tool/","test/","assets/","artifacts/")) or token in {"CLAUDE.md","README.md","HANDOFF.md","GAME_DESIGN.md","AGENT_START_HERE.md","pubspec.yaml"}:
                target=(ROOT/token).resolve()
            else:
                target=(base/token).resolve()
        else:
            continue
        if not target.exists(): fail(f"broken reference in {rel}: {token}")
for rel in [
"CLAUDE.md","README.md","AGENT_START_HERE.md","docs/v4/final/MASTER_SPEC.md",
"docs/v4/design/v6/00_INDEX.md","docs/v4/narrative/v7/00_INDEX.md",
"docs/v4/preimplementation/00_INDEX.md","artifacts/v4/FINAL_COMPLETE_HANDOFF/00_START_HERE.md"]:
    check_refs(rel)

# Unified builder must use live layers and must not depend on historical binary archives.
builder=read("artifacts/v4/FINAL_COMPLETE_HANDOFF/build_final_complete_handoff.sh")
for token in ["docs/v4/design/v6","docs/v4/narrative/v7","docs/v4/preimplementation","lib","test","tool"]:
    if token not in builder: fail(f"builder missing live layer: {token}")
for forbidden in ["check_sha \"$PRE\"","xz -dc \"$PRE\"","check_sha \"$POST\"","xz -dc \"$POST\""]:
    if forbidden in builder: fail("builder still depends on old binary provenance archives")

# Original package/contract validators.
for script in [v6/"validate_v6_campaign.py",v7/"validate_v7_narrative.py",v8/"validate_v8_preimplementation.py"]:
    cp=subprocess.run([sys.executable,str(script)],cwd=script.parent,capture_output=True,text=True)
    if cp.returncode: fail(f"validator failed {script.name}: {cp.stdout}\n{cp.stderr}")

print("V8_2_FRESH_CLONE_HANDOFF_VALIDATION_OK")
print("v6_json",len(list(v6.glob("*.json"))),"v7_json",len(list(v7.glob("*.json"))),"v8_json",len(list(v8.glob("*.json"))))
print("dialogue_entries",len(cat),"broken_refs",0)
print("manifest_entries",v6_manifest_entries+v7_manifest_entries)
