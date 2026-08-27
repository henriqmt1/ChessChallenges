import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/viewmodels/campaign_progress_state.dart';

final localCampaignProgressStorageProvider =
    Provider<LocalCampaignProgressStorage>(
      (ref) => const LocalCampaignProgressStorage(),
    );

class LocalCampaignProgressStorage {
  const LocalCampaignProgressStorage();

  static const _completedLevelsKey = 'campaign.completedLevels';
  static const _offensiveCountKey = 'campaign.offensiveCount';
  static const _lastActivityDateKey = 'campaign.lastActivityDate';

  Future<CampaignProgressState> load({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final completedLevelIndexes =
        prefs
            .getStringList(_completedLevelsKey)
            ?.map(int.tryParse)
            .whereType<int>()
            .toSet() ??
        const <int>{};
    final lastActivityDate = _parseDateKey(
      prefs.getString(_lastActivityDateKey),
    );
    final state = CampaignProgressState(
      completedLevelIndexes: completedLevelIndexes,
      offensiveCount: prefs.getInt(_offensiveCountKey) ?? 0,
      lastActivityDate: lastActivityDate,
    ).normalizeForToday(now ?? DateTime.now());

    if (state.offensiveCount != (prefs.getInt(_offensiveCountKey) ?? 0)) {
      await save(state);
    }

    return state;
  }

  Future<void> save(CampaignProgressState state) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _completedLevelsKey,
      state.completedLevelIndexes.map((index) => '$index').toList()..sort(),
    );
    await prefs.setInt(_offensiveCountKey, state.offensiveCount);

    final lastActivityDate = state.lastActivityDate;
    if (lastActivityDate == null) {
      await prefs.remove(_lastActivityDateKey);
      return;
    }

    await prefs.setString(_lastActivityDateKey, _dateKey(lastActivityDate));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_completedLevelsKey);
    await prefs.remove(_offensiveCountKey);
    await prefs.remove(_lastActivityDateKey);
  }

  static DateTime? _parseDateKey(String? value) {
    if (value == null) {
      return null;
    }

    final date = DateTime.tryParse(value);
    if (date == null) {
      return null;
    }

    return DateTime(date.year, date.month, date.day);
  }

  static String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');

    return '${normalized.year}-$month-$day';
  }
}
