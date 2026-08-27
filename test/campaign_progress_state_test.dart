import 'package:chess_chalenges/app/campaign/presentation/viewmodels/campaign_progress_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps, increases, and resets offensive count by activity date', () {
    final firstDay = DateTime(2026, 6, 16);
    final secondDay = DateTime(2026, 6, 17);
    final missedDay = DateTime(2026, 6, 19);

    final dayOneProgress = CampaignProgressState.empty().recordActivity(
      completedLevelIndex: 0,
      now: firstDay,
    );
    final repeatedSameDay = dayOneProgress.recordActivity(
      completedLevelIndex: 1,
      now: firstDay,
    );
    final nextDayProgress = repeatedSameDay.recordActivity(
      completedLevelIndex: 2,
      now: secondDay,
    );
    final normalizedAfterMiss = nextDayProgress.normalizeForToday(missedDay);

    expect(dayOneProgress.offensiveCount, 1);
    expect(dayOneProgress.hasActivityOn(firstDay), isTrue);
    expect(dayOneProgress.hasActivityOn(secondDay), isFalse);
    expect(repeatedSameDay.offensiveCount, 1);
    expect(nextDayProgress.offensiveCount, 2);
    expect(normalizedAfterMiss.offensiveCount, 0);
  });

  test('records daily activity without completing campaign levels', () {
    final activityDay = DateTime(2026, 7, 14);
    final progress = CampaignProgressState.empty().recordDailyActivity(
      now: activityDay,
    );

    expect(progress.completedLevelIndexes, isEmpty);
    expect(progress.offensiveCount, 1);
    expect(progress.hasActivityOn(activityDay), isTrue);
  });
}
