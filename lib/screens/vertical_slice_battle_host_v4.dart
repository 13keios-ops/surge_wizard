import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/dungeon_run_state_v4.dart';
import '../core/encounter_data_v4.dart';
import '../core/encounter_loader_v4.dart';
import '../core/vertical_slice_catalog_v4.dart';
import 'battle_preview_controller_v4.dart';
import 'battle_screen_v4.dart';

class VerticalSliceBattleHostV4 extends StatefulWidget {
  const VerticalSliceBattleHostV4({super.key});
  @override
  State<VerticalSliceBattleHostV4> createState() => _VerticalSliceBattleHostV4State();
}

class _VerticalSliceBattleHostV4State extends State<VerticalSliceBattleHostV4> {
  List<EncounterDefinitionV4>? encounters;
  BattlePreviewControllerV4? controller;
  DungeonCarryStateV4? carry;
  int currentIndex = 0;
  int attempt = 0;
  int gold = 520;
  int essence = 20;
  bool rewardClaimed = false;
  bool tookOptionalB04 = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final source = await rootBundle.loadString('assets/data/v4_vertical_slice_encounters.json');
    final loaded = const EncounterLoaderV4().decode(source);
    final initialParty = VerticalSliceCatalogV4.partyFor(loaded.first.partyIds);
    if (!mounted) return;
    setState(() {
      encounters = loaded;
      carry = DungeonCarryStateV4.fromParty(initialParty, hpPotions: 2);
      _replaceController(0);
    });
  }

  void _replaceController(int index) {
    controller?.dispose();
    currentIndex = index;
    rewardClaimed = false;
    final c = carry!;
    controller = BattlePreviewControllerV4(
      encounter: encounters![index],
      seed: 23092026 + attempt * 1009 + index * 100003,
      carry: c.copy(),
      hpPotions: c.hpPotions,
    );
  }

  void _claimVictory() {
    if (rewardClaimed) return;
    final battle = controller!;
    carry!.captureAfterVictory(battle.partyCombatUnits);
    carry!.hpPotions = battle.hpPotions;
    gold += battle.encounter.gold;
    essence += battle.encounter.essence;

    if (battle.encounter.id == 'VS_B03_ARCHIVE_HALL') {
      carry!.applyBossAntechamberCheckpoint(
        battle.partyCombatUnits,
        wizardMpFloor: 100,
        startBarrier: 10,
      );
    }
    if (battle.encounter.id == 'VS_B04_OPTIONAL_SEAL_ROOM') {
      carry!.applyAncientFocusReward(
        battle.partyCombatUnits,
        wizardMpBonus: 40,
        partyBarrier: 25,
      );
      tookOptionalB04 = true;
    }
    rewardClaimed = true;
  }

  void _continueTo(int index) {
    _claimVictory();
    setState(() => _replaceController(index));
  }

  void _retryDefeat() {
    final battle = controller!;
    carry!.hpPotions = battle.hpPotions;
    attempt++;
    setState(() => _replaceController(currentIndex));
  }

  void _restartRun() {
    final initial = VerticalSliceCatalogV4.partyFor(encounters!.first.partyIds);
    controller?.dispose();
    setState(() {
      gold = 520;
      essence = 20;
      attempt = 0;
      tookOptionalB04 = false;
      carry = DungeonCarryStateV4.fromParty(initial, hpPotions: 2);
      _replaceController(0);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = encounters;
    final battle = controller;
    if (items == null || battle == null || carry == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF17191D),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(children: [
      BattleScreenV4(controller: battle),
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 66, top: 6),
          child: _RunHud(
            label: _progressLabel(battle.encounter.id),
            gold: gold,
            essence: essence,
            potions: battle.hpPotions,
          ),
        ),
      ),
      AnimatedBuilder(
        animation: battle,
        builder: (context, _) {
          if (!battle.isBattleOver) return const SizedBox.shrink();
          if (!battle.didWin) {
            return _ResultOverlay(
              title: 'DEFEAT',
              subtitle: 'Safe Point · Potion 사용량 유지',
              primaryLabel: 'RETRY',
              onPrimary: _retryDefeat,
            );
          }

          final id = battle.encounter.id;
          if (id == 'VS_B03_ARCHIVE_HALL') {
            return _ResultOverlay(
              title: 'ARCHIVE CLEARED',
              subtitle: 'Boss Antechamber Safe Point',
              primaryLabel: 'B05 BOSS',
              onPrimary: () => _continueTo(4),
              secondaryLabel: 'B04 OPTIONAL',
              onSecondary: () => _continueTo(3),
            );
          }
          if (id == 'VS_B05_BONE_HEAP') {
            final finalGold = gold + (rewardClaimed ? 0 : battle.encounter.gold);
            final finalEssence =
                essence + (rewardClaimed ? 0 : battle.encounter.essence);
            return _ResultOverlay(
              title: 'VERTICAL SLICE CLEAR',
              subtitle: 'Gold $finalGold · Essence $finalEssence · Potion ${battle.hpPotions}'
                  '${tookOptionalB04 ? ' · Ancient Focus' : ''}',
              primaryLabel: 'NEW RUN',
              onPrimary: () {
                _claimVictory();
                _restartRun();
              },
            );
          }

          final next = id == 'VS_B01_GOBLIN_AMBUSH'
              ? 1
              : id == 'VS_B02_RUIN_COURTYARD'
                  ? 2
                  : 4;
          return _ResultOverlay(
            title: 'VICTORY',
            subtitle: '+${battle.encounter.gold} Gold · +${battle.encounter.essence} Essence',
            primaryLabel: 'NEXT',
            onPrimary: () => _continueTo(next),
          );
        },
      ),
    ]);
  }

  String _progressLabel(String id) => switch (id) {
        'VS_B01_GOBLIN_AMBUSH' => 'B01 · 1/5',
        'VS_B02_RUIN_COURTYARD' => 'B02 · 2/5',
        'VS_B03_ARCHIVE_HALL' => 'B03 · 3/5',
        'VS_B04_OPTIONAL_SEAL_ROOM' => 'B04 · OPTIONAL',
        'VS_B05_BONE_HEAP' => 'B05 · BOSS',
        _ => id,
      };
}

class _RunHud extends StatelessWidget {
  const _RunHud({required this.label, required this.gold, required this.essence, required this.potions});
  final String label;
  final int gold;
  final int essence;
  final int potions;
  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xE020222A),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Text('$label   G $gold · E $essence · P $potions',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      );
}

class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });
  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: ColoredBox(
          color: const Color(0x99101218),
          child: Center(
            child: Material(
              color: const Color(0xFF252833),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(subtitle),
                  const SizedBox(height: 14),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    if (secondaryLabel != null) ...[
                      OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
                      const SizedBox(width: 10),
                    ],
                    FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
                  ]),
                ]),
              ),
            ),
          ),
        ),
      );
}
