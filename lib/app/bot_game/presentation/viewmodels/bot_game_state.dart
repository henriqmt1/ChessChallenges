import '../../../../shared/chess/board_move.dart';
import '../../../../shared/chess/board_piece.dart';
import '../../../../shared/chess/chess_asset_paths.dart';
import '../../domain/bot_difficulty.dart';

const botGameDailyActivityMoveThreshold = 6;

enum BotGameStatus { choosingDifficulty, playing, checkmate, draw }

class BotGameState {
  const BotGameState({
    required this.pieces,
    required this.turn,
    required this.status,
    required this.inCheck,
    required this.selectedSquare,
    required this.legalTargets,
    required this.moveCount,
    required this.difficulty,
    required this.botThinking,
    required this.lastMove,
    required this.showLastMove,
  });

  final Map<String, BoardPiece> pieces;
  final ChessPieceColor turn;
  final BotGameStatus status;
  final bool inCheck;
  final String? selectedSquare;
  final Set<String> legalTargets;
  final int moveCount;
  final BotDifficulty? difficulty;
  final bool botThinking;
  final BoardMove? lastMove;
  final bool showLastMove;

  bool get canInteract {
    return status == BotGameStatus.playing &&
        difficulty != null &&
        !botThinking &&
        turn == ChessPieceColor.white;
  }

  bool get isPlayingGame => status != BotGameStatus.choosingDifficulty;

  bool get qualifiesForDailyActivity {
    return moveCount >= botGameDailyActivityMoveThreshold ||
        (status != BotGameStatus.playing &&
            status != BotGameStatus.choosingDifficulty &&
            moveCount > 0);
  }

  ChessPieceColor? get winner {
    if (status != BotGameStatus.checkmate) {
      return null;
    }

    return turn == ChessPieceColor.white
        ? ChessPieceColor.black
        : ChessPieceColor.white;
  }

  BotGameState copyWith({
    Map<String, BoardPiece>? pieces,
    ChessPieceColor? turn,
    BotGameStatus? status,
    bool? inCheck,
    Object? selectedSquare = _unset,
    Set<String>? legalTargets,
    int? moveCount,
    Object? difficulty = _unset,
    bool? botThinking,
    Object? lastMove = _unset,
    bool? showLastMove,
  }) {
    return BotGameState(
      pieces: pieces ?? this.pieces,
      turn: turn ?? this.turn,
      status: status ?? this.status,
      inCheck: inCheck ?? this.inCheck,
      selectedSquare: selectedSquare == _unset
          ? this.selectedSquare
          : selectedSquare as String?,
      legalTargets: legalTargets ?? this.legalTargets,
      moveCount: moveCount ?? this.moveCount,
      difficulty: difficulty == _unset
          ? this.difficulty
          : difficulty as BotDifficulty?,
      botThinking: botThinking ?? this.botThinking,
      lastMove: lastMove == _unset ? this.lastMove : lastMove as BoardMove?,
      showLastMove: showLastMove ?? this.showLastMove,
    );
  }
}

const _unset = Object();
