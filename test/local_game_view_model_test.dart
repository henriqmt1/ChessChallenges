import 'package:chess_chalenges/app/local_game/presentation/viewmodels/local_game_view_model.dart';
import 'package:chess_chalenges/app/local_game/presentation/viewmodels/local_game_state.dart';
import 'package:chess_chalenges/shared/chess/chess_asset_paths.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('selects legal pieces, moves, and switches turns', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      localGameViewModelProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final viewModel = container.read(localGameViewModelProvider.notifier);
    var state = container.read(localGameViewModelProvider);

    expect(state.turn, ChessPieceColor.white);
    expect(state.moveCount, 0);
    expect(state.status, LocalGameStatus.playing);

    viewModel.onSquareTapped('e2');
    state = container.read(localGameViewModelProvider);

    expect(state.selectedSquare, 'e2');
    expect(state.legalTargets, containsAll(<String>['e3', 'e4']));

    viewModel.onSquareTapped('e4');
    state = container.read(localGameViewModelProvider);

    expect(state.moveCount, 1);
    expect(state.turn, ChessPieceColor.black);
    expect(state.selectedSquare, isNull);
    expect(state.pieces['e2'], isNull);
    expect(state.pieces['e4']?.color, ChessPieceColor.white);
    expect(state.pieces['e4']?.kind, ChessPieceKind.pawn);

    viewModel.onSquareTapped('d2');
    state = container.read(localGameViewModelProvider);

    expect(state.selectedSquare, isNull);

    viewModel.onSquareTapped('e7');
    state = container.read(localGameViewModelProvider);

    expect(state.selectedSquare, 'e7');
    expect(state.legalTargets, containsAll(<String>['e6', 'e5']));
  });

  test('flips the board and resets the local game', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      localGameViewModelProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final viewModel = container.read(localGameViewModelProvider.notifier);

    viewModel.toggleBoard();
    expect(container.read(localGameViewModelProvider).boardFlipped, isTrue);

    viewModel.onSquareTapped('e2');
    viewModel.onSquareTapped('e4');
    expect(container.read(localGameViewModelProvider).moveCount, 1);

    viewModel.resetGame();
    final state = container.read(localGameViewModelProvider);

    expect(state.boardFlipped, isTrue);
    expect(state.moveCount, 0);
    expect(state.turn, ChessPieceColor.white);
    expect(state.pieces['e2']?.kind, ChessPieceKind.pawn);
    expect(state.pieces['e4'], isNull);
  });

  test('stores and temporarily shows the last move', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      localGameViewModelProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final viewModel = container.read(localGameViewModelProvider.notifier);

    viewModel.onSquareTapped('e2');
    viewModel.onSquareTapped('e4');

    var state = container.read(localGameViewModelProvider);
    expect(state.lastMove?.from, 'e2');
    expect(state.lastMove?.to, 'e4');
    expect(state.showLastMove, isFalse);

    viewModel.showLastMovePreview();
    state = container.read(localGameViewModelProvider);
    expect(state.showLastMove, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 1600));

    state = container.read(localGameViewModelProvider);
    expect(state.showLastMove, isFalse);
  });
}
