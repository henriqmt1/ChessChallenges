import '../../../../shared/chess/board_move.dart';
import '../../../../shared/chess/board_piece.dart';
import '../../../../shared/chess/chess_asset_paths.dart';

enum ObjectiveChallengeSessionStatus { playing, completed, failed }

class ObjectiveChallengeGameState {
  const ObjectiveChallengeGameState({
    required this.pieces,
    required this.turn,
    required this.status,
    required this.inCheck,
    required this.selectedSquare,
    required this.legalTargets,
    required this.playerMoveCount,
    required this.earnedStars,
    required this.botThinking,
    required this.lastMove,
    required this.lastMateAttemptMissed,
    required this.missedMateAttemptCount,
    required this.moveSoundCount,
  });

  final Map<String, BoardPiece> pieces;
  final ChessPieceColor turn;
  final ObjectiveChallengeSessionStatus status;
  final bool inCheck;
  final String? selectedSquare;
  final Set<String> legalTargets;
  final int playerMoveCount;
  final int earnedStars;
  final bool botThinking;
  final BoardMove? lastMove;
  final bool lastMateAttemptMissed;
  final int missedMateAttemptCount;
  final int moveSoundCount;

  bool canInteract(ChessPieceColor playerColor) {
    return status == ObjectiveChallengeSessionStatus.playing &&
        !botThinking &&
        turn == playerColor;
  }

  ObjectiveChallengeGameState copyWith({
    Map<String, BoardPiece>? pieces,
    ChessPieceColor? turn,
    ObjectiveChallengeSessionStatus? status,
    bool? inCheck,
    Object? selectedSquare = _unset,
    Set<String>? legalTargets,
    int? playerMoveCount,
    int? earnedStars,
    bool? botThinking,
    Object? lastMove = _unset,
    bool? lastMateAttemptMissed,
    int? missedMateAttemptCount,
    int? moveSoundCount,
  }) {
    return ObjectiveChallengeGameState(
      pieces: pieces ?? this.pieces,
      turn: turn ?? this.turn,
      status: status ?? this.status,
      inCheck: inCheck ?? this.inCheck,
      selectedSquare: selectedSquare == _unset
          ? this.selectedSquare
          : selectedSquare as String?,
      legalTargets: legalTargets ?? this.legalTargets,
      playerMoveCount: playerMoveCount ?? this.playerMoveCount,
      earnedStars: earnedStars ?? this.earnedStars,
      botThinking: botThinking ?? this.botThinking,
      lastMove: lastMove == _unset ? this.lastMove : lastMove as BoardMove?,
      lastMateAttemptMissed:
          lastMateAttemptMissed ?? this.lastMateAttemptMissed,
      missedMateAttemptCount:
          missedMateAttemptCount ?? this.missedMateAttemptCount,
      moveSoundCount: moveSoundCount ?? this.moveSoundCount,
    );
  }
}

const _unset = Object();
