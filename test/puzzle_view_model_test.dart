import 'package:chess_chalenges/app/puzzles/domain/entities/puzzle.dart';
import 'package:chess_chalenges/app/puzzles/presentation/l10n/puzzle_localizations.dart';
import 'package:chess_chalenges/app/puzzles/presentation/viewmodels/puzzle_state.dart';
import 'package:chess_chalenges/app/puzzles/presentation/viewmodels/puzzle_view_model.dart';
import 'package:chess_chalenges/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('shows the phase objective instead of a generic instruction', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(puzzleViewModelProvider.future);
    final state = _readPuzzleState(container);
    final l10n = lookupAppLocalizations(const Locale('pt', 'BR'));

    expect(state.localizedMessage(l10n), state.puzzle.objective);
    expect(state.puzzle.objective, isNot('Encontre a melhor jogada.'));
    expect(state.puzzle.hint.text, isNotEmpty);
  });

  test(
    'hint follows the current player move after an opponent reply',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(puzzleViewModelProvider.notifier);
      await container.read(puzzleViewModelProvider.future);

      final puzzle = _selectMultiMovePuzzle(container, notifier);
      final firstMove = puzzle.moves.first;
      notifier.onSquareTapped(firstMove.substring(0, 2));
      notifier.onSquareTapped(firstMove.substring(2, 4));
      expect(notifier.showHint(), isTrue);

      final state = _readPuzzleState(container);
      final nextMove = puzzle.moves[2];

      expect(state.currentMoveIndex, 2);
      expect(state.selectedSquare, nextMove.substring(0, 2));
      expect(state.legalTargets, contains(nextMove.substring(2, 4)));
    },
  );

  test('selecting the current puzzle restarts it', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(puzzleViewModelProvider.notifier);
    await container.read(puzzleViewModelProvider.future);

    final puzzle = _selectMultiMovePuzzle(container, notifier);
    final selectedIndex = _readPuzzleState(container).selectedPuzzleIndex;
    final firstMove = puzzle.moves.first;
    notifier.onSquareTapped(firstMove.substring(0, 2));
    notifier.onSquareTapped(firstMove.substring(2, 4));

    expect(_readPuzzleState(container).completedPlayerMoves, 1);

    notifier.selectPuzzle(selectedIndex);

    final restartedState = _readPuzzleState(container);
    expect(restartedState.selectedPuzzleIndex, selectedIndex);
    expect(restartedState.currentMoveIndex, 0);
    expect(restartedState.completedPlayerMoves, 0);
    expect(restartedState.status, PuzzleStatus.playing);
  });

  test(
    'hint is disabled for the current move and resets on next move',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(puzzleViewModelProvider.notifier);
      await container.read(puzzleViewModelProvider.future);

      final puzzle = _selectMultiMovePuzzle(container, notifier);
      expect(notifier.showHint(), isTrue);

      var state = _readPuzzleState(container);
      final firstMove = puzzle.moves.first;
      expect(state.hintUsed, isTrue);
      expect(state.selectedSquare, firstMove.substring(0, 2));
      expect(state.legalTargets, contains(firstMove.substring(2, 4)));

      expect(notifier.showHint(), isFalse);

      state = _readPuzzleState(container);
      expect(state.hintUsed, isTrue);
      expect(state.selectedSquare, firstMove.substring(0, 2));

      notifier.onSquareTapped(firstMove.substring(2, 4));

      state = _readPuzzleState(container);
      expect(state.currentMoveIndex, 2);
      expect(state.hintUsed, isFalse);

      expect(notifier.showHint(), isTrue);

      state = _readPuzzleState(container);
      final nextMove = puzzle.moves[2];
      expect(state.hintUsed, isTrue);
      expect(state.selectedSquare, nextMove.substring(0, 2));
      expect(state.legalTargets, contains(nextMove.substring(2, 4)));
    },
  );

  test('retrying a wrong move re-enables the hint', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(puzzleViewModelProvider.notifier);
    await container.read(puzzleViewModelProvider.future);

    expect(notifier.showHint(), isTrue);
    final hintedState = _readPuzzleState(container);
    final source = hintedState.selectedSquare!;
    final expectedTarget = hintedState.legalTargets.single;

    notifier.onSquareTapped(source);
    final selectableTargets = _readPuzzleState(container).legalTargets;
    final wrongTarget = selectableTargets.firstWhere(
      (target) => target != expectedTarget,
    );
    notifier.onSquareTapped(wrongTarget);

    expect(_readPuzzleState(container).status, PuzzleStatus.failed);
    notifier.retryCurrentMove();

    final retryState = _readPuzzleState(container);
    expect(retryState.status, PuzzleStatus.playing);
    expect(retryState.hintUsed, isFalse);
    expect(notifier.showHint(), isTrue);
  });
}

PuzzleState _readPuzzleState(ProviderContainer container) {
  final asyncState = container.read(puzzleViewModelProvider);

  return switch (asyncState) {
    AsyncData(:final value) => value,
    AsyncError(:final error) => throw error,
    _ => throw StateError('Puzzle state is still loading.'),
  };
}

Puzzle _selectMultiMovePuzzle(
  ProviderContainer container,
  PuzzleViewModel notifier,
) {
  final initial = _readPuzzleState(container);
  final index = initial.puzzles.indexWhere(
    (puzzle) => puzzle.playerMoveCount >= 2,
  );
  expect(index, greaterThanOrEqualTo(0));
  notifier.selectPuzzle(index);
  return _readPuzzleState(container).puzzle;
}
