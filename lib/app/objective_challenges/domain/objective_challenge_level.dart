import '../../../shared/chess/chess_asset_paths.dart';

enum ObjectiveChallengeGoalType { checkmate, materialGain }

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
    required this.minimumPlayerMoves,
    required this.maximumPlayerMoves,
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
  final int minimumPlayerMoves;
  final int maximumPlayerMoves;
  final int startMaterialBalance;
  final ObjectiveChallengeGoal goal;

  bool get isMateInOne {
    return goal.type == ObjectiveChallengeGoalType.checkmate &&
        minimumPlayerMoves == 1 &&
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
