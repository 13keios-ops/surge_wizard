from pathlib import Path
import json, re, subprocess, sys

ROOT=Path(__file__).resolve().parents[3]  # docs/v4/preimplementation -> repo root

def fail(msg):
    raise AssertionError(msg)

def read(rel):
    p=ROOT/rel
    if not p.exists(): fail(f'missing: {rel}')
    return p.read_text(encoding='utf-8')

def load(rel):
    return json.loads(read(rel))

# 1. current entry / authority
required=[
    'CLAUDE.md','README.md','AGENT_START_HERE.md',
    'docs/v4/final/CURRENT_AUTHORITY_2026-10-02.md',
    'docs/v4/final/MASTER_SPEC.md',
    'docs/v4/preimplementation/LOCAL_AGENT_BOOTSTRAP_v8.0.md',
    'docs/v4/preimplementation/FINAL_HANDOFF_RECHECK_v8.1.md',
    'docs/v4/preimplementation/CANONICAL_FLAG_MAP_v8.0.json',
    'docs/v4/preimplementation/M08_WEST_ANCHOR_RESTORATION_v8.0.md',
    'lib/main_v4_preview.dart',
]
for p in required:
    if not (ROOT/p).exists(): fail(f'missing required path: {p}')

for p in ['CLAUDE.md','README.md','AGENT_START_HERE.md','docs/v4/final/MASTER_SPEC.md']:
    t=read(p)
    if 'CURRENT_AUTHORITY_2026-10-02.md' not in t: fail(f'{p}: missing 2026-10-02 authority')

bootstrap=read('docs/v4/preimplementation/LOCAL_AGENT_BOOTSTRAP_v8.0.md')
if 'CURRENT_AUTHORITY_2026-10-01.md' in bootstrap: fail('bootstrap points to old 10-01 authority')
if 'CLAUDE.md\nHANDOFF.md\nGAME_DESIGN.md\nREADME.md' in bootstrap: fail('bootstrap still marks current CLAUDE/README as legacy')

# 2. legacy quarantine
for p in ['HANDOFF.md','GAME_DESIGN.md']:
    first='\n'.join(read(p).splitlines()[:6])
    if 'LEGACY PRE-v4' not in first: fail(f'{p}: legacy banner missing')
for p in ['docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md','docs/v4/final/FINAL_AUDIT_2026-10-01.md']:
    first='\n'.join(read(p).splitlines()[:6])
    if 'SUPERSEDED' not in first: fail(f'{p}: superseded banner missing')

# 3. package completeness
v6=ROOT/'docs/v4/design/v6'
v7=ROOT/'docs/v4/narrative/v7'
v8=ROOT/'docs/v4/preimplementation'
for name in [
'A_v6.0_ACT_III_DATA.json','A_v6.0_CHECKPOINT_AUDIT.md',
'B_v6.1_ACT_IV_COMPANION_DATA.json','B_v6.1_CHECKPOINT_AUDIT.md',
'C_v6.2_ACT_V_ENDING_DATA.json','C_v6.2_CHECKPOINT_AUDIT.md',
'D_v6.3_COMPANION_QUEST_INTEGRATION.json','D_v6.3_FULL_WALKTHROUGH_STATE_TRACE.json',
'D_v6.3_LATE_GEAR_SPELL_HUB_DATA.json','D_v6.3_STATE_FLAG_MATRIX.json',
'D_v6.3_TACTICAL_MAP_LAYOUTS.json','D_v6.3_WORLD_EVENT_POOL_98.json','D_v6.3_XP_ECONOMY_AUDIT.json',
'validate_v6_campaign.py','VALIDATION_RUN.txt']:
    if not (v6/name).exists(): fail(f'v6 package missing {name}')
for name in [
'N1_v7.0_CHARACTER_NPC_VOICE_DATA.json','N2_v7.1_ACT_I_II_SCRIPT_DATA.json',
'N3_v7.2_ACT_III_SCRIPT_DATA.json','N4_v7.3_ACT_IV_SCRIPT_DATA.json',
'N5_v7.4_ACT_V_SCRIPT_DATA.json','N6_v7.5_COMPANION_PQ_SCRIPT_DATA.json',
'N7_v7.6_HUB_NPC_DIALOGUE_DATA.json','N8_v7.7_COMPANION_REACTIONS_BANTER_BARK_DATA.json',
'N9_v7.8_FULL_DIALOGUE_CATALOG.json','N9_v7.8_NARRATIVE_AUDIT_DATA.json',
'validate_v7_narrative.py','VALIDATION_RUN.txt']:
    if not (v7/name).exists(): fail(f'v7 package missing {name}')
for n in range(1,9):
    matches=list(v7.glob(f'N{n}_v*.CHECKPOINT_AUDIT.md'))
    if not matches:
        # actual names use _CHECKPOINT_AUDIT; fallback exact glob
        matches=list(v7.glob(f'N{n}_v*_CHECKPOINT_AUDIT.md'))
    if not matches: fail(f'v7 checkpoint audit N{n} missing')

# 4. all JSON parse
for base in [v6,v7,v8]:
    for p in base.glob('*.json'):
        try: json.loads(p.read_text(encoding='utf-8'))
        except Exception as e: fail(f'JSON parse failed {p.relative_to(ROOT)}: {e}')

# 5. important invariants
flags=load('docs/v4/preimplementation/CANONICAL_FLAG_MAP_v8.0.json')
if set(flags['exclusive_choice_groups']) != {'M01','M02','M03','M04','M05','M06','M07','M08','C01'}:
    fail('choice groups mismatch')
if len(flags['exclusive_choice_groups']['M08']) != 3: fail('M08 option count mismatch')
xp=load('docs/v4/preimplementation/XP_TRANSITION_FLOOR_v8.0.json')['transitionMinimumXp']
if xp['ACT_II_TO_III']!=1640 or xp['ACT_III_TO_IV']!=4130 or xp['ACT_IV_TO_V']!=7030:
    fail('XP floors mismatch')
poi=load('docs/v4/preimplementation/POI_EVENT_AUTHORITY_v8.0.json')
if len(poi['canonicalPOIs'])!=20 or len(poi['canonicalSideEventIds'])!=24:
    fail('POI/side-event count mismatch')
cat=load('docs/v4/narrative/v7/N9_v7.8_FULL_DIALOGUE_CATALOG.json')['dialogue']
ids=[x['id'] for x in cat]
if len(cat)!=1152 or len(ids)!=len(set(ids)) or any(not x['text_ko'].strip() for x in cat):
    fail('dialogue catalog invariant failed')

# 6. monetization contamination
pub=read('pubspec.yaml')
if 'google_mobile_ads' in pub: fail('google_mobile_ads still present')

# 7. unified handoff points to latest authority and copies live overlays
hs=read('artifacts/v4/FINAL_COMPLETE_HANDOFF/00_START_HERE.md')
bs=read('artifacts/v4/FINAL_COMPLETE_HANDOFF/build_final_complete_handoff.sh')
for t in [hs,bs]:
    if 'CURRENT_AUTHORITY_2026-10-02.md' not in t: fail('final handoff still points to old authority')
for token in ['docs/v4/design/v6','docs/v4/narrative/v7','docs/v4/preimplementation']:
    if token not in bs: fail(f'final handoff builder does not include {token}')

# 8. current index references must exist (only repository-looking tokens)
def check_refs(rel):
    txt=read(rel); base=(ROOT/rel).parent
    for token in re.findall(r'`([^`\n]+)`',txt):
        token=token.strip()
        if any(c in token for c in '<>|*{}[]') or ' ' in token: continue
        if token.endswith('/'):
            target=ROOT/token if '/' in token else base/token
        elif re.search(r'\.(md|json|py|txt|xz|dart|yaml|yml|sh)$',token):
            if token.startswith(('docs/','lib/','tool/','test/','assets/','artifacts/')) or token in {'CLAUDE.md','README.md','HANDOFF.md','GAME_DESIGN.md','AGENT_START_HERE.md','pubspec.yaml'}:
                target=ROOT/token
            else:
                target=base/token
        else:
            continue
        if not target.exists(): fail(f'broken reference in {rel}: {token}')
for rel in ['docs/v4/design/v6/00_INDEX.md','docs/v4/narrative/v7/00_INDEX.md','docs/v4/preimplementation/00_INDEX.md']:
    check_refs(rel)

# 9. run original package validators and v8 validator
for script in [v6/'validate_v6_campaign.py',v7/'validate_v7_narrative.py',v8/'validate_v8_preimplementation.py']:
    cp=subprocess.run([sys.executable,str(script)],cwd=script.parent,capture_output=True,text=True)
    if cp.returncode:
        fail(f'validator failed {script.name}: {cp.stdout}\n{cp.stderr}')

print('V8_1_FRESH_CLONE_HANDOFF_VALIDATION_OK')
print('v6_json',len(list(v6.glob('*.json'))),'v7_json',len(list(v7.glob('*.json'))),'v8_json',len(list(v8.glob('*.json'))))
print('dialogue_entries',len(cat),'broken_refs',0)