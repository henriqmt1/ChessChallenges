import 'package:chess_chalenges/app/local_game/presentation/viewmodels/local_game_controller.dart';
import 'package:chess_chalenges/app/local_game/presentation/viewmodels/local_game_state.dart';
import 'package:chess_chalenges/shared/chess/chess_asset_paths.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('selects legal pieces, moves, and switches turns', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      localGameControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final controller = container.read(localGameControllerProvider.notifier);
    var state = container.read(localGameControllerProvider);

    expect(state.turn, ChessPieceColor.white);
    expect(state.moveCount, 0);
    expect(state.status, LocalGameStatus.playing);

    controller.onSquareTapped('e2');
    state = container.read(localGameControllerProvider);

    expect(state.selectedSquare, 'e2');
    expect(state.legalTargets, containsAll(<String>['e3', 'e4']));

    controller.onSquareTapped('e4');
    state = container.read(localGameControllerProvider);

    expect(state.moveCount, 1);
    expect(state.turn, ChessPieceColor.black);
    expect(state.selectedSquare, isNull);
    expect(state.pieces['e2'], isNull);
    expect(state.pieces['e4']?.color, ChessPieceColor.white);
    expect(state.pieces['e4']?.kind, ChessPieceKind.pawn);

    controller.onSquareTapped('d2');
    state = container.read(localGameControllerProvider);

    expect(state.selectedSquare, isNull);

    controller.onSquareTapped('e7');
    state = container.read(localGameControllerProvider);

    expect(state.selectedSquare, 'e7');
    expect(state.legalTargets, containsAll(<String>['e6', 'e5']));
  });

  test('flips the board and resets the local game', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      localGameControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final controller = container.read(localGameControllerProvider.notifier);

    controller.toggleBoard();
    expect(container.read(localGameControllerProvider).boardFlipped, isTrue);

    controller.onSquareTapped('e2');
    controller.onSquareTapped('e4');
    expect(container.read(localGameControllerProvider).moveCount, 1);

    controller.resetGame();
    final state = container.read(localGameControllerProvider);

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
      localGameControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final controller = container.read(localGameControllerProvider.notifier);

    controller.onSquareTapped('e2');
    controller.onSquareTapped('e4');

    var state = container.read(localGameControllerProvider);
    expect(state.lastMove?.from, 'e2');
    expect(state.lastMove?.to, 'e4');
    expect(state.showLastMove, isFalse);

    controller.showLastMovePreview();
    state = container.read(localGameControllerProvider);
    expect(state.showLastMove, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 1600));

    state = container.read(localGameControllerProvider);
    expect(state.showLastMove, isFalse);
  });
}
