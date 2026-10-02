from pathlib import Path
import json, collections, sys
ROOT=Path(__file__).resolve().parent
def load(name): return json.loads((ROOT/name).read_text(encoding="utf-8"))
n1=load("N1_v7.0_CHARACTER_NPC_VOICE_DATA.json")
n2=load("N2_v7.1_ACT_I_II_SCRIPT_DATA.json")
n3=load("N3_v7.2_ACT_III_SCRIPT_DATA.json")
n4=load("N4_v7.3_ACT_IV_SCRIPT_DATA.json")
n5=load("N5_v7.4_ACT_V_SCRIPT_DATA.json")
n6=load("N6_v7.5_COMPANION_PQ_SCRIPT_DATA.json")
n7=load("N7_v7.6_HUB_NPC_DIALOGUE_DATA.json")
n8=load("N8_v7.7_COMPANION_REACTIONS_BANTER_BARK_DATA.json")
cat=load("N9_v7.8_FULL_DIALOGUE_CATALOG.json")
aud=load("N9_v7.8_NARRATIVE_AUDIT_DATA.json")

scene_ids=[]
for x in [n2,n3,n4,n5,n6]:
    scene_ids += [s["id"] for s in x["scenes"]]
assert len(scene_ids)==len(set(scene_ids)), "duplicate scene IDs"

assert "해방파" not in json.dumps(n2,ensure_ascii=False)
assert "공명체" not in json.dumps(n2,ensure_ascii=False)
assert "공명체" not in json.dumps(n3,ensure_ascii=False)
assert "안정화망" not in json.dumps(n2,ensure_ascii=False)
assert "안정화망" not in json.dumps(n3,ensure_ascii=False)

expected={"M01":2,"M02":2,"M03":3,"M04":3,"M05":3,"M06":2,"M07":3,"C01":2}
for c,n in expected.items():
    opts=n8["major_choice_reactions"][c]
    assert len(opts)==n
    for r in opts.values():
        assert set(r)=={"kael","erin","nera","seon","luka"}

hub_ids={n["id"] for n in n1["npcs"] if n["hub"]}
assert set(n7["npc_topics"])==hub_ids
assert all(len(v)>=3 for v in n7["npc_topics"].values())
assert set(n7["rumors"])=={f"T{i:02d}" for i in range(1,12)}
assert sum(len(v) for v in n7["rumors"].values())==33

pairs=set(n8["travel_banter"])
assert len(pairs)==10
assert sum(len(v) for v in n8["travel_banter"].values())==20

pq=collections.Counter(s["owner"] for s in n6["scenes"])
assert pq=={"kael":6,"erin":6,"nera":6,"seon":6,"luka":6}

epi=next(s for s in n5["scenes"] if s["id"]=="EPILOGUE_WORLD")
assert set(epi["hub_epilogues"])=={f"T{i:02d}" for i in range(1,12)}
assert set(epi["companion_epilogues"])=={"kael","erin","nera","seon","luka"}

final=next(s for s in n5["scenes"] if s["id"]=="C01_FINAL_CHOICE")
assert {o["id"] for o in final["options"]}=={"RESTORE","CHANGE"}
assert not any("condition" in o for o in final["options"])

ids=[d["id"] for d in cat["dialogue"]]
assert len(ids)==len(set(ids))
assert all(d["text_ko"].strip() for d in cat["dialogue"])

assert not aud["errors"], aud["errors"]
assert all(x["status"]=="COVERED" for x in aud["main_beat_crosswalk"])

print("V7_FULL_NARRATIVE_VALIDATION_OK")
print("main_scenes",aud["counts"]["main_scenes"])
print("personal_quest_scenes",aud["counts"]["personal_quest_scenes"])
print("dialogue_entries",aud["counts"]["dialogue_catalog_entries"])
print("named_npcs",aud["counts"]["named_npcs"])
print("major_choice_reactions",aud["counts"]["major_choice_reactions"])
print("travel_banter_variants",aud["counts"]["travel_banter_variants"])
print("combat_barks",aud["counts"]["combat_barks"])