import 'package:chess_chalenges/app/objective_challenges/data/objective_challenge_data_source.dart';
import 'package:chess_chalenges/app/objective_challenges/domain/objective_challenge_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads objective challenge levels from campaign content', () async {
    final levels = await const ObjectiveChallengeDataSource().loadLevels();

    expect(levels, hasLength(30));
    expect(levels.first.goal.type, ObjectiveChallengeGoalType.checkmate);
    expect(levels.take(3).every((level) => level.isMateInOne), isTrue);
    expect(levels.skip(3).any((level) => !level.isMateInOne), isTrue);
    expect(levels.first.scoring.metric, ObjectiveChallengeScoreMetric.attempts);
    expect(levels.first.threeStarLimit, 1);
    expect(levels.first.scoring.twoStarLimit, 2);
    expect(levels.first.oneStarLimit, 3);

    final moveScoredLevel = levels[3];
    expect(
      moveScoredLevel.scoring.metric,
      ObjectiveChallengeScoreMetric.playerMoves,
    );
    expect(moveScoredLevel.starsFor(moveScoredLevel.threeStarLimit), 3);
    expect(moveScoredLevel.starsFor(moveScoredLevel.scoring.twoStarLimit), 2);
    expect(moveScoredLevel.starsFor(moveScoredLevel.oneStarLimit), 1);
    expect(moveScoredLevel.starsFor(moveScoredLevel.oneStarLimit + 1), 0);
  });
}
