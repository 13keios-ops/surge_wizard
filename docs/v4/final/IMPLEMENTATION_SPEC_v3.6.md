# Surge Wizard v4 â€” Implementation Specification v3.6

**Scope:** Path Preview Â· Pre-commit Combat Preview Â· Detailed Combat Log Â· Safe Point Save/Restore

**Status:** implementation-ready specification supplement to v3.5.  
**Authority:** newer explicit user instruction > this document > v3.5 master where the topic overlaps.

---

## 1. Goal of v3.6

v3.5 made the Vertical Slice manually playable in structure. v3.6 defines the information and persistence layer needed before real device playtesting.

The implementation must make four things true:

1. A player can see **where a move will actually travel** before committing it.
2. A player can see **what an action is expected to do** before consuming MP / action time / RNG.
3. A developer or player can reconstruct **why an outcome happened** from the combat log.
4. A Vertical Slice run can survive app restarts and wipes without duplicating rewards or refunding consumed items.

This is a specification pass. It does not claim that these features have already been implemented or executed.

---

# 2. Path Preview

## 2.1 Interaction model

Current v3.5 behavior moves immediately when a reachable Hex is tapped. Replace it with a two-stage mobile-safe interaction.

```text
MOVE button
â†’ reachable Hexes appear
â†’ first tap on a reachable Hex = preview destination
â†’ path line + cost + risk appears
â†’ tap same Hex again OR press MOVE CONFIRM = commit movement
â†’ actor moves
â†’ activation remains open for Act
```

Rules:

- Tapping another reachable Hex changes the preview destination.
- Tapping an unreachable Hex clears only the destination preview; MOVE mode stays open.
- Back exits MOVE mode without moving.
- After one voluntary move, ordinary MOVE becomes unavailable for that activation.
- Rooted disables voluntary MOVE.
- Forced movement / teleport skills use their own preview and do not consume voluntary movement unless the skill definition says so.

Reason for two-stage confirmation: on a touch device, path information is only useful if the player can inspect it before movement is committed.

## 2.2 Pathfinding authority

The **engine pathfinder** is the authority. UI must never invent a visually shorter path that the engine would not use.

Add a deterministic path API:

```dart
PathResultV4 shortestPath({
  required CombatUnitV4 unit,
  required HexCoord destination,
  required Iterable<CombatUnitV4> units,
  int? budget,
});
```

`PathResultV4`:

```text
path: [start, ..., destination]
movementCost: int
remainingMovement: int
opportunityEdges: List<OpportunityRiskV4>
terrainEntries: List<TerrainEntryV4>
valid: bool
failureReason: optional enum
```

Tie-break order must be deterministic:

1. lower total movement cost
2. fewer opportunity-trigger edges
3. fewer hazard tiles
4. fewer steps
5. lexicographic Hex order `(col,row)`

This tie-break is for selecting among equally legal paths; it must not silently choose a higher movement-cost path just to avoid opportunity attacks.

## 2.3 Terrain cost

The existing board rules remain authoritative.

```text
Normal / Cover / Forest : cost 1 unless separately authored
Water                    : cost 2
Block                    : impassable
```

If later terrain adds a movement modifier, `CombatBoardV4.movementCost()` remains the single source of truth.

## 2.4 Opportunity preview

Opportunity risk is evaluated **per path edge**, not merely at the final Hex.

An opportunity trigger exists when an edge moves the actor from adjacent to an eligible enemy to non-adjacent.

Preview records:

```text
reactorId
fromHex
toHex
estimatedHitChance
estimatedDamageMinMax
```

The path is still legal even when opportunity attacks are predicted.

Nera Smoke Step / explicit Disengage / Teleport:

```text
opportunityEdges = []
```

and the path graphic uses a teleport/dashed style rather than ordinary footsteps.

## 2.5 Visual language

Do not rely on color alone.

- Reachable area: existing blue-tinted fill + subtle border.
- Preview path: solid center-to-center line with small step dots.
- Destination: outlined Hex + endpoint marker.
- Water/high-cost step: small `2` cost pip or terrain icon.
- Opportunity edge: `!` marker placed on the relevant segment.
- Telegraph overlap: warning icon on the overlapping Hex; Telegraph remains visually higher priority than movement.

Layer order remains:

```text
terrain
passive grid
hazard
movement reachable
path line
selected target / skill area
enemy telegraph
units
floating information
UI overlay
```

Enemy Telegraph always wins visual priority over the move path.

## 2.6 Path Preview panel

While previewing movement, lower-right Context Preview shows:

```text
MOVE Â· (col,row)
Cost 2 / Move 3
Remaining 1
Opportunity Ã—1
Water Ã—1
```

If no risk:

```text
Opportunity ì—†ìŒ
```

If destination intersects a known enemy Telegraph:

```text
âš  Enemy Telegraph
```

## 2.7 Path Previeu…•ÁÑ…¹”Ñ•ÍÑÌ()I•ÅÕ¥É•Ñ•ÍÑÌè((Ä¸Í¡½ÉÑ•ÍĞÁ…Ñ É•ÍÁ•ÑÌ]…Ñ•È½ÍĞ¸(È¸	±½¬¹•Ù•È…ÁÁ•…ÉÌ¥¸„Á…Ñ ¸(Ì¸½ÕÁ¥•!•à¹•Ù•È…ÁÁ•…ÉÌ…Ì„‘•ÍÑ¥¹…Ñ¥½¸½Á…Ñ ¹½‘”Õ¹±•ÍÌ•áÁ±¥¥Ñ±ä…±±½İ•‰ä„Í­¥±°¸(Ğ¸Í…µ”ÍÑ…Ñ”…±İ…åÌÉ•ÑÕÉ¹ÌÑ¡”Í…µ”Ñ¥•Á…Ñ ¸(Ô¸½ÁÁ½ÉÑÕ¹¥ÑäÉ¥Í¬¥Ì…ÑÑ…¡•Ñ¼Ñ¡”½ÉÉ•Ğ•‘”¸(Ø¸9•É„Mµ½­”MÑ•ÀÁÉ½‘Õ•Ì¹¼½ÁÁ½ÉÑÕ¹¥ÑäÉ¥Í¬¸(Ü¸I½½ĞÁÉ•Ù•¹ÑÌÙ½±Õ¹Ñ…ÉäÁ…Ñ ÁÉ•Ù¥•Ü½½µµ¥Ğ¸(à¸ÁÉ•Ù¥•Ü‘½•Ì¹½ĞµÕÑ…Ñ”…Ñ½ÈÁ½Í¥Ñ¥½¸°I9°É•…Ñ¥½¸ÍÑ…Ñ”°½ÈÑ¥µ•±¥¹”¸(ä¸Í•½¹Ñ…À½½¹™¥É´½µµ¥ÑÌ•á…Ñ±äÑ¡”Á…Ñ ÁÉ•Ù¥½ÕÍ±äÁÉ•Ù¥•İ•¥˜ÍÑ…Ñ”‘¥¹½Ğ¡…¹”¸(ÄÀ¸¥˜ÍÑ…Ñ”¡…¹•Ì‰•™½É”½¹™¥Éµ…Ñ¥½¸°Á…Ñ ¥ÌÉ•…±Õ±…Ñ•…¹¥¹Ù…±¥½¹™¥Éµ…Ñ¥½¸¥ÌÉ•©•Ñ•¸((´´´((Œ€Ì¸AÉ”µ½µµ¥Ğ½µ‰…ĞAÉ•Ù¥•Ü((ŒŒ€Ì¸ÄAÉ¥¹¥Á±”()AÉ•Ù¥•Ü¥Ì€¨©ÁÕÉ”…±Õ±…Ñ¥½¸¨¨¸()%ĞµÕÍĞ¹½Ğè((´½¹ÍÕµ”I9(´¡…¹”!@½5@(´…ÁÁ±äMÑ…ÑÕÌ(´µ½Ù”Ñ¥µ•±¥¹”(´½¹ÍÕµ”É•…Ñ¥½¹Ì(´…±Ñ•È	…ÉÉ¥•È(´µÕÑ…Ñ”Ñ¡”½µ‰…Ğ±½œ()Q¡”Í…µ”ÁÉ•Ù¥•Ü…¸‰”É•ÅÕ•ÍÑ•É•Á•…Ñ•‘±äİ¥Ñ¡½ÕĞ¡…¹¥¹œÑ¡”•Ù•¹ÑÕ…°½µ‰…ĞÉ•ÍÕ±Ğ¸((ŒŒ€Ì¸ÈAÉ½‰…‰¥±¥Ñä•¹¥¹”()UÍ”•á…Ğ€ÍØ•¹Õµ•É…Ñ¥½¸°¹½Ğ5½¹Ñ”…É±¼¸()Ñ•áĞ(Øƒ\€Øƒ\€Ø€ô€ÈÄØ½ÕÑ½µ•Ì)€()É•…Ñ”„Í¡…É•ÁÉ½‰…‰¥±¥Ñä¡•±Á•ÈÕÍ•‰äU$…¹UQ<Í½É¥¹œè()‘…ÉĞ)AÉ½‰…‰¥±¥Ñå	É•…­‘½İ¹XĞ…ÑÑ…­AÉ½‰…‰¥±¥Ñä ¸¸¸¤)AÉ½‰…‰¥±¥Ñå	É•…­‘½İ¹XĞ•™™•ÑAÉ½‰…‰¥±¥Ñä ¸¸¸¤)…ÍÑAÉ½‰…‰¥±¥ÑåXĞ…ÍÑAÉ½‰…‰¥±¥Ñä ¸¸¸¤)€()Q¡¥Ì…Ù½¥‘ÌUQ<…¹U$‘¥Í…É••¥¹œ…‰½ÕĞÑ¡”Í…µ”¡…¹”¸((ŒŒ€Ì¸ÌÑÑ…¬ÁÉ•Ù¥•Ü()½È‘¥É•Ğ…ÑÑ…­ÌÍ¡½Üè()Ñ•áĞ)!¥Ğ€ÜĞ”)…µ…”€ÄËŠLÄÔ)É¥Ğ€À¸Ô”)Q…É•ĞY€ÄÌ)€()…µ…”É…¹”¥ÌÑ¡”¹½Éµ…°¹½¸µÉ¥Ñ¥…°‘•Ñ•Éµ¥¹¥ÍÑ¥ŒÉ…¹”…™Ñ•È­¹½İ¸ÍÑ…Ñ¥Œµ¥Ñ¥…Ñ¥½¸è()Ñ•áĞ(äÀ”Ù…É¥…¹”ƒŠHµ¥Ñ¥…Ñ¥½¸ƒŠH•±•µ•¹ĞµÕ±Ñ¥Á±¥•ÈƒŠHÕ…É‘•)Ñ¡É½Õ (ÄÄÀ”Ù…É¥…¹”ƒŠHµ¥Ñ¥…Ñ¥½¸ƒŠH•±•µ•¹ĞµÕ±Ñ¥Á±¥•ÈƒŠHÕ…É‘•)€()	…ÉÉ¥•È¥ÌÍ¡½İ¸Í•Á…É…Ñ•±äÉ…Ñ¡•ÈÑ¡…¸ÁÉ•Ñ•¹‘¥¹œ¥Ğ¥ÌÁ…ÉĞ½˜…Éµ½Èè()Ñ•áĞ)	…ÉÉ¥•È€ÄÀƒŠH•ÍÑ¥µ…Ñ•!@‘…µ…”€ËŠLÔ)€()É¥ĞÉ…¹”µ…ä‰”Í¡½İ¸½¸‘•Ñ…¥±•Ù¥•Üè()Ñ•áĞ)É¥Ğ€ÄãŠLÈÈ)€()9…ÑÕÉ…°€Ì€¼¹…ÑÕÉ…°€ÄàÉÕ±•ÌµÕÍĞ‰”¥¹±Õ‘•¥¸Ñ¡”‘¥ÍÁ±…å•¡…¹”¸((ŒŒ€Ì¸Ğ½Ù•ÈÁÉ•Ù¥•Ü()½È‘¥É•ĞÉ…¹•…Ñ¥½¹Ìè()Ñ•áĞ)½Ù•È€¬ÈY)€()µÕÍĞ…ÁÁ•…È…Ì„É•…Í½¸±¥¹”¸()á…µÁ±”è()Ñ•áĞ)!¥Ğ€Ôà”)Y€ÄÈ€¬½Ù•È€È€ô€ÄĞ)€()½Í¡…Á•ÌÑ¡…Ğ‘¼¹½ĞÕÍ”½Ù•È¥¸Ñ¡”¥µÁ±•µ•¹Ñ•É•Í½±Ù•ÈÍ¡½Õ±¹½Ğ‘¥ÍÁ±…äÑ¡¥Ìµ½‘¥™¥•È¸((ŒŒ€Ì¸ÔMÁ•±°MÑ…‰¥±¥ÑäÁÉ•Ù¥•Ü()	•™½É”…ÍĞ°Í¡½Ü‘¥ÍÑÉ¥‰ÕÑ¥½¸½Ù•ÈÑ¡”ÍÑ…‰¥±¥ÑäÉ½±°è()Ñ•áĞ)MÑ…‰±”½A•É™•Ğ€äĞ”)U¹ÍÑ…‰±”€Ô”)MÕÉ”€Ä”)€ÄÄ)€()A•É™•Ğµ…ä‰”™½±‘•¥¹Ñ¼MÑ…‰±”¥¸½µÁ…ĞU$…¹ÍÁ±¥Ğ¥¸•Ñ…¥±•Ù¥•Ü¸()•Ñ…¥±•è()Ñ•áĞ)A•É™•Ğ€À¸Ô”)MÑ…‰±”€äÌ¸Ô”)U¹ÍÑ…‰±”€Ô¸Ä”)MÕÉ”€À¸ä”)€()I½Õ¹‘¥ÍÁ±…äÑ¼½¹”‘•¥µ…°İ¡•¸Õ¹‘•È€ÄÀ”°½Ñ¡•Éİ¥Í”İ¡½±”Á•É•¹Ğ¥Ì…•ÁÑ…‰±”¥¸½µÁ…ĞU$¸((ŒŒ€Ì¸ØMÁ•±°‘¥É•Ğµ¡¥ĞÁÉ•Ù¥•Ü()%˜…¸…ÑÑ…¬ÍÁ•±°Á•É™½ÉµÌ„‘¥É•Ğ¡¥Ğ¡•¬°‘¥ÍÁ±…ä‰½Ñ ¡•­Ì‘¥ÍÑ¥¹Ñ±äè()Ñ•áĞ)…ÍĞƒ²V#²‚T€äĞ”)!¥Ğ€ÜĞ”)…µ…”€Ä×ŠLÄä)	ÕÉ¸€ØÌ”)€()¼¹½ĞµÕ±Ñ¥Á±äÑ¡•Í”¥¹Ñ¼½¹”½Á…ÅÕ”ƒŠq½Ù•É…±°ÍÕ•ÍÏŠt¹Õµ‰•È¥¸Ñ¡”‘•™…Õ±ĞU$¸Q¡”Á±…å•ÈÍ¡½Õ±Õ¹‘•ÉÍÑ…¹İ¡…Ğ…¸™…¥°¸((ŒŒ€Ì¸Ü™™•ĞÁÉ•Ù¥•Ü()½È½¹ÑÉ½°½ÍÑ…ÑÕÌ•™™•ÑÌè()Ñ•áĞ)I½½Ğ€Øà”ÙÌ=IP€ÄĞ)ÕÉ…Ñ¥½¸€ÄÑ¥Ù…Ñ¥½¸)€()	½ÍÌ½¹Ù•ÉÍ¥½¸µÕÍĞ‰”ÁÉ•Ù¥•İ•‰•™½É”½µµ¥Ñµ•¹Ğ¸()á…µÁ±”è()Ñ•áĞ)I½½ĞƒŠHM±½Ü€ÈÔ”)	½ÍÌ½¹ÑÉ½°½¹Ù•ÉÍ¥½¸)€()%˜¥µµÕ¹”è()Ñ•áĞ)%55U8¦  ¦æBVffV7B6†æ6R—2æ÷B6†÷vâ2–bF†RVffV7B6÷VÆBÆæBà ¢222ã‚ôRò×VÇF’×F&vWB&Wf–Wp ¥F†R&ö&B&Wf–Wr×W7BVçVÖW&FR7GVÂffV7FVBVæ—G2g&öÒF†R7W'&VçB&W6öÇfW"à ¤6öçFW‡BæVÃ  ¦FW‡@¥F&vWG20¤vö&Æ–â†—Bƒ2R+rN(	3p¤vö&Æ–â"†—BsBR+r>(	3`¤v&v÷–ÆR†—BS‚R+r(	30¦  ¤öâ6ÖÆÂ67&VVç2ÂF—7Æ’F†Rf—'7B2æB´æà ¤&ö&BÖ&¶W'3  ¢ÒF&vWB†W†W2÷WFÆ–æVBà¢ÒV6‚ffV7FVBVæ—BvWG26ÖÆÂF&vWBÖ&¶W"à¢Òg&–VæFÇ’F&vWG2W6RF—7F–æ7B–6öâ÷7G&—RÂæ÷BöæÇ’F–ffW&VçB6öÆ÷"à ¢222ã’g&–VæFÇ’f—&P ¥F†R&Wf–WrVæv–æR7W÷'G2g&–VæFÇ’f—&RWfVâ–bÖç’7W'&VçB7VÆÇ2†fRg&–VæFÇ”f—&SÖfÇ6Và ¤f÷"ç’7F–öâv†÷6RFVf–æ—F–öâW&Ö—G2ÆÇ’FÖvRöVffV7G3  ¦FW‡@¤ÄÅ’„•B^)y£¦  ¦×W7B&R6†÷vâ&Vf÷&R6öÖÖ—Bà ¤–bFÖv–ær7F–öâv–ÆÂffV7BöæR÷"Ö÷&RÆÆ–W2Â&WV—&RW‡Æ–6—B6V6öæB6öæf—&ÖF–öã  ¦FW‡@®ÈºNÙh(i"(	ÎÉXN«[º¨^ÉÛB»(NÉÈNÉyÉèÈ«^¸¸¸ºN(	Ğ®(i"«{¹é¸øBÈ¹ÎÊ@¦  ¤W†6WF–öç3  ¢Ò6VÆbÖ6÷7BW‡Æ–6—FÇ’7FFVB–âF†R6¶–ÆÂFVf–æ—F–öâà¢Ò7F–öç2v†÷6RöæÇ’g&–VæFÇ’VffV7B—2&VæVf–6–Âà ¤UDò&Ææ6VBöÆ–7’×W7BÇ’Æ&vRæVvF—fRg&–VæFÇ’Öf—&R66÷&RVæÆW72âWF†÷&VB6¶–ÆÂöÆ–7’W‡Æ–6—FÇ’W&Ö—G2F†RG&FRà ¢222ãF–ÖVÆ–æR&Wf–Wp ¤&Vf÷&R6öÖÖ—GF–ærâ7F–öâÂ6†÷r¢¦v†÷7BæW‡B×÷6—F–öâ¢¢f÷"F†R7F—fR7F÷"–âF†RF÷F–ÖVÆ–æRà ¤öæÇ’6Æ7VÆFRFWFW&Ö–æ—7F–27F–öâFVÆ’VffV7G2¶æ÷vâ&Vf÷&R$äs  ¢Ò&6RFVÆ¢Ò7VV@¢Ò7W'&VçB6Æ÷rô†7FP¢ÒWF†÷&VBwV&çFVVBF–ÖVÆ–æR6†–gG0 ¤Fò¢¦æ÷B¢¢&WFVæBFò&VF–7B$ärÖFWVæFVçB7FvvW"÷"7W&vRF—7Æ6VÖVçB26W'F–âà ¤6ö×7BFW‡C  ¦FW‡@¤æW‡C¢³0¦  ¢222ã&Wf–WrFFÖöFVÀ ¥&V6öÖÖVæFVBW&RÖöFVÃ  ¦F'@¦6Æ726öÖ&E&Wf–WucB°¢7F–öäFW67&—F÷%cB7F–öã°¢7G&–ær7F÷$–C°¢†W„6ö÷&CòF&vWD†Wƒ°¢Æ—7CÅF&vWE&Wf–WucCâF&vWG3°¢67E&ö&&–Æ—G•cCò67C°¢–çBÖæ6÷7C°¢–çBVffV7F—fTFVÆ“°¢–çB&VF–7FVDæW‡D7F–öåF–ÖS°¢Æ—7CÅ7G&–æsâv&æ–æw3°¢&ööÂ&WV—&W4g&–VæFÇ”f—&T6öæf—&ÖF–öã°§Ğ¦  ¦F&vWE&Wf–WucF  ¦FW‡@§F&vWD–@§&VÆF–öã¢VæV×’òÆÇ’ò6VÆ`¦†—D6†æ6P¦VffV7D6†æ6P¦FÖvTÖ–à¦FÖvTÖ€¦7&—DFÖvTÖ–à¦7&—DFÖvTÖ€¦6÷fW$&öçW0¦FVfVç6UG—P¦FVfVç6UfÇVP§7FGW4æÖP§7FGW4GW&F–öà¦&÷746öçfW'6–öà¦–Ö×VæP¦&'&–W$'6÷&$Ö–äÖ€¦  ¢222ã"6öÖ&B&Wf–Wr66WFæ6RFW7G0 £â&Wf–WrFöW2æ÷B6öç7VÖR$är7FFRà£"âF—&V7B&ævVB&Wf–Wr–æ6ÇVFW26÷fW"³"à£2âæGW&Â2ó‚&R&VfÆV7FVB–â&ö&&–Æ—G’à£Bâ#bÖ÷WF6öÖR†VÇW"ÖF6†W2UDò&ö&&–Æ—G’†VÇW"W†7FÇ’à£Râ&'&–W"6†ævW2…ÖFÖvRW7F–ÖFRv—F†÷WB6†æv–ær&rFÖvRW7F–ÖFRà£bâ&÷72&ö÷B&Wf–Wr&W÷'G26Æ÷r6öçfW'6–öâà£râ–Ö×Væ—G’—2F—7Æ–VB2–Ö×Væ—G’Âæ÷BR6WVFò×&öÆÂà£‚â'W'7CrÆ—7G2W†7FÇ’F†RVæ—G2F†R&W6öÇfW"v÷VÆBffV7Bà£’âg&–VæFÇ’Öf—&R6öæf—&ÖF–öâ—2&WV—&VBöæÇ’f÷"†&ÖgVÂÆÇ’–×7Bà£â&VF–7FVBF–ÖVÆ–æR÷6—F–öâÖF6†W2VffV7F—fTFVÆ•cB‚–à£â6†æv–ærF&vWB–ÖÖVF–FVÇ’WFFW2ÆÂfÇVW2v—F†÷WB7FFR×WFF–öâà ¢ÒÒĞ ¢2BâFWF–ÆVB6öÖ&BÆöp ¢22BãGvòÆ–W'0 ¤¶VWF†RVæv–æRWfVçB7G&VÒÖ6†–æR×&VF&ÆRæB'V–ÆBF†RW6W"öFWfVÆ÷W"ÆöröâF÷öb—Bà ¦FW‡@¤6öÖ&DWfVçEcBÒÆ÷rÖÆWfVÂFWFW&Ö–æ—7F–2Væv–æRWfVç@¤6öÖ&DÆötVçG'•cBÒw&÷WVB‡VÖâ×&VF&ÆRVçG'¤6öÖ&DÆöt7F—fF–öåcBÒöæR7F÷"7F—fF–öâw&÷W ¦  ¤Fòæ÷B&WÆ6R7G'V7GW&VBVæv–æRFFv—F‚&Vf÷&ÖGFVB¶÷&Vâ7G&–æw2à ¢22Bã"7F—fF–öâw&÷W–æp ¤gVÆÂÆör—2w&÷WVB'’7F—fF–öã  ¦FW‡@¥CÓ##R+rv—¦&@¢ÔõdRƒÃ2’(i"ƒ"Ã2’Â6÷7B¢f—&R&öÇB(i"vö&Æ–â66÷W@¢7F&–Æ—G’6Cb³BÃRÃ5Ò³BÓbg2D3+r7F&ÆP¢†—B6Cb³2ÃBÃUÒ³BÓbg2Ud2+r†—@¢FÖvRR(i"&Ö÷"(i"@¢'W&æ–ær6Cbâââ+r7V66W72+r"7F—fF–öç0¢æW‡B7F–öâCÓ3¦  ¥F†—26†÷VÆBÆWBFWfVÆ÷W"&V6öç7G'V7B'Vrv—F†÷WBæVVF–ærFV'VvvW"à ¢22Bã2&WV—&VB7G'V7GW&VBf–VÆG0 ¤V6‚Æ÷rÖÆWfVÂVçG'’6†÷VÆB&R&ÆRFò6''’Âv†Vâ&VÆWfçC  ¦FW‡@¦6öÖ&EF–ÖP¦7F—fF–öä–æFW€¦7F÷$–@¦7F–öä–@§F&vWD–@§F&vWD†W€¦¶–æ@§&öÆÇ0¦æGW&ÅF÷FÀ¦&öçW4'&V¶F÷và¦FVfVç6UG—P¦FVfVç6UfÇVP§&tFÖvP§f&–æ6UW&Ö–ÆÆP¦7&—F–6Ä×VÇF—Æ–W ¦&Ö÷$÷$× §v¶æW75&W6—7Fæ6T×VÇF—Æ–W ¦wV&FVE&VGV7F–öà¦&'&–W$&Vf÷&P¦&'&–W$'6÷&&V@¦‡&Vf÷&P¦‡gFW ¦×&Vf÷&P¦×gFW §7FGW4&Vf÷&TgFW §F–ÖVÆ–æT&Vf÷&TgFW §&æu7FFT&Vf÷&R†FV'VröæÇ’§&æu7FFTgFW"†FV'VröæÇ’¦ÖW76vT¶W¦  ¤Fòæ÷BW‡÷6R$är7FFR–âæ÷&ÖÂÆ–W"T“²&WF–â—B–âFWfVÆ÷W"öW‡÷'BFWF–Âà ¢22BãBÆörFWF–ÂÆWfVÇ0 ¤66W76–&–Æ—G’ò6WGF–æw3  ¢222Ö–æ–ÖÀ ¦FW‡@¥v—¦&B(i"vö&Æ–â+rBÙKÎ»*€¤&öæR†V+r&öæR7vVWÉˆ«: ¤¶VÂ+rÙ¨ÎÙKÀ¦  ¢222æ÷&ÖÂ†FVfVÇB ¦FW‡@¤f—&R&öÇB+r†—Bbg2Ud2+rBÙKÎÙ[B+r'W&æ–æp¦  ¢222FWF–ÆV@ ¥6†÷w2F–6RÂ&öçW6W2ÂÖ—F–vF–öâÂF–ÖVÆ–æR6†ævW2æB6öçfW'6–öâFWF–Ç2à ¥F†R6WGF–ær6†ævW2&W6VçFF–öâöæÇ’Âæ÷BF†RVæFW&Ç––ær7F÷&VBWfVçG2à ¢22BãRT ¤W†—7F–ær&÷GFöÒ6öÖ&BFö7B&VÖ–ç2öæRÖÆ–æRÆFW7BÖWfVçB7W&f6Rà ¥FF†RFö7BöÆör–6öã  ¢Ò÷Vâ&–v‡B×6–FRG&vW"÷"ÖöFÂ6†VWB6—¦VBf÷"ÆæG66Rà¢ÒæWvW7B7F—fF–öâf—6–&ÆRf—'7B–â6ö×7BÖöFRà¢ÒW6W"6âW‡æBâ7F—fF–öâà¢Òf–ÇFW'3¢ÆÂòFÖvRò7FGW2òF–ÖVÆ–æRò7—7FVÒà¢Ò6÷’FV'VrÆöv—2FWfVÆ÷ÖVçBÖ'V–ÆBöæÇ’à ¥F†RÆör×W7Bæ÷B6÷fW"F†RVçF—&RF7F–6Â&ö&B'’FVfVÇBv†–ÆRF†RÆ–W"—26VÆV7F–ærâ7F–öâà ¢22BãbÆör&WFVçF–öà ¤GW&–ær&GFÆS  ¢Ò¶VWgVÆÂ7W'&VçBÖ&GFÆR7G'V7GW&VBÆörà ¤&WGvVVâ&GFÆW3  ¢Òæ÷&ÖÂ&VÆV6R6fRFöW2æ÷BæVVBFòW'6—7BWfW'’6öÖ&B&öÆÂà¢Ò¶VW7VÖÖ'’FVÆVÖWG'’öæÇ’à¢ÒFWfVÆ÷ÖVçB'V–ÆG2Ö’W‡÷'BF†RgVÆÂÆör2¥4ôâà ¤f÷"7&6‚&W÷'Bò&WÆ’ÂF†R&VfW'&VB6¶WB—3  ¦FW‡@¦Væ6÷VçFW$–@§'Vå6VV@¦GFV×@¦–æ—F–Â6''’6æ6†÷@¦–çWBö7F–öâ6WVVæ6P¦Væv–æRWfVçBÆöp¦f–æÂ$är7FFP¦  ¢22Bãr6öÖ&BÆör66WFæ6RFW7G0 £âWfW'’6öÖÖ—GFVB7F–öâ&VÆöæw2FòW†7FÇ’öæR7F—fF–öâw&÷Wà£"âFÖvRÆör–æ6ÇVFW2…&Vf÷&RögFW"æB&'&–W"'6÷'F–öâà£2â7FGW26öçfW'6–öâ—2ÆövvVBW‡Æ–6—FÇ’à£BâÖ÷fVÖVçBæB÷÷'GVæ—G’WfVçG2V"–â6‡&öæöÆöv–6Â÷&FW"à£Râ6ÖR6VVB²6ÖR7F–öç2&öGV6W2'—FRÖWV—fÆVçB7G'V7GW&VBWfVçB6öçFVçBW†6ÇVF–ærvÆÂÖ6Æö6²ÖWFFFà£bâÖ–æ–ÖÂôæ÷&ÖÂôFWF–ÆVB&VæFW"g&öÒF†R6ÖRVæFW&Ç––ærFFà£râ&VÆV6RÆöræWfW"6†÷w2–çFW&æÂ$är7FFRà ¢ÒÒĞ ¢2Râ6fRö–çB6fRò&W7F÷&P ¢22Rã66÷P §cBf—'7B–×ÆVÖVçFF–öâ7W÷'G2¢¦&WGvVVâÖVæ6÷VçFW"ò6fR×ö–çB6fW2¢¢Âæ÷B&&—G&'’Ö–BÖ7F–öâ6öÖ&B6fW2à ¤Ö–BÖ6öÖ&BFW&Ö–æF–öâ&W7F'G2F†RVæ6÷VçFW"g&öÒF†RÆFW7B6†V6·ö–çB7FFRÂ'WB6öç7VÖ&ÆW2Ç&VG’W6VB–âF†BVæf–æ—6†VBGFV×B&VÖ–â6öç7VÖVBà ¥F†—2ÖF6†W2F†RW7F&Æ—6†VBv—R'VÆS  ¦FW‡@¤…ôÕ6†V6·ö–çB7FFR&W7F÷&W0§W6VB6öç7VÖ&ÆW2Fòæ÷@¦æòvöÆBÆ÷70¦  ¢22Rã"6W&FR6†V6·ö–çB7FFRg&öÒGW&&ÆR'Vâ7FFP ¥F†—2F—7F–æ7F–öâ—2&WV—&VBFò&WfVçB÷F–öâ×&VgVæBW‡Æö—G2à ¢2226†V6·ö–çB6æ6†÷@ ¥&W7F÷&VBöâv—R÷&VÆVæ6ƒ  ¦FW‡@¦6†V6·ö–çD–@¦7W'&VçDVæ6÷VçFW$–@§'G’… §'G’Õ §7F'B&'&–W"òWF†÷&VB6†V6·ö–çB'Vfg0§'G’&÷7FW §÷6—F–öâ–â&÷WFP¦  ¢222GW&&ÆR'Vâ7FFP ¤æ÷B&öÆÆVB&6²öâv—S  ¦FW‡@§6fU&Wf—6–öà§'Vå6VV@¦GFV×B6÷Vç@¦vöÆ@¦W76Væ6P¤…÷F–öâ6÷Vç@¦6öç7VÖVBGW&&ÆR—FV×0¦6ö×ÆWFVBVæ6÷VçFW"”G0¦6Æ–ÖVB&Wv&B”G0§&V7'V—FVB6ö×æ–öâfÆw0¦÷F–öæÂ×&÷WFRfÆw0¤æ6–VçBfö7W2fÆr–bV&æV@§7F÷'’÷'VâfÆw0¦  ¤öâFVfVC  ¦FW‡@§&W7F÷&R6†V6·ö–çB'G’6æ6†÷@¤´TU7W'&VçBGW&&ÆR÷F–öâ6÷Vç@¤´TU6öÖÖ—GFVB&Wv&G2öfÆw0¦–æ7&VÖVçBGFV×@¦  ¢22Rã26fRG&–vvW'0 ¥w&—FR6fR–ÖÖVF–FVÇ’gFW"F†W6RWfVçG3  £âæWr'Vâ7&VF–öâà£"âVæ6÷VçFW"f–7F÷'’æB&Wv&B6öÖÖ—Bà£2âVçFW&–ærâW‡Æ–6—B6fRö–çBà£Bâ6†ö÷6–ær#B÷F–öæÂg2#RF—&V7B&÷WFRà£Râ6öç7VÖ–ærâ…÷F–öâ÷"æ÷F†W"GW&&ÆR6öç7VÖ&ÆRà£bâö'F–æ–æræ6–VçBfö7W2÷"æ÷F†W"W'6—7FVçB'Vâ&Wv&Bà£râFVfVB÷v—RG&ç6—F–öâà£‚âÆ–fV7–6ÆRW6R–bF—'G’7FFRW†—7G2à ¤…ôÕFÖvRGW&–ærf–v‡BFöW2æ÷BæVVBFò&Rw&—GFVâ6öçF–çV÷W6Ç’–âcBâF†RVæ6÷VçFW"&W7F'G2gFW"FW&Ö–æF–öâà ¢22RãB&Wv&B–FV×÷FVæ7 ¤æWfW"v&BF†R6ÖRVæ6÷VçFW"Gv–6R&V6W6Röb7&6‚&WGvVVâf–7F÷'’67&VVâæBG&ç6—F–öâà ¥W6R”G3  ¦FW‡@¦6ö×ÆWFVDVæ6÷VçFW$–G0¦6Æ–ÖVE&Wv&D–G0¦  ¥f–7F÷'’G&ç67F–öâ6öæ6WGVÆÇ“  ¦FW‡@¦–b&Wv&D–Bæ÷B6Æ–ÖVC ¢FBvöÆBôW76Væ6Rö—FVÒöfÆp¢FB&Wv&D–BFò6Æ–ÖVE&Wv&D–G0¦Ö&²Væ6÷VçFW"6ö×ÆWFV@§w&—FRGW&&ÆR6fP§F†Vâ6†÷röÆVfRf–7F÷'’67&VVà¦  ¤–bF†RF–W2gFW"F†Rw&—FRÂ&VÆöB6VW2F†R6Æ–ÖVB”BæBFöW2æ÷BGWÆ–6FRF†R&Wv&Bà ¢22RãR6fR66†VÖc ¥&V6öÖÖVæFVB¥4ôâ6†S  ¦§6öà§°¢'66†VÖfW'6–öâ#¢À¢'6fU&Wf—6–öâ#¢rÀ¢''Vä–B#¢'WV–BÖ÷"×7F&ÆR×'VâÖ–B"À¢''Vå6VVB#¢#3“##bÀ¢&GFV×B#¢"À¢'&÷WFR#¢°¢&7W'&VçDVæ6÷VçFW$–B#¢%e5ô#Uô$ôäUô„T"À¢&6†V6·ö–çD–B#¢$%$ô´Tåô$4„•dUôåDT4„Ô$U""À¢&6ö×ÆWFVDVæ6÷VçFW$–G2#¢²%e5ô#ôtô$Ä”åôÔ%U4‚"Â%e5ô#%õ%T”åô4õU%E”$B"Â%e5ô#5ô$4„•dUô„ÄÂ%ÒÀ¢&6Æ–ÖVE&Wv&D–G2#¢²'&Wv&Bä#"Â'&Wv&Bä#""Â'&Wv&Bä#2%ÒÀ¢'Föö´÷F–öæÄ#B#¢fÇ6P¢ÒÀ¢'&W6÷W&6W2#¢°¢&vöÆB#¢s3BÀ¢&W76Væ6R#¢3"À¢&‡÷F–öç2#¢¢ÒÀ¢&6†V6·ö–çE'G’#¢°¢'v—¦&B#¢²&‡#¢cÂ&×#¢Â'7F'D&'&–W"#¢ÒÀ¢&¶VÂ#¢²&‡#¢"Â&×#¢Â'7F'D&'&–W"#¢ÒÀ¢&æW&#¢²&‡#¢s"Â&×#¢Â'7F'D&'&–W"#¢Ğ¢ÒÀ¢&fÆw2#¢°¢&æW&&V7'V—FVB#¢G'VRÀ¢&æ6–VçDfö7W2#¢fÇ6P¢Ğ§Ğ¦  ¤Fòæ÷B6W&–Æ—¦RG&ç6–VçB7FGW2VffV7G2g&öÒf–æ—6†VB&GFÆRVæÆW72gWGW&RWF†÷&VBÖV6†æ–2W‡Æ–6—FÇ’6'&–W2F†VÒ&WGvVVâ&GFÆW2à ¢22Rãb7F÷&vR–×ÆVÖVçFF–öà ¥F†R&W÷6—F÷'’Ç&VG’FWVæG2öâ6†&VE÷&VfW&Væ6W6Â6òcB6â&Vv–âv—F‚fW'6–öæVB¥4ôâ7G&–ær&W÷6—F÷'’v—F†÷WB–çG&öGV6–æræWrFF&6RFWVæFVæ7’à ¥&V6öÖÖVæFVB¶W—3  ¦FW‡@§7W&vU÷v—¦&E÷cE÷6fU÷&–Ö'§7W&vU÷v—¦&E÷cE÷6fUö&6·W ¦  ¥w&—FR7G&FVw“  ¦FW‡@£âVæ6öFRæWr¥4ôâv—F‚6fU&Wf—6–öâ³£"â6÷’7W'&VçFÇ’fÆ–B&–Ö'’Fò&6·W £2âw&—FRæWr&–Ö'£Bâ&VBÖ&6²FV6öFR÷fÆ–FFP£RâÖ&²6fR6ÆVâ–âÖVÖ÷'¦  ¤öâÆöC  ¦FW‡@§G'’&–Ö'®(i"66†VÖfÆ–FF–öà®(i"–b–çfÆ–BÂG'’&6·W ®(i"–b&÷F‚–çfÆ–BÂ&W÷'B&V6÷fW&&ÆR6fRW'&÷"æBöffW"æWr'Và¦  ¤Fòæ÷B6–ÆVçFÇ’7&VFRæWr'Vâ÷fW"6÷''WFVB6fRà ¢22Rãr66†VÖÖ–w&F–öà ¤7&VFS  ¦FW‡@¥'Vå6fUc@¥'Vå6fT6öFV5c@¥'Vå6fU&W÷6—F÷'•c@¥'Vå6fTÖ–w&F–öåc@¦  ¥'VÆW3  ¢Ò66†VÖfW'6–öâÓÒ7W'&VçF¢FV6öFRæ÷&ÖÆÇ’à¢ÒöÆFW"¶æ÷vâfW'6–öã¢Ö–w&FR7FWÖ'’×7FWà¢ÒæWvW"Væ¶æ÷vâfW'6–öã¢&VgW6RFW7G'V7F—fRÆöC²FVÆÂW6W"F†R6fRv27&VFVB'’æWvW"vÖRfW'6–öâà¢ÒÖ–w&F–öâ×W7BæWfW"&VGV6R÷F–öâ6÷VçB÷"GWÆ–6FR&Wv&G2à ¢22Rã‚6öÖ&B&W7F'B6VV@ ¤&WG'’×W7Bæ÷B66–FVçFÆÇ’&V6öÖRFWFW&Ö–æ—7F–2–FVçF–6Â67&—B–bF†RW6W"6†ævW2æ÷F†–ærÂVæÆW72F†B—2–çFVçF–öæÆÇ’FW6—&VBf÷"FV'Vvv–ærà ¥W6S  ¦FW‡@¦Væ6÷VçFW%6VVBÒ†6‚‡'Vå6VVBÂVæ6÷VçFW$–BÂGFV×B¦  ¥F†R7W'&VçB&÷F÷G—Rf÷&×VÆÖ’&VÖ–âFV×÷&&–Ç’Â'WB&öGV7F–öâ6†÷VÆB6VçG&Æ—¦R—B–âöæRFWFW&Ö–æ—7F–26VVBgVæ7F–öâà ¤f÷"&WÆ“  ¦FW‡@§'Vå6VVB²GFV×B²7F–öâ6WVVæ6P¦  ¦—2Væ÷Vv‚Fò&V6öç7G'V7B6öÖ&B$ärà ¢22Rã’6fRö–çBT ¤B6fRö–çB6†÷r6†÷'B6öæf—&ÖF–öâÂæ÷B&Æö6¶–ær6fRÖÖævVÖVçB67&VVã  ¦FW‡@®ÉXÊBÊxÊ	 ¥…Ù¨Î»;@®ºxº
RËYÎÈhÂ £²¶Z$ƒ²‚²z—®B )€()ÕÑ½Í…Ù”¥½¸½Ñ•áĞµ…ä…ÁÁ•…È‰É¥•™±ä¸()¼¹½ĞÉ•ÅÕ¥É”µ…¹Õ…°Í…Ù”Í±½ÑÌ™½ÈÑ¡”Y•ÉÑ¥…°M±¥”¸((ŒŒ€Ô¸ÄÀM…Ù”½I•ÍÑ½É”…•ÁÑ…¹”Ñ•ÍÑÌ((Ä¸)M=8É½Õ¹‘ÑÉ¥ÀÁÉ½‘Õ•Ì•ÅÕ¥Ù…±•¹ĞÉÕ¸ÍÑ…Ñ”¸(È¸½ÉÉÕÁÑ•ÁÉ¥µ…Éä±½…‘ÌÙ…±¥‰…­ÕÀ¸(Ì¸‰½Ñ ¥¹Ù…±¥‘¼¹½ĞÍ¥±•¹Ñ±ä½Ù•ÉİÉ¥Ñ”¸(Ğ¸Á½Ñ¥½¸ÕÍ•¥¸„™…¥±••¹½Õ¹Ñ•ÈÉ•µ…¥¹Ì½¹ÍÕµ•…™Ñ•ÈÉ•ÍÑ½É”¸(Ô¸!@½5@É•ÍÑ½É”Ñ¼¡•­Á½¥¹ĞÙ…±Õ•Ì…™Ñ•È‘•™•…Ğ¸(Ø¸½±¥Ì¹½Ğ±½ÍĞ½¸İ¥Á”¸(Ü¸É•İ…É…¹¹½Ğ‰”±…¥µ•Ñİ¥”…™Ñ•ÈÉ•±…Õ¹ ¸(à¸ÀÌ¡•­Á½¥¹Ğ½ÉÉ•Ñ±äÍÑ½É•ÌÕ±°!@€¼]¥é…É5@™±½½È€¼	…ÉÉ¥•È€ÄÀ¸(ä¸ÀĞ¹¥•¹Ğ½ÕÌ½ÉÉ•Ñ±äÍÕÉÙ¥Ù•ÌÑ¼ÀÔÍÑ…ÉĞ¸(ÄÀ¸½ÁÑ¥½¹…°É½ÕÑ”¡½¥”ÍÕÉÙ¥Ù•Ì…ÁÀÉ•ÍÑ…ÉĞ¸(ÄÄ¸…ÑÑ•µÁĞ¥¹É•µ•¹ÑÌ…¹¡…¹•Ì‘•É¥Ù••¹½Õ¹Ñ•ÈÍ••¸(ÄÈ¸Õ¹­¹½İ¸¹•İ•ÈÍ¡•µ„¥ÌÉ•©•Ñ•Í…™•±ä¸(ÄÌ¸ØÄµ¥É…Ñ¥½¸Ñ•ÍĞ™¥áÑÕÉ”É•µ…¥¹Ì¥¸É•Á½Í¥Ñ½ÉäÁ•Éµ…¹•¹Ñ±ä¸((´´´((Œ€Ø¸MÕ•ÍÑ•™¥±”ÍÁ±¥Ğ™½È¥µÁ±•µ•¹Ñ…Ñ¥½¸()-••ÀÑ¡”•á¥ÍÑ¥¹œøÌÀÀµ±¥¹”ÍÁ±¥ĞÉÕ±”¸()Ñ•áĞ)±¥ˆ½½É”½Á…Ñ¡™¥¹‘•É}ØĞ¹‘…ÉĞ)±¥ˆ½½É”½½µ‰…Ñ}ÁÉ½‰…‰¥±¥Ñå}ØĞ¹‘…ÉĞ)±¥ˆ½½É”½½µ‰…Ñ}ÁÉ•Ù¥•İ}ØĞ¹‘…ÉĞ)±¥ˆ½½É”½½µ‰…Ñ}±½}ØĞ¹‘…ÉĞ)±¥ˆ½½É”½½µ‰…Ñ}±½}™½Éµ…ÑÑ•É}ØĞ¹‘…ÉĞ)±¥ˆ½½É”½ÉÕ¹}Í…Ù•}ØĞ¹‘…ÉĞ)±¥ˆ½½É”½ÉÕ¹}Í…Ù•}½‘•}ØĞ¹‘…ÉĞ)±¥ˆ½½É”½ÉÕ¹}Í…Ù•}É•Á½Í¥Ñ½Éå}ØĞ¹‘…ÉĞ)±¥ˆ½½É”½ÉÕ¹}Í…Ù•}µ¥É…Ñ¥½¹}ØĞ¹‘…ÉĞ()±¥ˆ½ÍÉ••¹Ì½‰…ÑÑ±•}ÁÉ•Ù¥•İ}Á…Ñ¡}ØĞ¹‘…ÉĞ)±¥ˆ½ÍÉ••¹Ì½‰…ÑÑ±•}ÁÉ•Ù¥•İ}ÁÉ•‘¥Ñ¥½¹}ØĞ¹‘…ÉĞ()±¥ˆ½İ¥‘•ÑÌ½Á…Ñ¡}ÁÉ•Ù¥•İ}ØĞ¹‘…ÉĞ)±¥ˆ½İ¥‘•ÑÌ½½µ‰…Ñ}ÁÉ•‘¥Ñ¥½¹}Á…¹•±}ØĞ¹‘…ÉĞ)±¥ˆ½İ¥‘•ÑÌ½½µ‰…Ñ}±½}Á…¹•±}ØĞ¹‘…ÉĞ)±¥ˆ½İ¥‘•ÑÌ½…ÕÑ½Í…Ù•}¥¹‘¥…Ñ½É}ØĞ¹‘…ÉĞ()Ñ•ÍĞ½Á…Ñ¡™¥¹‘•É}ØÑ}Ñ•ÍĞ¹‘…ÉĞ)Ñ•ÍĞ½½µ‰…Ñ}ÁÉ½‰…‰¥±¥Ñå}ØÑ}Ñ•ÍĞ¹‘…ÉĞ)Ñ•ÍĞ½½µ‰…Ñ}ÁÉ•Ù¥•İ}ØÑ}Ñ•ÍĞ¹‘…ÉĞ)Ñ•ÍĞ½½µ‰…Ñ}±½}ØÑ}Ñ•ÍĞ¹‘…ÉĞ)Ñ•ÍĞ½ÉÕ¹}Í…Ù•}½‘•}ØÑ}Ñ•ÍĞ¹‘…ÉĞ)Ñ•ÍĞ½ÉÕ¹}Í…Ù•}É•Á½Í¥Ñ½Éå}ØÑ}Ñ•ÍĞ¹‘…ÉĞ)Ñ•ÍĞ½ÉÕ¹}Í…Ù•}µ¥É…Ñ¥½¹}ØÑ}Ñ•ÍĞ¹‘…ÉĞ)€()¼¹½Ğ‘ÕÁ±¥…Ñ”€ÍØÁÉ½‰…‰¥±¥Ñä½‘”¥¸Ñ¡”UQ<Á±…¹¹•È…™Ñ•È½µ‰…Ñ}ÁÉ½‰…‰¥±¥Ñå}ØĞ¹‘…ÉÑ€•á¥ÍÑÌ¸I•™…Ñ½ÈUQ<Ñ¼ÕÍ”Ñ¡”Í¡…É•¡•±Á•È¸((´´´((Œ€Ü¸%µÁ±•µ•¹Ñ…Ñ¥½¸½É‘•È()I•½µµ•¹‘•½É‘•ÈÑ¼µ¥¹¥µ¥é”É•İ½É¬è()Ñ•áĞ(Ä¸‘•Ñ•Éµ¥¹¥ÍÑ¥ŒÁ…Ñ¡™¥¹‘•È€¬Ñ•ÍÑÌ(È¸Í¡…É•€ÍØÁÉ½‰…‰¥±¥Ñä¡•±Á•È(Ì¸ÁÕÉ”½µ‰…ÑAÉ•Ù¥•İXĞµ½‘•°(Ğ¸A…Ñ AÉ•Ù¥•ÜU$(Ô¸½µ‰…ĞAÉ•‘¥Ñ¥½¸U$(Ø¸ÍÑÉÕÑÕÉ•½µ‰…Ğ1½œ(Ü¸1½œÁ…¹•°€¼‘•Ñ…¥°±•Ù•±Ì(à¸IÕ¹M…Ù”Í¡•µ„€¬½‘•Œ(ä¸É•Á½Í¥Ñ½ÉäÁÉ¥µ…Éä½‰…­ÕÀ‰•¡…Ù¥½È(ÄÀ¸Y•ÉÑ¥…°M±¥”¡½ÍĞ¥¹Ñ•É…Ñ¥½¸(ÄÄ¸±½…°™±ÕÑÑ•È…¹…±åé”½Ñ•ÍĞ(ÄÈ¸…ÉĞ¡•…‘±•ÍÌ‰…Í•±¥¹”(ÄÌ¸É•…°µ‘•Ù¥”±…å½ÕĞ½Ñ½Õ E)€()Q¡”Í…Ù”±…å•ÈÍ¡½Õ±¹½Ğ‰”İÉ¥ÑÑ•¸™¥ÉÍĞ‰•…ÕÍ”Ñ¡”½µ‰…Ğ½ÉÕ¸µ½‘•°¥ÌÍÑ¥±°‰•¥¹œ¥Ù•¸Ñ¡”™¥¹…°ÁÉ•Ù¥•Ü½±½œ¥¹Ñ•É™…•Ì¥¸Ñ¡¥ÌÁ…ÍÌ¸((´´´((Œ€à¸•™¥¹¥Ñ¥½¸½˜½¹”™½ÈØÌ¸Ø¥µÁ±•µ•¹Ñ…Ñ¥½¸()ØÌ¸Ø¥µÁ±•µ•¹Ñ…Ñ¥½¸¥Ì¹½ĞƒŠq‘½¹—Štµ•É•±ä‰•…ÕÍ”İ¥‘•ÑÌÉ•¹‘•È¸()%Ğ¥Ì‘½¹”İ¡•¸…±°½˜Ñ¡”™½±±½İ¥¹œ…É”ÑÉÕ”è((´5½Ù”‘•ÍÑ¥¹…Ñ¥½¸¥ÌÁÉ•Ù¥•İ•‰•™½É”½µµ¥Ğ¸(´‘¥ÍÁ±…å•Á…Ñ ¥Ì•¹¥¹”µ…ÕÑ¡½É¥Ñ…Ñ¥Ù”¸(´½ÁÁ½ÉÑÕ¹¥ÑäÉ¥Í¬¥ÌÁ•Èµ•‘”…¹Ù¥Í¥‰±”İ¥Ñ¡½ÕĞÉ•±å¥¹œ½¸½±½È…±½¹”¸(´…Ñ¥½¸ÁÉ•Ù¥•Ü½¹ÍÕµ•Ìé•É¼I9½ÍÑ…Ñ”¸(´!¥Ğ½™™•Ğ½MÑ…‰¥±¥Ñä¡…¹•ÌÕÍ”Ñ¡”Í…µ”€ÈÄØµ½ÕÑ½µ”¡•±Á•È…ÌUQ<¸(´½Ñ…É•Ğ±¥ÍĞµ…Ñ¡•ÌÑ¡”…ÑÕ…°É•Í½±Ù•È¸(´¡…Éµ™Õ°™É¥•¹‘±ä™¥É”É••¥Ù•Ì•áÁ±¥¥Ğİ…É¹¥¹œ½½¹™¥Éµ…Ñ¥½¸¸(´Ñ¥µ•±¥¹”¡½ÍĞÕÍ•ÌÑ¡”Í…µ”‘•±…ä™Õ¹Ñ¥½¸…ÌÑ¡”•¹¥¹”¸(´ÍÑÉÕÑÕÉ•½µ‰…Ğ±½œ…¸•áÁ±…¥¸•Ù•Éä‘…µ…”½ÍÑ…ÑÕÌÉ•ÍÕ±Ğ¸(´±½œÁÉ•Í•¹Ñ…Ñ¥½¸ÍÕÁÁ½ÉÑÌ5¥¹¥µ…°½9½Éµ…°½•Ñ…¥±•İ¥Ñ¡½ÕĞ¡…¹¥¹œÉ…Ü‘…Ñ„¸(´M…™”A½¥¹ĞÍ…Ù”Á•ÉÍ¥ÍÑÌ…É½ÍÌ…ÁÀÉ•ÍÑ…ÉĞ¸(´½¹ÍÕµ…‰±•Ì…É”¹½ĞÉ•™Õ¹‘•‰äİ¥Á”½™½É”µ±½Í”¸(´É•İ…É‘Ì…É”¥‘•µÁ½Ñ•¹Ğ¸(´½ÉÉÕÁÑ•ÁÉ¥µ…ÉäÍ…Ù”…¸É•½Ù•È™É½´‰…­ÕÀ¸(´±ÕÑÑ•È½…ÉĞ…¹…±åé”½Ñ•ÍĞ…É”…ÑÕ…±±äÉÕ¸±½…±±ä…¹Ñ¡•¥È½ÕÑÁÕÑÌ…É”½µµ¥ÑÑ•…ÌÙ…±¥‘…Ñ¥½¸•Ù¥‘•¹”¸((´´´((Œ€ä¸9•áĞÍÁ•¥™¥…Ñ¥½¸…™Ñ•ÈØÌ¸Ø()=¹”Ñ¡•Í”¥¹Ñ•É™…•Ì…É”™¥á•°Ñ¡”¹•áĞ‘•Í¥¸½¥µÁ±•µ•¹Ñ…Ñ¥½¸µÍÁ•ŒÁ…ÍÌÍ¡½Õ±™½ÕÌ½¸è()Ñ•áĞ)¸É•…°•ÅÕ¥Áµ•¹Ğ½ÍÑ…ĞÁ¥Á•±¥¹”¥¹Ñ¼½µ‰…ÑU¹¥ÑXĞ)¸ÁÉ•Á…É•µÍÁ•±°±½…‘½ÕĞ…¹ÍÁ•±±‰½½¬U$)¸•¹•µä$…É¡•ÑåÁ”Á½±¥ä‰•å½¹Ñ¡”Y•ÉÑ¥…°M±¥”™¥áÑÕÉ•Ì)¸•¹½Õ¹Ñ•ÈÉ•İ…É€¼±½½Ğ€¼•ÍÍ•¹”ÁÉ½É•ÍÍ¥½¸¥¹Ñ•É…Ñ¥½¸)¸İ½É±µµ…ÀƒŠH•¹½Õ¹Ñ•ÈƒŠHÉ•İ…ÉƒŠH¡ÕˆÍÑ…Ñ”µµ…¡¥¹”Á•ÉÍ¥ÍÑ•¹”)€()¼¹½Ğ©ÕµÀÑ¼‰É½……µÁ…¥¸¥µÁ±•µ•¹Ñ…Ñ¥½¸Õ¹Ñ¥°ØÌ¸Ø±½…°±ÕÑÑ•ÈÙ…±¥‘…Ñ¥½¸¥Ì½µÁ±•Ñ”•¹½Õ Ñ¼ÁÉ½Ù”Ñ¡”½É”½µ‰…ĞU`¥ÌÍÑ…‰±”¸(