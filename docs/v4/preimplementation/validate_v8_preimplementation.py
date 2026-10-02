from pathlib import Path
import json
R=Path(__file__).resolve().parent
def load(n): return json.loads((R/n).read_text(encoding="utf-8"))
flags=load("CANONICAL_FLAG_MAP_v8.0.json")
m08_text=(R/"M08_WEST_ANCHOR_RESTORATION_v8.0.md").read_text(encoding="utf-8")
xp=load("XP_TRANSITION_FLOOR_v8.0.json")
poi=load("POI_EVENT_AUTHORITY_v8.0.json")
enc=load("ENCOUNTER_RUNTIME_EXTENSION_v8.0.json")
assert len(flags["exclusive_choice_groups"])==9
assert "west_anchor_method_blast" in flags["exclusive_choice_groups"]["M08"]
assert "광산 구조 폭파" in m08_text
assert xp["transitionMinimumXp"]["ACT_II_TO_III"]==1640
assert xp["transitionMinimumXp"]["ACT_III_TO_IV"]==4130
assert xp["transitionMinimumXp"]["ACT_IV_TO_V"]==7030
assert len(poi["canonicalPOIs"])==20
assert len(poi["canonicalSideEventIds"])==24
assert "victoryCondition" in enc["requiredFieldsOrEquivalent"]
print("V8_PREIMPLEMENTATION_AUDIT_VALIDATION_OK")
