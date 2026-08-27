import 'package:chess_chalenges/app/progress/domain/player_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('records campaign snapshot, active day, and best streak', () {
    final progress = PlayerProgress.empty().recordCampaignSnapshot(
      completedLevelIndexes: {0, 1, 2},
      currentOffensiveCount: 3,
      lastActivityDate: DateTime(2026, 7, 16),
      now: DateTime(2026, 7, 16, 12),
    );

    expect(progress.guidedLessonsCompleted, 3);
    expect(progress.offensiveCount, 3);
    expect(progress.bestOffensiveCount, 3);
    expect(progress.activeDays, 3);
    expect(
      progress.activeDayKeys,
      containsAll(['2026-07-14', '2026-07-15', '2026-07-16']),
    );
  });

  test('keeps active days coherent when loading old streak data', () {
    final progress = PlayerProgress.fromJson({
      'offensiveCount': 3,
      'bestOffensiveCount': 3,
      'lastActivityDate': '2026-07-16',
      'activeDayKeys': ['2026-07-16'],
    });

    expect(progress.activeDays, 3);
    expect(
      progress.activeDayKeys,
      containsAll(['2026-07-14', '2026-07-15', '2026-07-16']),
    );
  });

  test('active days is never lower than the best streak', () {
    final progress = PlayerProgress.fromJson({
      'offensiveCount': 0,
      'bestOffensiveCount': 5,
      'activeDayKeys': ['2026-07-16'],
    });

    expect(progress.activeDays, 5);
  });

  test('records bot and local game statistics', () {
    final progress = PlayerProgress.empty()
        .recordBotGameFinished(
          difficultyKey: 'advanced',
          playerWon: true,
          draw: false,
          now: DateTime(2026, 7, 16, 12),
        )
        .recordLocalGameFinished(
          winnerKey: 'black',
          draw: false,
          now: DateTime(2026, 7, 16, 12, 5),
        );

    expect(progress.totalGamesPlayed, 2);
    expect(progress.botGamesPlayed, 1);
    expect(progress.botWins, 1);
    expect(progress.botWinsForDifficulty('advanced'), 1);
    expect(progress.localGamesPlayed, 1);
    expect(progress.localBlackWins, 1);
  });

  test('merges progress without lowering stars or counters', () {
    final local = PlayerProgress.empty()
        .recordObjectiveStars(
          level: 1,
          stars: 2,
          now: DateTime(2026, 7, 16, 12),
        )
        .recordBotGameFinished(
          difficultyKey: 'beginner',
          playerWon: true,
          draw: false,
          now: DateTime(2026, 7, 16, 12),
        );
    final remote = PlayerProgress.empty()
        .recordObjectiveStars(
          level: 1,
          stars: 3,
          now: DateTime(2026, 7, 16, 13),
        )
        .recordBotGameFinished(
          difficultyKey: 'beginner',
          playerWon: false,
          draw: true,
          now: DateTime(2026, 7, 16, 13),
        );

    final merged = local.mergeWith(remote);

    expect(merged.objectiveStarsByLevel[1], 3);
    expect(merged.botGamesPlayed, 2);
    expect(merged.botWins, 1);
    expect(merged.botDraws, 1);
  });
}
