import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/player_progress.dart';

final localPlayerProgressStorageProvider = Provider<LocalPlayerProgressStorage>(
  (ref) => const LocalPlayerProgressStorage(),
);

class LocalPlayerProgressStorage {
  const LocalPlayerProgressStorage();

  static const _progressKey = 'player.progress.v1';

  Future<PlayerProgress> load({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final rawProgress = prefs.getString(_progressKey);
    if (rawProgress == null || rawProgress.isEmpty) {
      return PlayerProgress.empty();
    }

    try {
      final decoded = jsonDecode(rawProgress);
      if (decoded is! Map<String, dynamic>) {
        return PlayerProgress.empty();
      }

      final progress = PlayerProgress.fromJson(
        decoded,
      ).normalizeForToday(now ?? DateTime.now());
      if (progress.offensiveCount !=
          PlayerProgress.fromJson(decoded).offensiveCount) {
        await save(progress);
      }

      return progress;
    } on Object {
      return PlayerProgress.empty();
    }
  }

  Future<void> save(PlayerProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
  }
}
