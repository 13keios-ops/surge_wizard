import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meta_state.dart';

/// 로컬 저장 담당 (shared_preferences).
/// 서버 통신 없음 — 전부 기기 안에만 저장된다.
class SaveService {
  static const _metaKey = 'meta_state_v1';

  /// 영구 강화 상태를 불러온다. 저장된 게 없거나 깨졌으면 초기 상태.
  Future<MetaState> loadMeta() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_metaKey);
    if (raw == null) return MetaState.initial();
    try {
      return MetaState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return MetaState.initial();
    }
  }

  /// 영구 강화 상태를 저장한다.
  Future<void> saveMeta(MetaState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_metaKey, jsonEncode(state.toJson()));
  }
}
