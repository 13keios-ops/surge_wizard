from pathlib import Path
import json, itertools, sys

ROOT=Path(__file__).resolve().parent
def load(n): return json.loads((ROOT/n).read_text(encoding="utf-8"))

A=load("A_v6.0_ACT_III_DATA.json")
B=load("B_v6.1_ACT_IV_COMPANION_DATA.json")
C=load("C_v6.2_ACT_V_ENDING_DATA.json")
L=load("D_v6.3_LATE_GEAR_SPELL_HUB_DATA.json")
E=load("D_v6.3_WORLD_EVENT_POOL_98.json")
M=load("D_v6.3_TACTICAL_MAP_LAYOUTS.json")
P=load("D_v6.3_COMPANION_QUEST_INTEGRATION.json")
F=load("D_v6.3_STATE_FLAG_MATRIX.json")
W=load("D_v6.3_FULL_WALKTHROUGH_STATE_TRACE.json")
X=load("D_v6.3_XP_ECONOMY_AUDIT.json")

def unique(items,key="id"):
    vals=[x[key] for x in items]
    assert len(vals)==len(set(vals)), f"duplicate {key}"

# Encounter IDs
all_enc=A["encounters"]+B["encounters"]+C["encounters"]
unique(all_enc)

# ACT V exact XP
assert sum(x["xp"] for x in C["encounters"] if x["mandatory"])==2965
assert sum(x["xp"] for x in C["story_xp"])==685
assert 2965+685==3650

# ACT IV target proximity
a4=4130+sum(x["xp"] for x in B["encounters"] if x["mandatory"])+sum(x["xp"] for x in B["story_xp"])
assert a4==7000

# ACT III target proximity
a3=1640+sum(x["xp"] for x in A["encounters"] if x["mandatory"])+sum(x["xp"] for x in A["story_xp"])
assert a3==3935

# Gear
gear=L["late_gear"]
unique(gear)
assert len(gear)>=30
assert all(g["tier"] in (3,4,5) for g in gear)
assert len(L["hub_stock"])==11

# Spells
assert L["spell_integration"]["C4_C6_count"]==27
assert len(L["spell_integration"]["C7"])==3
unique(L["spell_integration"]["C7"])

# Events
events=E["events"]
unique(events)
assert len(events)==98
for rid in [f"R{i:02d}" for i in range(1,15)]:
    rs=[e for e in events if e["region"]==rid]
    fam={f:sum(1 for e in rs if e["family"]==f) for f in ["COMBAT","DISCOVERY","RESOURCE","RARE"]}
    assert fam=={"COMBAT":2,"DISCOVERY":2,"RESOURCE":2,"RARE":1}, (rid,fam)

# Maps
maps=M["maps"]
unique(maps)
assert len(maps)>=38
for m in maps:
    assert 6<=m["columns"]<=12 and 5<=m["rows"]<=9
    coords=[]
    for group in [m["partySpawn"],m["enemySpawnSlots"],m["terrain"]]:
        for c in group:
            assert 0<=c["q"]<m["columns"] and 0<=c["r"]<m["rows"], (m["id"],c)
    if m.get("bossSpawnAnchor"):
        c=m["bossSpawnAnchor"]
        assert 0<=c["q"]<m["columns"] and 0<=c["r"]<m["rows"]

# Companion quests
assert len(P["companions"])==5
assert all(not x["main_gate"] and not x["ending_lock"] for x in P["companions"])

# Choice exclusivity
for group,flags in F["choice_groups"].items():
    assert len(flags)==len(set(flags)) and len(flags)>=2

# Easter flags not ending group
ending=set(F["choice_groups"]["C01"])
easter=set(F["durable_flags"]["easter"])
assert not ending & easter

# 648 main-choice combinations all have defined anchor fallbacks by construction.
groups=[F["choice_groups"][k] for k in ["M01","M02","M03","M04","M05","M06","M07"]]
combos=list(itertools.product(*groups))
assert len(combos)==648
for _ in combos:
    for a in C["anchors"].values():
        assert a["fallback"]

# Walkthrough
assert W["trace"][-1]["state"].startswith("11 Hub")
assert any("C01 committed" in x["state"] for x in W["trace"])

# XP global checks
xp=X["xp"]
assert xp["act1"]["target_end"]==390
assert xp["act2"]["two_arc_end"]==1640
assert xp["act5"]["end_reference"]==10680

print("V6_CAMPAIGN_VALIDATION_OK")
print("encounters_act3",len(A["encounters"]))
print("encounters_act4",len(B["encounters"]))
print("encounters_act5",len(C["encounters"]))
print("late_gear",len(gear))
print("events",len(events))
print("maps",len(maps))
print("choice_combinations_checked",len(combos))
print("xp_act3_end",a3,"xp_act4_end",a4,"xp_act5_end",xp["act5"]["end_reference"])