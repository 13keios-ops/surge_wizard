# COMPLETE_DECISION_LOG — Surge Wizard v4

> Current-decision handoff distilled from the design/prototype conversation. This is not a verbatim chat transcript. If this conflicts with the v3.5 master spec, the master spec wins unless a newer user instruction says otherwise.

## Product identity
- v4 is a **landscape mobile RPG**.
- “Vertical Slice” is the standard game-development term; it does not mean portrait orientation.
- Emotional premise: **raise my wizard** — a novice develops into “my wizard.”
- Prefer environmental/discovery storytelling and short 2–5 line events over exposition-heavy fetch-quest presentation.
- Current v4 direction is a full/paid RPG, not a login/daily/gacha/ad-driven core loop.
- Town/city is a one-screen illustrated hub with tappable buildings; no town walking simulation.
- Town entry restores HP/MP.

## Party / progression
- Active party: Wizard + up to 2 companions = 3.
- Party swaps in town; bench companions receive 100% XP.
- Stats: STR / DEX / CON / MND.
- Proficiency 0–4.
- Mana: `40 + MND*6 + level*2 + equipment`.
- Prepared spell categories: attack/control/defense; starting 3/category, max 4/category, total 12.
- Cantrips do not consume slots.

## World movement
- World travel uses Hex.
- 1 world Hex = 0.5 day.
- Day/night flips each Hex.
- World travel displays only the protagonist icon.
- No survival-meter subsystem.

## Tactical board / camera
- Landscape 3/4 oblique/top-down tactical battle.
- Default camera pitch **42°**, acceptable 40–44°.
- Orthographic preferred.
- Party left; enemies right.
- Standard board 9×7; variants 8×6–11×7.
- Normal footprint 1; Large 3; Huge 7.
- Boss pitch remains fixed; use framing/zoom for size.
- No ordinary actor-to-actor camera pans.

## Timeline / turn structure
- No rounds; absolute `nextActionTime`.
- Speed = `100 + 2*(DEX-5) + gear/status`, clamp 80–130.
- Base delays: 70 / 85 / 100 / 130 / 160 / 180 from fast through huge.
- Effective delay = `round(BaseDelay*100/Speed)` then status modifiers.
- Slow/Haste affect the delay produced by the current activation before their duration decrements.
- Move → Act is allowed.
- One voluntary move per activation.
- No ordinary post-action movement unless a skill permits it.
- Wizard/warrior/paladin/priest Move 2; rogue/ranger Move 3.
- Leaving engagement can trigger one opportunity reaction; teleport/disengage bypasses it.
- Opportunity attacks: -1 accuracy, no timeline delay.

## Encounter scale
- Standard around 3v3.
- Weak mobs can reach 3v9.
- Boss fights may be 3v1.
- Wizard target share roughly 40–60% of party damage.

## Combat checks
- Internal system uses 3d6.
- Baseline defense 11.
- EVASION = `11 + DEX mod + equip/status + cover`.
- FORTITUDE = `11 + CON mod`.
- RESOLVE = `11 + MND mod`.
- BRACE = `11 + max(STR mod, CON mod) + equip/status`.
- Attack = `3d6 + primary + mastery + skillAcc + equipAcc + temp`.
- Natural 3 = miss.
- Natural 18 = hit + crit.
- Crit = ×1.5.
- Damage uses authored power/stat terms, seeded 90–110% variance, mitigation, elemental modifiers, then Barrier.
- Direct ranged attacks receive Cover `EVA +2`.
- Attack spells also perform direct hit checks vs EVASION; Stability success is not automatic hit.

## Stability / Surge
- `3d6 + MND mod + mastery + equipCast + tempCast >= 9 + circle + difficulty + conditionPenalty`.
- C1..C9 normal DC 10..18.
- margin >=0 Stable.
- -1..-3 Unstable.
- <=-4 Surge.
- Natural 3 Surge candidate.
- Natural 18 + success Perfect candidate.
- Current prototype Perfect refund: 20% MP.
- Unstable penalty is spell-defined.
- Fireball Surge shifts the center by one neighboring Hex.
- AoE shape is spell-fixed, not mastery-expanded.
- Shapes: Single / Line / Burst7 / Cone / Row / Chain / All / Self.

## Status model
Activation-based, not round-based:
- Burning
- Bleeding
- Poisoned
- Slowed
- Rooted
- Stunned
- Exposed
- Weakened
- Disrupted
- Barrier
- Guarded
- Haste
- Marked

Boss control conversion:
- Stun can convert to Stagger.
- Root can convert to Slow.
- No universal boss control immunity.
- Status communication must not depend on color alone.

## KO / wipe
- 0 HP = KO.
- No default midbattle revive.
- Victory carry revives a KO companion to 1 HP.
- Wipe returns to a safe point.
- Used consumables remain consumed.
- No gold loss.

## UI
- Timeline top, roughly 6–8 actors.
- AUTO/speed upper-right.
- Party HUD lower-left.
- Target/action preview lower-right.
- First radial level <=4: Attack / Control / Defense / Tool.
- Second skill ring replaces the first ring.
- Preview should mature toward damage/hit/effect/targets/Surge/timeline information.
- Accessibility includes sound/haptic/icon/color/text size/speed/shake/log detail.

## AUTO
- Tutorial introduces AUTO around battle 3.
- Same combat rules as manual.
- 1×/2×/3×.
- Player AUTO consumables default OFF.
- Balanced AUTO prototype scores expected damage, kill, multi-target, control, survival, position, target priority, minus mana/delay/Surge risk.
- 3d6 probabilities are enumerated across all 216 outcomes.
- Headless AI may perform minimal obvious Telegraph avoidance.

## Companion prototype skills

Kael:
- Quick Slash: Accuracy +1 / Delay 90.
- Heavy Strike: Power +5 / Accuracy -1 / Delay 130.
- Guard Stance: Guarded 20%, 2 activations / Delay 95.
- Hook Pull: Range 3 / BRACE / Pull 1 / Delay 110.

Nera:
- Vital Strike: Power +6, improved against Exposed / Delay 110.
- Expose Weakness: Range 3 / EVASION / Exposed 2 / Delay 90.
- Smoke Step: Range 3 / opportunity bypass / Guarded 15% / Delay 85.

## Bone Heap
- Bone Throw: +4 / raw 13 / Range 5 / Delay 90.
- Bone Sweep: +5 / raw 16 / Cone3 / resolve Delay 105.
- Sweep telegraphs fixed danger Hexes first; current wind-up fixture Base Delay 55.
- Bone Cage: FORT / Root 1 / Delay 120.
- Reassemble <=60% HP once: Barrier 25 + Skeleton Apprentice ×1 + timeline adjustments.
- Fractured Core <=30%: incoming Accuracy +1; Sweep damage +15%.
- Intended as phase/telegraph-driven, not an HP sponge.

## Vertical Slice
ACT II: Mossbridge → 4 world Hex → Oldcross → Broken Archive; target 45–60m.
Start: Wizard Lv7, Kael Lv7, Gold 520, Essence 20, HP Potion 2.

- B01 Goblin ×4.
- B02 Skeleton ×3 + Gargoyle ×1; Nera present from this phase.
- B03 Cursed Armor ×2 + Skeleton ×2 + Gargoyle ×1.
- B04 optional Cursed Armor ×1 + Skeleton ×2.
- B05 Bone Heap + Skeleton ×2.

Flow:
`B01 → B02 → B03 → [B04 Optional or skip] → B05`.

After B03 Boss Antechamber:
- Party HP Full.
- Wizard MP floor 100.
- Start Ward Barrier 10.
- Potion not restored.

B04 Ancient Focus current fixture:
- Wizard MP +40.
- B05 Start Barrier 25.

## Validation interpretation
- Python behavioral mirrors were actually executed.
- Dart/Flutter was **not** executed in the generation environment because no SDK was installed.
- Python results are reference baselines, not proof of Dart compilation.
- QA seed commonly used: `23092026`.
- Latest v3.4 mirror recorded about B01 99.9%, B02 99.7%, B03 97.4%, B04 100%, B05 86.7% under telegraph-aware AUTO.
- Main sequential route ~81.7%; Optional ~82.9%.
- These are mirror reference numbers, not authoritative Dart baselines.

## Campaign/world scale
- Main story 20–25h; typical play 25–35h.
- 11 hubs, 14 regions, 9 dungeons, 5 companions, roughly 10–15 bosses.
- Level bands: Act I 1–4, II 4–9, III 9–15, IV 15–20, V 20–25.

## Spell scale
- 57 candidate spells C0–C6.
- C4 DC13 / C5 DC14 / C6 DC15.
- Learn costs C4 44 / C5 64 / C6 90.
- Access: C4 Act III+Lv9; C5 D05+Lv13; C6 D07+flag+Lv17.
- C7 is an Act V story breakthrough; first free; provisional.

## Enemy / boss content
- 26 normal base enemies; variants are code-driven recolors, not new art.
- 12 authored bosses.
- `boss_dice_devourer` is deferred/unassigned and should not be produced.
- Full rosters and tables remain in the master/archive.

## Graphics decisions affecting implementation
- One cohesive game-screen style.
- Character/enemy/boss: square high-res transparent assets; smooth high-detail rendering without forcing a pixel grid.
- Character foot contact y = 477/512 canvas height; top margin >=8%.
- Background plate is opaque and flatter/simpler than characters.
- Layered background: fixed plate + separate goal building + separate roadside objects; do not vertically scroll one perspective painting.
- Current approved style refs include current wizard, goblin scout, elder slime.
- Old `bg_forest` is not current background authority.

## Architecture
Legacy portrait controller assumptions are incompatible with v4 because it assumes single enemy, player/enemy alternation, dice/reroll phase and hand index.

v4 needs party3, multi-enemy, `nextActionTime`, Hex movement, activation statuses, reactions and AUTO.

- Keep implementation files around 300 lines by splitting responsibilities.
- Legacy `lib/main.dart` remains untouched.
- v4 entry point: `lib/main_v4_preview.dart`.

## Handoff principle
**Preserve first, prune later.**
The repository should carry the current spec, historical specs, implementation source, tests, validation methods, baseline outputs, proof images, reports and package-history logical contents.
The next implementation agent decides what can be retired.
