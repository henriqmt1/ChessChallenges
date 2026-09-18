import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/chess/chess_rules_service.dart';
import '../domain/bot_difficulty.dart';
import '../domain/bot_move_calculator.dart';
import '../domain/chess_bot_service.dart';

final botMoveCalculatorProvider = Provider<BotMoveCalculator>((ref) {
  return const IsolateBotMoveCalculator();
});

/// Runs the synchronous chess heuristic in a background isolate.
final class IsolateBotMoveCalculator implements BotMoveCalculator {
  const IsolateBotMoveCalculator();

  @override
  Future<ChessMove?> chooseMove({
    required String fen,
    required BotDifficulty difficulty,
  }) async {
    final uciMove = await compute(chooseBotMoveUci, <String, String>{
      'fen': fen,
      'difficulty': difficulty.name,
    });

    if (uciMove == null) {
      return null;
    }

    final parsed = UciMove.parse(uciMove);
    return ChessMove(
      from: parsed.from,
      to: parsed.to,
      promotion: parsed.promotion,
    );
  }
}
