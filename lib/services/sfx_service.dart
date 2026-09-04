import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 효과음 + 진동 담당 (GAME_DESIGN 6절 손맛 표).
/// 소리·진동이 실패해도 게임은 계속돼야 하므로 전부 조용히 삼킨다.
class SfxService {
  SfxService._();

  static final SfxService instance = SfxService._();

  final Map<String, AudioPlayer> _players = {};

  /// `assets/sfx/<이름>.wav` 재생 (같은 소리는 플레이어를 재사용)
  Future<void> play(String name) async {
    try {
      final p = _players.putIfAbsent(
          name, () => AudioPlayer()..setReleaseMode(ReleaseMode.stop));
      await p.stop();
      await p.play(AssetSource('sfx/$name.wav'));
    } catch (e) {
      debugPrint('효과음 재생 실패($name): $e');
    }
  }

  void _haptic(Future<void> Function() f) {
    try {
      f();
    } catch (e) {
      debugPrint('진동 실패: $e');
    }
  }

  /// 주사위 굴림: 중간 진동 + 굴림 소리
  void diceRoll() {
    _haptic(HapticFeedback.mediumImpact);
    play('dice');
  }

  /// 잠금: 딸깍 (가벼운 진동 + 클릭음)
  void lockClick() {
    _haptic(HapticFeedback.selectionClick);
    play('click');
  }

  /// 대성공: 강한 진동 + 팡파르
  void crit() {
    _haptic(HapticFeedback.heavyImpact);
    play('crit');
  }

  /// 일반 타격
  void hit() {
    _haptic(HapticFeedback.lightImpact);
    play('hit');
  }

  /// 폭주: 짧은 진동 2회 + 하강음
  void surge() {
    _haptic(HapticFeedback.mediumImpact);
    Future<void>.delayed(const Duration(milliseconds: 120),
        () => _haptic(HapticFeedback.mediumImpact));
    play('surge');
  }
}
