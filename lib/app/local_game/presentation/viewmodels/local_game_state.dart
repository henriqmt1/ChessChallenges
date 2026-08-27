import '../../../../shared/chess/board_move.dart';
import '../../../../shared/chess/board_piece.dart';
import '../../../../shared/chess/chess_asset_paths.dart';

const localGameDailyActivityMoveThreshold = 6;

enum LocalGameStatus { playing, checkmate, draw }

class LocalGameState {
  const LocalGameState({
    required this.pieces,
    required this.turn,
    required this.status,
    required this.inCheck,
    required this.selectedSquare,
    required this.legalTargets,
    required this.moveCount,
    required this.boardFlipped,
    required this.lastMove,
    required this.showLastMove,
  });

  final Map<String, BoardPiece> pieces;
  final ChessPieceColor turn;
  final LocalGameStatus status;
  final bool inCheck;
  final String? selectedSquare;
  final Set<String> legalTargets;
  final int moveCount;
  final bool boardFlipped;
  final BoardMove? lastMove;
  final bool showLastMove;

  bool get canInteract => status == LocalGameStatus.playing;

  bool get qualifiesForDailyActivity {
    return moveCount >= localGameDailyActivityMoveThreshold ||
        (status != LocalGameStatus.playing && moveCount > 0);
  }

  ChessPieceColor? get winner {
    if (status != LocalGameStatus.checkmate) {
      return null;
    }

    return turn == ChessPieceColor.white
        ? ChessPieceColor.black
        : ChessPieceColor.white;
  }

  LocalGameState copyWith({
    Map<String, BoardPiece>? pieces,
    ChessPieceColor? turn,
    LocalGameStatus? status,
    bool? inCheck,
    Object? selectedSquare = _unset,
    Set<String>? legalTargets,
    int? moveCount,
    bool? boardFlipped,
    Object? lastMove = _unset,
    bool? showLastMove,
  }) {
    return LocalGameState(
      pieces: pieces ?? this.pieces,
      turn: turn ?? this.turn,
      status: status ?? this.status,
      inCheck: inCheck ?? this.inCheck,
      selectedSquare: selectedSquare == _unset
          ? this.selectedSquare
          : selectedSquare as String?,
      legalTargets: legalTargets ?? this.legalTargets,
      moveCount: moveCount ?? this.moveCount,
      boardFlipped: boardFlipped ?? this.boardFlipped,
      lastMove: lastMove == _unset ? this.lastMove : lastMove as BoardMove?,
      showLastMove: showLastMove ?? this.showLastMove,
    );
  }
}

const _unset = Object();
