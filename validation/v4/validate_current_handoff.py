from pathlib import Path
import json, sys

# This validator expects the extracted post-v3.6 handoff layout.
ROOT=Path(__file__).resolve().parents[2]
E=ROOT/'current'/'contract_examples_reconciled'

def load(n):
    return json.loads((E/n).read_text(encoding='utf-8'))

def uniq(xs,label):
    ids=[x['id'] for x in xs]
    if len(ids)!=len(set(ids)):
        raise AssertionError(f'duplicate {label} ids')

def main():
    equipment=load('equipment.json')['items']
    spells=load('spells.json')['spells']
    encounters=load('encounters_act1_act2.json')['encounters']
    rewards=load('rewards_act1_act2.json')['rewards']
    world=load('world.json')
    for xs,l in [(equipment,'equipment'),(spells,'spell'),(encounters,'encounter'),(rewards,'reward')]:
        uniq(xs,l)
    assert len(equipment)==34
    assert len(spells)==30
    assert len(world['hubs'])==11 and len(world['regions'])==14 and len(world['dungeons'])==9
    reward_ids={r['id'] for r in rewards}
    assert all(e['rewardId'] in reward_ids for e in encounters)
    for e in encounters:
        c=e['board']['columns']; r=e['board']['rows']
        assert 6<=c<=12 and 5<=r<=9
        for s in e['spawns']:
            assert 0<=s['q']<c and 0<=s['r']<r
            assert s['level']==e['recommendedLevel']
    by={'act1':[],'mine':[],'swamp':[],'ruin':[]}
    for e in encounters:
        tags=set(e['tags'])
        k='act1' if 'I' in tags else 'mine' if 'R03' in tags else 'swamp' if 'R04' in tags else 'ruin'
        by[k].append(e)
    assert {k:len(v) for k,v in by.items()}=={'act1':9,'mine':5,'swamp':5,'ruin':5}
    core={k:sum(e['xpReward'] for e in v if 'OPTIONAL' not in e['tags']) for k,v in by.items()}
    assert core=={'act1':355,'mine':295,'swamp':285,'ruin':303}, core
    print('CURRENT_HANDOFF_VALIDATION_OK')
    print('equipment=34 spells=30 encounters=24 hubs=11 regions=14 dungeons=9')
    print('core_xp',core)

if __name__=='__main__':
    try:
        main()
    except Exception as exc:
        print('CURRENT_HANDOFF_VALIDATION_FAILED',repr(exc))
        sys.exit(1)
