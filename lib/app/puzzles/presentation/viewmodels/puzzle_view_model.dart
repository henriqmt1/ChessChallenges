import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/chess/chess_rules_service.dart';
import '../../domain/entities/puzzle.dart';
import 'puzzle_dependencies.dart';
import 'puzzle_state.dart';

final puzzleViewModelProvider =
    AsyncNotifierProvider<PuzzleViewModel, PuzzleState>(PuzzleViewModel.new);

class PuzzleViewModel extends AsyncNotifier<PuzzleState> {
  ChessRulesService? _rules;

  @override
  Future<PuzzleState> build() async {
    final puzzles = await ref.watch(getDemoPuzzlesUseCaseProvider).call();

    return _newPuzzleState(
      puzzles: puzzles,
      selectedPuzzleIndex: 0,
      puzzle: puzzles.first,
    );
  }

  void selectPuzzle(int index) {
    final current = state.value;

    if (current == null || index < 0 || index >= current.puzzles.length) {
      return;
    }

    state = AsyncValue.data(
      _newPuzzleState(
        puzzles: current.puzzles,
        selectedPuzzleIndex: index,
        puzzle: current.puzzles[index],
      ),
    );
  }

  void resetPuzzle() {
    final current = state.value;

    if (current == null) {
      return;
    }

    state = AsyncValue.data(
      _newPuzzleState(
        puzzles: current.puzzles,
        selectedPuzzleIndex: current.selectedPuzzleIndex,
        puzzle: current.puzzle,
      ),
    );
  }

  bool showHint() {
    final current = state.value;

    if (current == null || !current.canInteract || current.hintUsed) {
      return false;
    }

    final expectedMove = current.nextExpectedMove;
    if (expectedMove == null) {
      return false;
    }

    final from = expectedMove.substring(0, 2);
    final to = expectedMove.substring(2, 4);
    final hintMessage = current.completedPlayerMoves == 0
        ? PuzzleMessage.puzzleHint
        : PuzzleMessage.lookHighlightedPiece;

    state = AsyncValue.data(
      current.copyWith(
        selectedSquare: from,
        legalTargets: {to},
        hintUsed: true,
        message: hintMessage,
      ),
    );
    return true;
  }

  void showSolution() {
    final current = state.value;

    if (current == null) {
      return;
    }

    state = AsyncValue.data(
      current.copyWith(solutionVisible: true, message: PuzzleMessage.solution),
    );
  }

  void retryCurrentMove() {
    final current = state.value;

    if (current == null || current.status != PuzzleStatus.failed) {
      return;
    }

    state = AsyncValue.data(
      current.copyWith(
        status: PuzzleStatus.playing,
        selectedSquare: null,
        legalTargets: {},
        hintUsed: false,
        message: PuzzleMessage.tryMoveAgain,
      ),
    );
  }

  void onSquareTapped(String square) {
    final current = state.value;
    final rules = _rules;

    if (current == null || rules == null || !current.canInteract) {
      return;
    }

    if (current.selectedSquare != null &&
        current.legalTargets.contains(square)) {
      _attemptMove(from: current.selectedSquare!, to: square);
      return;
    }

    final targets = rules.legalTargetsFrom(square).toSet();

    if (current.pieces.containsKey(square) && targets.isNotEmpty) {
      state = AsyncValue.data(
        current.copyWith(
          selectedSquare: square,
          legalTargets: targets,
          message: PuzzleMessage.chooseRightSquare,
        ),
      );
      return;
    }

    state = AsyncValue.data(
      current.copyWith(
        selectedSquare: null,
        legalTargets: {},
        message: PuzzleMessage.tapPiece,
      ),
    );
  }

  PuzzleState _newPuzzleState({
    required List<Puzzle> puzzles,
    required int selectedPuzzleIndex,
    required Puzzle puzzle,
  }) {
    _rules = ChessRulesService.fromFen(puzzle.fen);

    return PuzzleState(
      puzzles: puzzles,
      selectedPuzzleIndex: selectedPuzzleIndex,
      puzzle: puzzle,
      pieces: _rules!.pieces,
      currentMoveIndex: 0,
      completedPlayerMoves: 0,
      status: PuzzleStatus.playing,
      message: PuzzleMessage.findBestMove,
      selectedSquare: null,
      legalTargets: {},
      hintUsed: false,
      solutionVisible: false,
    );
  }

  void _attemptMove({required String from, required String to}) {
    final current = state.value;
    final rules = _rules;

    if (current == null || rules == null) {
      return;
    }

    final expectedMove = current.nextExpectedMove;
    if (expectedMove == null) {
      return;
    }

    final attemptedMove = _attemptedMoveForExpected(
      from: from,
      to: to,
      expectedMove: expectedMove,
    );

    if (attemptedMove != expectedMove) {
      state = AsyncValue.data(
        current.copyWith(
          status: PuzzleStatus.failed,
          selectedSquare: null,
          legalTargets: {},
          message: PuzzleMessage.wrongMove,
        ),
      );
      return;
    }

    if (!rules.isLegalUciMove(expectedMove) ||
        !rules.applyUciMove(expectedMove)) {
      state = AsyncValue.data(
        current.copyWith(
          status: PuzzleStatus.failed,
          selectedSquare: null,
          legalTargets: {},
          message: PuzzleMessage.inconsistentPuzzle,
        ),
      );
      return;
    }

    var nextMoveIndex = current.currentMoveIndex + 1;
    var opponentReplies = 0;

    while (nextMoveIndex < current.puzzle.moves.length &&
        !current.puzzle.playerMoveIndexes.contains(nextMoveIndex)) {
      final opponentMove = current.puzzle.moves[nextMoveIndex];

      if (!rules.applyUciMove(opponentMove)) {
        state = AsyncValue.data(
          current.copyWith(
            status: PuzzleStatus.failed,
            selectedSquare: null,
            legalTargets: {},
            message: PuzzleMessage.invalidOpponentReply,
          ),
        );
        return;
      }

      opponentReplies++;
      nextMoveIndex++;
    }

    final completedPlayerMoves = current.completedPlayerMoves + 1;
    final isCompleted = nextMoveIndex >= current.puzzle.moves.length;
    final message = isCompleted
        ? PuzzleMessage.completed
        : opponentReplies > 0
        ? PuzzleMessage.opponentReplied
        : PuzzleMessage.continueSequence;

    state = AsyncValue.data(
      current.copyWith(
        pieces: rules.pieces,
        currentMoveIndex: nextMoveIndex,
        completedPlayerMoves: completedPlayerMoves,
        status: isCompleted ? PuzzleStatus.completed : PuzzleStatus.playing,
        selectedSquare: null,
        legalTargets: {},
        hintUsed: false,
        message: message,
      ),
    );
  }

  static String _attemptedMoveForExpected({
    required String from,
    required String to,
    required String expectedMove,
  }) {
    final baseMove = '$from$to';

    if (expectedMove.length == 5 && expectedMove.startsWith(baseMove)) {
      return expectedMove;
    }

    return baseMove;
  }
}
