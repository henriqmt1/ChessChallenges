import 'package:chess_chalenges/app/bot_game/data/isolate_bot_move_calculator.dart';
import 'package:chess_chalenges/app/bot_game/domain/bot_difficulty.dart';
import 'package:chess_chalenges/app/bot_game/domain/chess_bot_service.dart';
import 'package:chess_chalenges/shared/chess/chess_rules_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates a legal move without blocking the game contract', () async {
    final rules = ChessRulesService.standard()..applyMove(from: 'e2', to: 'e4');
    final calculator = const IsolateBotMoveCalculator();

    final move = await calculator.chooseMove(
      fen: rules.fen,
      difficulty: BotDifficulty.advanced,
    );

    expect(move, isNotNull);
    expect(rules.isLegalUciMove(move!.uci), isTrue);
  });

  test('ignores malformed isolate payloads', () {
    expect(
      chooseBotMoveUci(const {'fen': 'invalid', 'difficulty': 'unknown'}),
      isNull,
    );
  });
}
