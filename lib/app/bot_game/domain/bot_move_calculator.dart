import '../../../shared/chess/chess_rules_service.dart';
import 'bot_difficulty.dart';

/// Abstraction used by game controllers so the UI never owns bot computation.
abstract interface class BotMoveCalculator {
  Future<ChessMove?> chooseMove({
    required String fen,
    required BotDifficulty difficulty,
  });
}
