class CampaignProgressState {
  const CampaignProgressState({
    required this.completedLevelIndexes,
    required this.offensiveCount,
    required this.lastActivityDate,
  });

  factory CampaignProgressState.empty() {
    return const CampaignProgressState(
      completedLevelIndexes: <int>{},
      offensiveCount: 0,
      lastActivityDate: null,
    );
  }

  final Set<int> completedLevelIndexes;
  final int offensiveCount;
  final DateTime? lastActivityDate;

  int get completedCount => completedLevelIndexes.length;

  int get currentLevelIndex {
    var index = 0;

    while (completedLevelIndexes.contains(index)) {
      index++;
    }

    return index;
  }

  bool isCompleted(int index) {
    return completedLevelIndexes.contains(index);
  }

  bool isUnlocked(int index) {
    return index <= currentLevelIndex;
  }

  bool hasActivityOn(DateTime date) {
    final lastDate = lastActivityDate;
    return lastDate != null && _daysBetween(lastDate, date) == 0;
  }

  CampaignProgressState recordActivity({
    required int completedLevelIndex,
    required DateTime now,
  }) {
    final today = _dateOnly(now);
    final nextOffensiveCount = _nextOffensiveCount(today);

    return copyWith(
      completedLevelIndexes: {...completedLevelIndexes, completedLevelIndex},
      offensiveCount: nextOffensiveCount,
      lastActivityDate: today,
    );
  }

  CampaignProgressState recordDailyActivity({required DateTime now}) {
    final today = _dateOnly(now);
    final nextOffensiveCount = _nextOffensiveCount(today);

    return copyWith(
      offensiveCount: nextOffensiveCount,
      lastActivityDate: today,
    );
  }

  CampaignProgressState normalizeForToday(DateTime now) {
    final lastDate = lastActivityDate;
    if (lastDate == null || _daysBetween(lastDate, now) > 1) {
      return copyWith(offensiveCount: 0);
    }

    return this;
  }

  CampaignProgressState copyWith({
    Set<int>? completedLevelIndexes,
    int? offensiveCount,
    Object? lastActivityDate = _unset,
  }) {
    return CampaignProgressState(
      completedLevelIndexes:
          completedLevelIndexes ?? this.completedLevelIndexes,
      offensiveCount: offensiveCount ?? this.offensiveCount,
      lastActivityDate: lastActivityDate == _unset
          ? this.lastActivityDate
          : lastActivityDate as DateTime?,
    );
  }

  int _nextOffensiveCount(DateTime today) {
    final lastDate = lastActivityDate;
    if (lastDate == null || offensiveCount == 0) {
      return 1;
    }

    final daysSinceLastActivity = _daysBetween(lastDate, today);
    if (daysSinceLastActivity == 0) {
      return offensiveCount;
    }

    if (daysSinceLastActivity == 1) {
      return offensiveCount + 1;
    }

    return 1;
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static int _daysBetween(DateTime start, DateTime end) {
    return _dateOnly(end).difference(_dateOnly(start)).inDays;
  }
}

const _unset = Object();
