import '../../../../shared/chess/board_piece.dart';
import '../../domain/entities/puzzle.dart';

enum PuzzleStatus { playing, failed, completed }

enum PuzzleMessage {
  findBestMove,
  puzzleHint,
  lookHighlightedPiece,
  solution,
  tryMoveAgain,
  chooseRightSquare,
  tapPiece,
  wrongMove,
  inconsistentPuzzle,
  invalidOpponentReply,
  completed,
  opponentReplied,
  continueSequence,
}

class PuzzleState {
  const PuzzleState({
    required this.puzzles,
    required this.selectedPuzzleIndex,
    required this.puzzle,
    required this.pieces,
    required this.currentMoveIndex,
    required this.completedPlayerMoves,
    required this.status,
    required this.message,
    required this.selectedSquare,
    required this.legalTargets,
    required this.hintUsed,
    required this.solutionVisible,
  });

  final List<Puzzle> puzzles;
  final int selectedPuzzleIndex;
  final Puzzle puzzle;
  final Map<String, BoardPiece> pieces;
  final int currentMoveIndex;
  final int completedPlayerMoves;
  final PuzzleStatus status;
  final PuzzleMessage message;
  final String? selectedSquare;
  final Set<String> legalTargets;
  final bool hintUsed;
  final bool solutionVisible;

  int get totalPlayerMoves => puzzle.playerMoveCount;

  bool get canInteract => status == PuzzleStatus.playing;

  String? get nextExpectedMove {
    if (currentMoveIndex >= puzzle.moves.length) {
      return null;
    }

    return puzzle.moves[currentMoveIndex];
  }

  String get solutionText {
    return puzzle.playerMoveIndexes
        .map((index) => puzzle.moves[index])
        .map(_formatUciMove)
        .join('  ');
  }

  PuzzleState copyWith({
    List<Puzzle>? puzzles,
    int? selectedPuzzleIndex,
    Puzzle? puzzle,
    Map<String, BoardPiece>? pieces,
    int? currentMoveIndex,
    int? completedPlayerMoves,
    PuzzleStatus? status,
    PuzzleMessage? message,
    Object? selectedSquare = _unset,
    Set<String>? legalTargets,
    bool? hintUsed,
    bool? solutionVisible,
  }) {
    return PuzzleState(
      puzzles: puzzles ?? this.puzzles,
      selectedPuzzleIndex: selectedPuzzleIndex ?? this.selectedPuzzleIndex,
      puzzle: puzzle ?? this.puzzle,
      pieces: pieces ?? this.pieces,
      currentMoveIndex: currentMoveIndex ?? this.currentMoveIndex,
      completedPlayerMoves: completedPlayerMoves ?? this.completedPlayerMoves,
      status: status ?? this.status,
      message: message ?? this.message,
      selectedSquare: selectedSquare == _unset
          ? this.selectedSquare
          : selectedSquare as String?,
      legalTargets: legalTargets ?? this.legalTargets,
      hintUsed: hintUsed ?? this.hintUsed,
      solutionVisible: solutionVisible ?? this.solutionVisible,
    );
  }

  static String _formatUciMove(String move) {
    final from = move.substring(0, 2);
    final to = move.substring(2, 4);
    final promotion = move.length == 5 ? '=${move.substring(4)}' : '';

    return '$from-$to$promotion';
  }
}

const _unset = Object();
