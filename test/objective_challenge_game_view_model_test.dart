import 'package:chess_chalenges/app/objective_challenges/data/objective_challenge_data_source.dart';
import 'package:chess_chalenges/app/objective_challenges/presentation/viewmodels/objective_challenge_game_view_model.dart';
import 'package:chess_chalenges/app/objective_challenges/presentation/viewmodels/objective_challenge_game_state.dart';
import 'package:chess_chalenges/shared/chess/chess_asset_paths.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('mate in one keeps the board position and scores by attempts', () async {
    final levels = await const ObjectiveChallengeDataSource().loadLevels();
    final level = levels.first;
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final provider = objectiveChallengeGameViewModelProvider(level);
    final viewModel = container.read(provider.notifier);
    final initialPieces = container.read(provider).pieces;

    final wrongMove = _findLegalNonSolutionMove(
      viewModel: viewModel,
      readState: () => container.read(provider),
      playerColor: level.playerColor,
      solutionMove: level.solutionMoves.first,
    );

    viewModel.onSquareTapped(wrongMove.to);

    final afterMiss = container.read(provider);
    expect(afterMiss.status, ObjectiveChallengeSessionStatus.playing);
    expect(afterMiss.playerMoveCount, 1);
    expect(afterMiss.lastMateAttemptMissed, isTrue);
    expect(afterMiss.missedMateAttemptCount, 1);
    expect(afterMiss.moveSoundCount, 0);
    expect(afterMiss.pieces.keys, initialPieces.keys);
    for (final entry in initialPieces.entries) {
      expect(afterMiss.pieces[entry.key]?.color, entry.value.color);
      expect(afterMiss.pieces[entry.key]?.kind, entry.value.kind);
    }

    viewModel.onSquareTapped('d3');
    viewModel.onSquareTapped('h7');

    final completed = container.read(provider);
    expect(completed.status, ObjectiveChallengeSessionStatus.completed);
    expect(completed.playerMoveCount, 2);
    expect(completed.earnedStars, 2);
    expect(completed.moveSoundCount, 1);
  });
}

({String from, String to}) _findLegalNonSolutionMove({
  required ObjectiveChallengeGameViewModel viewModel,
  required ObjectiveChallengeGameState Function() readState,
  required ChessPieceColor playerColor,
  required String solutionMove,
}) {
  final initialPieces = readState().pieces;

  for (final entry in initialPieces.entries) {
    if (entry.value.color != playerColor) {
      continue;
    }

    viewModel.onSquareTapped(entry.key);
    final state = readState();
    for (final target in state.legalTargets) {
      if ('${entry.key}$target' != solutionMove) {
        return (from: entry.key, to: target);
      }
    }
  }

  fail('Could not find a legal non-solution move for mate-in-one test.');
}
