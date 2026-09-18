import '../../../shared/chess/chess_asset_paths.dart';

enum ObjectiveChallengeGoalType { checkmate, materialGain }

enum ObjectiveChallengeScoreMetric { playerMoves, attempts }

class ObjectiveChallengeScoring {
  const ObjectiveChallengeScoring({
    required this.metric,
    required this.threeStarLimit,
    required this.twoStarLimit,
    required this.oneStarLimit,
  }) : assert(threeStarLimit > 0),
       assert(threeStarLimit < twoStarLimit),
       assert(twoStarLimit < oneStarLimit);

  const ObjectiveChallengeScoring.moves({
    required int threeStarLimit,
    required int twoStarLimit,
    required int oneStarLimit,
  }) : this(
         metric: ObjectiveChallengeScoreMetric.playerMoves,
         threeStarLimit: threeStarLimit,
         twoStarLimit: twoStarLimit,
         oneStarLimit: oneStarLimit,
       );

  const ObjectiveChallengeScoring.attempts({required int oneStarLimit})
    : this(
        metric: ObjectiveChallengeScoreMetric.attempts,
        threeStarLimit: 1,
        twoStarLimit: 2,
        oneStarLimit: oneStarLimit,
      );

  final ObjectiveChallengeScoreMetric metric;
  final int threeStarLimit;
  final int twoStarLimit;
  final int oneStarLimit;

  bool get countsAttempts => metric == ObjectiveChallengeScoreMetric.attempts;

  int starsFor(int score) {
    if (score <= 0) {
      return 0;
    }
    if (score <= threeStarLimit) {
      return 3;
    }
    if (score <= twoStarLimit) {
      return 2;
    }
    if (score <= oneStarLimit) {
      return 1;
    }
    return 0;
  }
}

class ObjectiveChallengeGoal {
  const ObjectiveChallengeGoal.checkmate()
    : type = ObjectiveChallengeGoalType.checkmate,
      targetMaterialGain = 0;

  const ObjectiveChallengeGoal.materialGain(this.targetMaterialGain)
    : type = ObjectiveChallengeGoalType.materialGain;

  final ObjectiveChallengeGoalType type;
  final int targetMaterialGain;
}

class ObjectiveChallengeLevel {
  const ObjectiveChallengeLevel({
    required this.id,
    required this.level,
    required this.sourceLevel,
    required this.objective,
    required this.fen,
    required this.playerColor,
    required this.solutionMoves,
    required this.playerMoveIndexes,
    required this.scoring,
    required this.startMaterialBalance,
    required this.goal,
  });

  final String id;
  final int level;
  final int sourceLevel;
  final String objective;
  final String fen;
  final ChessPieceColor playerColor;
  final List<String> solutionMoves;
  final Set<int> playerMoveIndexes;
  final ObjectiveChallengeScoring scoring;
  final int startMaterialBalance;
  final ObjectiveChallengeGoal goal;

  int get threeStarLimit => scoring.threeStarLimit;

  int get oneStarLimit => scoring.oneStarLimit;

  int starsFor(int score) => scoring.starsFor(score);

  bool get isMateInOne {
    return goal.type == ObjectiveChallengeGoalType.checkmate &&
        scoring.threeStarLimit == 1 &&
        playerMoveIndexes.length == 1 &&
        solutionMoves.length == 1;
  }

  ChessPieceColor get botColor {
    return playerColor == ChessPieceColor.white
        ? ChessPieceColor.black
        : ChessPieceColor.white;
  }

  String? scriptedBotMoveAt(int plyIndex) {
    if (plyIndex < 0 ||
        plyIndex >= solutionMoves.length ||
        playerMoveIndexes.contains(plyIndex)) {
      return null;
    }

    return solutionMoves[plyIndex];
  }
}
