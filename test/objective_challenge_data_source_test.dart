import 'package:chess_chalenges/app/objective_challenges/data/objective_challenge_data_source.dart';
import 'package:chess_chalenges/app/objective_challenges/domain/objective_challenge_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads objective challenge levels from campaign content', () async {
    final levels = await const ObjectiveChallengeDataSource().loadLevels();

    expect(levels, hasLength(30));
    expect(levels.first.goal.type, ObjectiveChallengeGoalType.checkmate);
    expect(levels.take(10).every((level) => level.isMateInOne), isTrue);
    expect(levels.first.minimumPlayerMoves, 1);
    expect(levels.first.maximumPlayerMoves, 3);
    expect(levels[10].isMateInOne, isFalse);
  });
}
