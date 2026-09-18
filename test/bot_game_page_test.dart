import 'package:chess_chalenges/app/bot_game/domain/bot_difficulty.dart';
import 'package:chess_chalenges/app/bot_game/domain/bot_move_calculator.dart';
import 'package:chess_chalenges/app/bot_game/data/isolate_bot_move_calculator.dart';
import 'package:chess_chalenges/app/bot_game/presentation/pages/bot_game_page.dart';
import 'package:chess_chalenges/shared/chess/chess_rules_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/localized_test_app.dart';

void main() {
  testWidgets('selects beginner and starts a bot match', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          botMoveCalculatorProvider.overrideWithValue(
            _DeterministicBotMoveCalculator(),
          ),
        ],
        child: localizedTestApp(home: const BotGamePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Escolha o nível do bot'), findsOneWidget);
    expect(find.text('Iniciante'), findsOneWidget);
    expect(find.text('Intermediário'), findsOneWidget);
    expect(find.text('Avançado'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('bot-difficulty-beginner')));
    await tester.pumpAndSettle();

    expect(find.text('Sua vez'), findsOneWidget);
    expect(find.byKey(const ValueKey('chess-square-e2')), findsOneWidget);
  });

  testWidgets('canceling exit preserves the active bot game', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          botMoveCalculatorProvider.overrideWithValue(
            _DeterministicBotMoveCalculator(),
          ),
        ],
        child: localizedTestApp(home: const BotGamePage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bot-difficulty-beginner')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('chess-square-e2')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('chess-square-e4')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bot-game-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('Sair da partida?'), findsOneWidget);
    await tester.tap(find.text('Continuar jogando'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('chess-square-e4')), findsOneWidget);
    expect(find.text('Escolha o nível do bot'), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair da partida'));
    await tester.pumpAndSettle();
    expect(find.text('Escolha o nível do bot'), findsOneWidget);
  });

  testWidgets('back returns from a bot match to difficulty selection', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          botMoveCalculatorProvider.overrideWithValue(
            _DeterministicBotMoveCalculator(),
          ),
        ],
        child: localizedTestApp(home: const BotGamePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('bot-difficulty-beginner')));
    await tester.pumpAndSettle();
    expect(find.text('Sua vez'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('bot-game-back-button')));
    await tester.pumpAndSettle();

    expect(find.text('Escolha o nível do bot'), findsOneWidget);
    expect(find.text('Iniciante'), findsOneWidget);
    expect(find.byKey(const ValueKey('chess-square-e2')), findsNothing);
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
