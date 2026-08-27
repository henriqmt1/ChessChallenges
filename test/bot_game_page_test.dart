import 'package:chess_chalenges/app/bot_game/domain/bot_difficulty.dart';
import 'package:chess_chalenges/app/bot_game/domain/chess_bot_service.dart';
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
          chessBotServiceProvider.overrideWithValue(_DeterministicBotService()),
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
          chessBotServiceProvider.overrideWithValue(_DeterministicBotService()),
        ],
        child: localizedTestApp(home: const BotGamePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('bot-difficulty-beginner')));
    await tester.pumpAndSettle();
    expect(find.text('Sua vez'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Escolha o nível do bot'), findsOneWidget);
    expect(find.text('Iniciante'), findsOneWidget);
    expect(find.byKey(const ValueKey('chess-square-e2')), findsNothing);
  });
}

class _DeterministicBotService extends ChessBotService {
  @override
  ChessMove? chooseMove(ChessRulesService rules, BotDifficulty difficulty) {
    final legalMoves = rules.legalMoves();
    return legalMoves.firstWhere(
      (move) => move.uci == 'e7e5',
      orElse: () => legalMoves.first,
    );
  }
}
