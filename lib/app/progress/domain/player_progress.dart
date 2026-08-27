import 'dart:math' as math;

class PlayerProgress {
  const PlayerProgress({
    required this.schemaVersion,
    required this.campaignCompletedLevelIndexes,
    required this.offensiveCount,
    required this.bestOffensiveCount,
    required this.lastActivityDate,
    required this.activeDayKeys,
    required this.objectiveStarsByLevel,
    required this.botGamesPlayed,
    required this.botWins,
    required this.botDraws,
    required this.botLosses,
    required this.botGamesByDifficulty,
    required this.botWinsByDifficulty,
    required this.localGamesPlayed,
    required this.localWhiteWins,
    required this.localBlackWins,
    required this.localDraws,
    required this.updatedAt,
    required this.lastSyncedAt,
  });

  factory PlayerProgress.empty() {
    return const PlayerProgress(
      schemaVersion: 1,
      campaignCompletedLevelIndexes: <int>{},
      offensiveCount: 0,
      bestOffensiveCount: 0,
      lastActivityDate: null,
      activeDayKeys: <String>{},
      objectiveStarsByLevel: <int, int>{},
      botGamesPlayed: 0,
      botWins: 0,
      botDraws: 0,
      botLosses: 0,
      botGamesByDifficulty: <String, int>{},
      botWinsByDifficulty: <String, int>{},
      localGamesPlayed: 0,
      localWhiteWins: 0,
      localBlackWins: 0,
      localDraws: 0,
      updatedAt: null,
      lastSyncedAt: null,
    );
  }

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    final lastActivityDate = _dateOnly(_dateFromJson(json['lastActivityDate']));
    final offensiveCount = _intFromJson(json['offensiveCount']);
    final activeDayKeys = _activeDayKeysWithCurrentStreak(
      _stringSetFromJson(json['activeDayKeys']),
      lastActivityDate,
      offensiveCount,
    );

    return PlayerProgress(
      schemaVersion: _intFromJson(json['schemaVersion']),
      campaignCompletedLevelIndexes: _intSetFromJson(
        json['campaignCompletedLevelIndexes'],
      ),
      offensiveCount: offensiveCount,
      bestOffensiveCount: _intFromJson(json['bestOffensiveCount']),
      lastActivityDate: lastActivityDate,
      activeDayKeys: activeDayKeys,
      objectiveStarsByLevel: _intMapFromJson(json['objectiveStarsByLevel']),
      botGamesPlayed: _intFromJson(json['botGamesPlayed']),
      botWins: _intFromJson(json['botWins']),
      botDraws: _intFromJson(json['botDraws']),
      botLosses: _intFromJson(json['botLosses']),
      botGamesByDifficulty: _stringIntMapFromJson(json['botGamesByDifficulty']),
      botWinsByDifficulty: _stringIntMapFromJson(json['botWinsByDifficulty']),
      localGamesPlayed: _intFromJson(json['localGamesPlayed']),
      localWhiteWins: _intFromJson(json['localWhiteWins']),
      localBlackWins: _intFromJson(json['localBlackWins']),
      localDraws: _intFromJson(json['localDraws']),
      updatedAt: _dateFromJson(json['updatedAt']),
      lastSyncedAt: _dateFromJson(json['lastSyncedAt']),
    );
  }

  final int schemaVersion;
  final Set<int> campaignCompletedLevelIndexes;
  final int offensiveCount;
  final int bestOffensiveCount;
  final DateTime? lastActivityDate;
  final Set<String> activeDayKeys;
  final Map<int, int> objectiveStarsByLevel;
  final int botGamesPlayed;
  final int botWins;
  final int botDraws;
  final int botLosses;
  final Map<String, int> botGamesByDifficulty;
  final Map<String, int> botWinsByDifficulty;
  final int localGamesPlayed;
  final int localWhiteWins;
  final int localBlackWins;
  final int localDraws;
  final DateTime? updatedAt;
  final DateTime? lastSyncedAt;

  int get guidedLessonsCompleted => campaignCompletedLevelIndexes.length;

  int get objectiveStars {
    return objectiveStarsByLevel.values.fold(0, (sum, stars) => sum + stars);
  }

  int get objectiveChallengesCompleted {
    return objectiveStarsByLevel.values.where((stars) => stars > 0).length;
  }

  int get activeDays {
    return math.max(
      activeDayKeys.length,
      math.max(offensiveCount, bestOffensiveCount),
    );
  }

  int get totalGamesPlayed => botGamesPlayed + localGamesPlayed;

  int botGamesForDifficulty(String difficultyKey) {
    return botGamesByDifficulty[difficultyKey] ?? 0;
  }

  int botWinsForDifficulty(String difficultyKey) {
    return botWinsByDifficulty[difficultyKey] ?? 0;
  }

  PlayerProgress normalizeForToday(DateTime now) {
    final lastDate = lastActivityDate;
    if (lastDate == null || _daysBetween(lastDate, now) <= 1) {
      return this;
    }

    return copyWith(offensiveCount: 0);
  }

  PlayerProgress recordCampaignSnapshot({
    required Set<int> completedLevelIndexes,
    required int currentOffensiveCount,
    required DateTime? lastActivityDate,
    DateTime? now,
  }) {
    final normalizedLastActivity = _dateOnly(lastActivityDate);
    final nextActiveDays = _activeDayKeysWithCurrentStreak(
      activeDayKeys,
      normalizedLastActivity,
      currentOffensiveCount,
    );

    return copyWith(
      campaignCompletedLevelIndexes: {
        ...campaignCompletedLevelIndexes,
        ...completedLevelIndexes,
      },
      offensiveCount: currentOffensiveCount,
      bestOffensiveCount: math.max(bestOffensiveCount, currentOffensiveCount),
      lastActivityDate: normalizedLastActivity,
      activeDayKeys: nextActiveDays,
      updatedAt: now ?? DateTime.now(),
    );
  }

  PlayerProgress recordObjectiveStars({
    required int level,
    required int stars,
    DateTime? now,
  }) {
    final normalizedStars = stars.clamp(0, 3).toInt();
    final currentStars = objectiveStarsByLevel[level] ?? 0;

    return copyWith(
      objectiveStarsByLevel: {
        ...objectiveStarsByLevel,
        level: math.max(currentStars, normalizedStars),
      },
      updatedAt: now ?? DateTime.now(),
    );
  }

  PlayerProgress recordBotGameFinished({
    required String difficultyKey,
    required bool playerWon,
    required bool draw,
    DateTime? now,
  }) {
    final nextGamesByDifficulty = {...botGamesByDifficulty};
    nextGamesByDifficulty[difficultyKey] =
        (nextGamesByDifficulty[difficultyKey] ?? 0) + 1;

    final nextWinsByDifficulty = {...botWinsByDifficulty};
    if (playerWon) {
      nextWinsByDifficulty[difficultyKey] =
          (nextWinsByDifficulty[difficultyKey] ?? 0) + 1;
    }

    return copyWith(
      botGamesPlayed: botGamesPlayed + 1,
      botWins: botWins + (playerWon ? 1 : 0),
      botDraws: botDraws + (draw ? 1 : 0),
      botLosses: botLosses + (!playerWon && !draw ? 1 : 0),
      botGamesByDifficulty: nextGamesByDifficulty,
      botWinsByDifficulty: nextWinsByDifficulty,
      updatedAt: now ?? DateTime.now(),
    );
  }

  PlayerProgress recordLocalGameFinished({
    required String? winnerKey,
    required bool draw,
    DateTime? now,
  }) {
    return copyWith(
      localGamesPlayed: localGamesPlayed + 1,
      localWhiteWins: localWhiteWins + (winnerKey == 'white' ? 1 : 0),
      localBlackWins: localBlackWins + (winnerKey == 'black' ? 1 : 0),
      localDraws: localDraws + (draw ? 1 : 0),
      updatedAt: now ?? DateTime.now(),
    );
  }

  PlayerProgress mergeWith(PlayerProgress other) {
    final mergedLastActivity = _latestDateOnly(
      lastActivityDate,
      other.lastActivityDate,
    );
    final mergedBotWins = math.max(botWins, other.botWins);
    final mergedBotDraws = math.max(botDraws, other.botDraws);
    final mergedBotLosses = math.max(botLosses, other.botLosses);
    final mergedLocalWhiteWins = math.max(localWhiteWins, other.localWhiteWins);
    final mergedLocalBlackWins = math.max(localBlackWins, other.localBlackWins);
    final mergedLocalDraws = math.max(localDraws, other.localDraws);

    return copyWith(
      schemaVersion: math.max(schemaVersion, other.schemaVersion),
      campaignCompletedLevelIndexes: {
        ...campaignCompletedLevelIndexes,
        ...other.campaignCompletedLevelIndexes,
      },
      offensiveCount: _mergedOffensiveCount(this, other),
      bestOffensiveCount: math.max(
        bestOffensiveCount,
        other.bestOffensiveCount,
      ),
      lastActivityDate: mergedLastActivity,
      activeDayKeys: {...activeDayKeys, ...other.activeDayKeys},
      objectiveStarsByLevel: _mergeIntMapsByMax(
        objectiveStarsByLevel,
        other.objectiveStarsByLevel,
      ),
      botGamesPlayed: math.max(
        math.max(botGamesPlayed, other.botGamesPlayed),
        mergedBotWins + mergedBotDraws + mergedBotLosses,
      ),
      botWins: mergedBotWins,
      botDraws: mergedBotDraws,
      botLosses: mergedBotLosses,
      botGamesByDifficulty: _mergeStringIntMapsByMax(
        botGamesByDifficulty,
        other.botGamesByDifficulty,
      ),
      botWinsByDifficulty: _mergeStringIntMapsByMax(
        botWinsByDifficulty,
        other.botWinsByDifficulty,
      ),
      localGamesPlayed: math.max(
        math.max(localGamesPlayed, other.localGamesPlayed),
        mergedLocalWhiteWins + mergedLocalBlackWins + mergedLocalDraws,
      ),
      localWhiteWins: mergedLocalWhiteWins,
      localBlackWins: mergedLocalBlackWins,
      localDraws: mergedLocalDraws,
      updatedAt: _latestDate(updatedAt, other.updatedAt),
      lastSyncedAt: _latestDate(lastSyncedAt, other.lastSyncedAt),
    );
  }

  PlayerProgress markSynced(DateTime syncedAt) {
    return copyWith(lastSyncedAt: syncedAt);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'campaignCompletedLevelIndexes': campaignCompletedLevelIndexes.toList()
        ..sort(),
      'offensiveCount': offensiveCount,
      'bestOffensiveCount': bestOffensiveCount,
      'lastActivityDate': lastActivityDate == null
          ? null
          : dateKey(lastActivityDate!),
      'activeDayKeys': activeDayKeys.toList()..sort(),
      'objectiveStarsByLevel': objectiveStarsByLevel.map(
        (level, stars) => MapEntry('$level', stars),
      ),
      'botGamesPlayed': botGamesPlayed,
      'botWins': botWins,
      'botDraws': botDraws,
      'botLosses': botLosses,
      'botGamesByDifficulty': botGamesByDifficulty,
      'botWinsByDifficulty': botWinsByDifficulty,
      'localGamesPlayed': localGamesPlayed,
      'localWhiteWins': localWhiteWins,
      'localBlackWins': localBlackWins,
      'localDraws': localDraws,
      'updatedAt': updatedAt?.toIso8601String(),
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  PlayerProgress copyWith({
    int? schemaVersion,
    Set<int>? campaignCompletedLevelIndexes,
    int? offensiveCount,
    int? bestOffensiveCount,
    Object? lastActivityDate = _unset,
    Set<String>? activeDayKeys,
    Map<int, int>? objectiveStarsByLevel,
    int? botGamesPlayed,
    int? botWins,
    int? botDraws,
    int? botLosses,
    Map<String, int>? botGamesByDifficulty,
    Map<String, int>? botWinsByDifficulty,
    int? localGamesPlayed,
    int? localWhiteWins,
    int? localBlackWins,
    int? localDraws,
    Object? updatedAt = _unset,
    Object? lastSyncedAt = _unset,
  }) {
    return PlayerProgress(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      campaignCompletedLevelIndexes:
          campaignCompletedLevelIndexes ?? this.campaignCompletedLevelIndexes,
      offensiveCount: offensiveCount ?? this.offensiveCount,
      bestOffensiveCount: bestOffensiveCount ?? this.bestOffensiveCount,
      lastActivityDate: lastActivityDate == _unset
          ? this.lastActivityDate
          : lastActivityDate as DateTime?,
      activeDayKeys: activeDayKeys ?? this.activeDayKeys,
      objectiveStarsByLevel:
          objectiveStarsByLevel ?? this.objectiveStarsByLevel,
      botGamesPlayed: botGamesPlayed ?? this.botGamesPlayed,
      botWins: botWins ?? this.botWins,
      botDraws: botDraws ?? this.botDraws,
      botLosses: botLosses ?? this.botLosses,
      botGamesByDifficulty: botGamesByDifficulty ?? this.botGamesByDifficulty,
      botWinsByDifficulty: botWinsByDifficulty ?? this.botWinsByDifficulty,
      localGamesPlayed: localGamesPlayed ?? this.localGamesPlayed,
      localWhiteWins: localWhiteWins ?? this.localWhiteWins,
      localBlackWins: localBlackWins ?? this.localBlackWins,
      localDraws: localDraws ?? this.localDraws,
      updatedAt: updatedAt == _unset ? this.updatedAt : updatedAt as DateTime?,
      lastSyncedAt: lastSyncedAt == _unset
          ? this.lastSyncedAt
          : lastSyncedAt as DateTime?,
    );
  }

  static String dateKey(DateTime date) {
    final normalized = _dateOnly(date)!;
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');

    return '${normalized.year}-$month-$day';
  }

  static int _mergedOffensiveCount(
    PlayerProgress current,
    PlayerProgress other,
  ) {
    final currentLast = current.lastActivityDate;
    final otherLast = other.lastActivityDate;
    if (currentLast == null) {
      return other.offensiveCount;
    }
    if (otherLast == null) {
      return current.offensiveCount;
    }
    final currentDate = _dateOnly(currentLast)!;
    final otherDate = _dateOnly(otherLast)!;
    final comparison = currentDate.compareTo(otherDate);
    if (comparison == 0) {
      return math.max(current.offensiveCount, other.offensiveCount);
    }

    return comparison > 0 ? current.offensiveCount : other.offensiveCount;
  }

  static Set<String> _activeDayKeysWithCurrentStreak(
    Set<String> activeDayKeys,
    DateTime? lastActivityDate,
    int offensiveCount,
  ) {
    final nextActiveDays = {...activeDayKeys};
    final normalizedLastActivity = _dateOnly(lastActivityDate);
    if (normalizedLastActivity == null) {
      return nextActiveDays;
    }

    final streakDays = math.max(offensiveCount, 1);
    for (var offset = 0; offset < streakDays; offset++) {
      final date = DateTime(
        normalizedLastActivity.year,
        normalizedLastActivity.month,
        normalizedLastActivity.day - offset,
      );
      nextActiveDays.add(dateKey(date));
    }

    return nextActiveDays;
  }

  static DateTime? _latestDate(DateTime? first, DateTime? second) {
    if (first == null) {
      return second;
    }
    if (second == null) {
      return first;
    }

    return first.isAfter(second) ? first : second;
  }

  static DateTime? _latestDateOnly(DateTime? first, DateTime? second) {
    return _dateOnly(_latestDate(first, second));
  }

  static DateTime? _dateOnly(DateTime? date) {
    if (date == null) {
      return null;
    }

    return DateTime(date.year, date.month, date.day);
  }

  static int _daysBetween(DateTime start, DateTime end) {
    return _dateOnly(end)!.difference(_dateOnly(start)!).inDays;
  }

  static int _intFromJson(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  static Set<int> _intSetFromJson(Object? value) {
    if (value is! Iterable) {
      return <int>{};
    }

    return value.map(_intFromJson).where((item) => item >= 0).toSet();
  }

  static Set<String> _stringSetFromJson(Object? value) {
    if (value is! Iterable) {
      return <String>{};
    }

    return value
        .map((item) => '$item')
        .where((item) => item.isNotEmpty)
        .toSet();
  }

  static Map<int, int> _intMapFromJson(Object? value) {
    if (value is! Map) {
      return <int, int>{};
    }

    return value.map<int, int>((key, item) {
      return MapEntry(
        _intFromJson(key),
        _intFromJson(item).clamp(0, 3).toInt(),
      );
    })..removeWhere((level, _) => level <= 0);
  }

  static Map<String, int> _stringIntMapFromJson(Object? value) {
    if (value is! Map) {
      return <String, int>{};
    }

    return value.map<String, int>((key, item) {
      return MapEntry('$key', _intFromJson(item));
    })..removeWhere((key, item) => key.isEmpty || item < 0);
  }

  static Map<int, int> _mergeIntMapsByMax(
    Map<int, int> first,
    Map<int, int> second,
  ) {
    final merged = {...first};
    for (final entry in second.entries) {
      merged[entry.key] = math.max(merged[entry.key] ?? 0, entry.value);
    }

    return merged;
  }

  static Map<String, int> _mergeStringIntMapsByMax(
    Map<String, int> first,
    Map<String, int> second,
  ) {
    final merged = {...first};
    for (final entry in second.entries) {
      merged[entry.key] = math.max(merged[entry.key] ?? 0, entry.value);
    }

    return merged;
  }

  static DateTime? _dateFromJson(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    try {
      final dynamic timestamp = value;
      final dynamic parsed = timestamp.toDate();
      if (parsed is DateTime) {
        return parsed;
      }
    } on Object {
      return null;
    }

    return null;
  }
}

const _unset = Object();
