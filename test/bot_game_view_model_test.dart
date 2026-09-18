import 'dart:math';

import 'package:chess_chalenges/app/bot_game/domain/bot_difficulty.dart';
import 'package:chess_chalenges/app/bot_game/domain/bot_move_calculator.dart';
import 'package:chess_chalenges/app/bot_game/data/isolate_bot_move_calculator.dart';
import 'package:chess_chalenges/app/bot_game/domain/chess_bot_service.dart';
import 'package:chess_chalenges/app/bot_game/presentation/viewmodels/bot_game_view_model.dart';
import 'package:chess_chalenges/app/bot_game/presentation/viewmodels/bot_game_state.dart';
import 'package:chess_chalenges/shared/chess/chess_asset_paths.dart';
import 'package:chess_chalenges/shared/chess/chess_rules_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bot service returns legal moves for every difficulty', () {
    final service = ChessBotService(random: Random(1));

    for (final difficulty in BotDifficulty.values) {
      final rules = ChessRulesService.standard()
        ..applyMove(from: 'e2', to: 'e4');
      final legalUciMoves = rules.legalMoves().map((move) => move.uci).toSet();
      final move = service.chooseMove(rules, difficulty);

      expect(move, isNotNull);
      expect(legalUciMoves, contains(move!.uci));
    }
  });

  test(
    'bot avoids closing a threefold repetition when another move exists',
    () {
      final service = ChessBotService(random: Random(1));
      final rules = ChessRulesService.standard();

      for (final uciMove in const [
        'g1f3',
        'g8f6',
        'f3g1',
        'f6g8',
        'g1f3',
        'g8f6',
        'f3g1',
      ]) {
        expect(rules.applyUciMove(uciMove), isTrue);
      }

      final repeatMove = rules.legalMoves().singleWhere(
        (move) => move.uci == 'f6g8',
      );
      expect(rules.wouldMoveCauseThreefoldRepetition(repeatMove), isTrue);

      for (final difficulty in BotDifficulty.values) {
        final move = service.chooseMove(rules, difficulty);
        expect(move, isNotNull);
        expect(move!.uci, isNot('f6g8'));
      }
    },
  );

  test('player moves as white and bot replies as black', () async {
    final container = ProviderContainer(
      overrides: [
        botMoveCalculatorProvider.overrideWithValue(
          _DeterministicBotMoveCalculator(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      botGameViewModelProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final viewModel = container.read(botGameViewModelProvider.notifier);

    viewModel.startGame(BotDifficulty.beginner);
    var state = container.read(botGameViewModelProvider);
    expect(state.status, BotGameStatus.playing);
    expect(state.turn, ChessPieceColor.white);

    viewModel.onSquareTapped('e2');
    viewModel.onSquareTapped('e4');

    state = container.read(botGameViewModelProvider);
    expect(state.moveCount, 1);
    expect(state.turn, ChessPieceColor.black);
    expect(state.botThinking, isTrue);
    expect(state.canInteract, isFalse);
    expect(state.lastMove?.from, 'e2');
    expect(state.lastMove?.to, 'e4');

    await Future<void>.delayed(const Duration(milliseconds: 700));

    state = container.read(botGameViewModelProvider);
    expect(state.moveCount, 2);
    expect(state.turn, ChessPieceColor.white);
    expect(state.botThinking, isFalse);
    expect(state.lastMove?.from, 'e7');
    expect(state.lastMove?.to, 'e5');
    expect(state.pieces['e4']?.color, ChessPieceColor.white);
    expect(state.pieces['e5']?.color, ChessPieceColor.black);
  });

  test(
    'bot still replies after the provider is invalidated on page entry',
    () async {
      final container = ProviderContainer(
        overrides: [
          botMoveCalculatorProvider.overrideWithValue(
            _DeterministicBotMoveCalculator(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        botGameViewModelProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      container.invalidate(botGameViewModelProvider);

      final viewModel = container.read(botGameViewModelProvider.notifier);
      viewModel.startGame(BotDifficulty.beginner);
      viewModel.onSquareTapped('e2');
      viewModel.onSquareTapped('e4');

      var state = container.read(botGameViewModelProvider);
      expect(state.turn, ChessPieceColor.black);
      expect(state.botThinking, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 700));

      state = container.read(botGameViewModelProvider);
      expect(state.moveCount, 2);
      expect(state.turn, ChessPieceColor.white);
      expect(state.pieces['e5']?.color, ChessPieceColor.black);
    },
  );

  test('bot falls back to a legal move when the worker fails', () async {
    final container = ProviderContainer(
      overrides: [
        botMoveCalculatorProvider.overrideWithValue(
          _FailingBotMoveCalculator(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      botGameViewModelProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final viewModel = container.read(botGameViewModelProvider.notifier);
    viewModel.startGame(BotDifficulty.beginner);
    viewModel.onSquareTapped('e2');
    viewModel.onSquareTapped('e4');

    await Future<void>.delayed(const Duration(milliseconds: 700));

    final state = container.read(botGameViewModelProvider);
    expect(state.moveCount, 2);
    expect(state.botThinking, isFalse);
    expect(state.turn, ChessPieceColor.white);
  });
}

class _DeterministicBotMoveCalculator implements BotMoveCalculator {
  @override
  Future<ChessMove?> chooseMove({
    required String fen,
    required BotDifficulty difficulty,
  }) async {
    final rules = ChessRulesService.fromFen(fen);
    final legalMoves = rules.legalMoves();
    return legalMoves.firstWhere(
      (move) => move.uci == 'e7e5',
      orElse: () => legalMoves.first,
    );
  }
}

class _FailingBotMoveCalculator implements BotMoveCalculator {
  @override
  Future<ChessMove?> chooseMove({
    required String fen,
    required BotDifficulty difficulty,
  }) async {
    throw StateError('simulated worker failure');
  }
}
