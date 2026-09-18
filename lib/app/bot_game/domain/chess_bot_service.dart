import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/chess/board_piece.dart';
import '../../../shared/chess/chess_asset_paths.dart';
import '../../../shared/chess/chess_rules_service.dart';
import 'bot_difficulty.dart';

final chessBotServiceProvider = Provider<ChessBotService>((ref) {
  return ChessBotService();
});

/// Isolate entry point. Keep the payload limited to simple values so it can be
/// transferred safely between isolates on every supported platform.
String? chooseBotMoveUci(Map<String, String> payload) {
  final fen = payload['fen'];
  final difficultyName = payload['difficulty'];
  if (fen == null || difficultyName == null) {
    return null;
  }

  final difficulty = switch (difficultyName) {
    'beginner' => BotDifficulty.beginner,
    'intermediate' => BotDifficulty.intermediate,
    'advanced' => BotDifficulty.advanced,
    _ => null,
  };
  if (difficulty == null) {
    return null;
  }

  final rules = ChessRulesService.fromFen(fen);
  return ChessBotService().chooseMove(rules, difficulty)?.uci;
}

class ChessBotService {
  ChessBotService({Random? random}) : _random = random ?? Random();

  final Random _random;

  ChessMove? chooseMove(ChessRulesService rules, BotDifficulty difficulty) {
    final legalMoves = _avoidThreefoldRepetitionWhenPossible(
      rules,
      rules.legalMoves(),
    );
    if (legalMoves.isEmpty) {
      return null;
    }

    return switch (difficulty) {
      BotDifficulty.beginner => _chooseBeginnerMove(rules, legalMoves),
      BotDifficulty.intermediate => _chooseIntermediateMove(rules, legalMoves),
      BotDifficulty.advanced => _chooseAdvancedMove(rules, legalMoves),
    };
  }

  List<ChessMove> _avoidThreefoldRepetitionWhenPossible(
    ChessRulesService rules,
    List<ChessMove> legalMoves,
  ) {
    if (legalMoves.length <= 1) {
      return legalMoves;
    }

    final nonRepeatingMoves = legalMoves
        .where((move) => !rules.wouldMoveCauseThreefoldRepetition(move))
        .toList(growable: false);

    return nonRepeatingMoves.isEmpty ? legalMoves : nonRepeatingMoves;
  }

  ChessMove _chooseBeginnerMove(
    ChessRulesService rules,
    List<ChessMove> legalMoves,
  ) {
    if (_random.nextDouble() < 0.68) {
      return _randomFrom(legalMoves);
    }

    final rankedMoves = _rankTacticalMoves(
      rules,
      legalMoves,
      perspective: rules.turnColor,
      noise: 80,
    );
    return _randomFrom(rankedMoves.take(4).map((entry) => entry.move).toList());
  }

  ChessMove _chooseIntermediateMove(
    ChessRulesService rules,
    List<ChessMove> legalMoves,
  ) {
    final rankedMoves = _rankTacticalMoves(
      rules,
      legalMoves,
      perspective: rules.turnColor,
      noise: 32,
    );
    final topMoves = rankedMoves.take(3).map((entry) => entry.move).toList();

    return _random.nextDouble() < 0.78 ? topMoves.first : _randomFrom(topMoves);
  }

  ChessMove _chooseAdvancedMove(
    ChessRulesService rules,
    List<ChessMove> legalMoves,
  ) {
    final perspective = rules.turnColor;
    final orderedRootMoves = _orderedForSearch(
      rules,
      legalMoves,
      perspective: perspective,
    );
    var bestScore = _negativeInfinity;
    final bestMoves = <ChessMove>[];

    for (final move in orderedRootMoves.take(_maxRootMoves)) {
      final nextRules = ChessRulesService.fromFen(rules.fen);
      nextRules.applyChessMove(move);

      final score = _minimax(
        nextRules,
        depth: _advancedResponseDepth,
        alpha: _negativeInfinity,
        beta: _positiveInfinity,
        perspective: perspective,
      );

      if (score > bestScore) {
        bestScore = score;
        bestMoves
          ..clear()
          ..add(move);
      } else if (score == bestScore) {
        bestMoves.add(move);
      }
    }

    return _randomFrom(bestMoves);
  }

  int _minimax(
    ChessRulesService rules, {
    required int depth,
    required int alpha,
    required int beta,
    required ChessPieceColor perspective,
  }) {
    if (depth == 0 || rules.gameOver) {
      return _evaluatePosition(rules, perspective);
    }

    final legalMoves = rules.legalMoves();
    if (legalMoves.isEmpty) {
      return _evaluatePosition(rules, perspective);
    }

    final maximizing = rules.turnColor == perspective;
    var bestScore = maximizing ? _negativeInfinity : _positiveInfinity;
    var currentAlpha = alpha;
    var currentBeta = beta;

    final orderedMoves = _orderedForSearch(
      rules,
      legalMoves,
      perspective: perspective,
    ).take(_maxSearchMoves);

    for (final move in orderedMoves) {
      final nextRules = ChessRulesService.fromFen(rules.fen);
      nextRules.applyChessMove(move);

      final score = _minimax(
        nextRules,
        depth: depth - 1,
        alpha: currentAlpha,
        beta: currentBeta,
        perspective: perspective,
      );

      if (maximizing) {
        bestScore = max(bestScore, score);
        currentAlpha = max(currentAlpha, bestScore);
      } else {
        bestScore = min(bestScore, score);
        currentBeta = min(currentBeta, bestScore);
      }

      if (currentBeta <= currentAlpha) {
        break;
      }
    }

    return bestScore;
  }

  List<_ScoredMove> _rankTacticalMoves(
    ChessRulesService rules,
    List<ChessMove> legalMoves, {
    required ChessPieceColor perspective,
    required int noise,
  }) {
    final scoredMoves = legalMoves
        .map(
          (move) => _ScoredMove(
            move: move,
            score:
                _quickMoveScore(rules, move, perspective: perspective) +
                (noise > 0 ? _random.nextInt(noise) : 0),
          ),
        )
        .toList();

    scoredMoves.sort((a, b) => b.score.compareTo(a.score));
    return scoredMoves;
  }

  List<ChessMove> _orderedForSearch(
    ChessRulesService rules,
    List<ChessMove> legalMoves, {
    required ChessPieceColor perspective,
  }) {
    final scoredMoves = _rankTacticalMoves(
      rules,
      legalMoves,
      perspective: perspective,
      noise: 0,
    );

    return scoredMoves.map((entry) => entry.move).toList(growable: false);
  }

  int _quickMoveScore(
    ChessRulesService rules,
    ChessMove move, {
    required ChessPieceColor perspective,
  }) {
    final movingPiece = rules.pieceAt(move.from);
    final capturedPiece = rules.pieceAt(move.to);
    final nextRules = ChessRulesService.fromFen(rules.fen)
      ..applyChessMove(move);

    if (nextRules.inCheckmate) {
      return _mateScore;
    }

    var score = 0;

    if (move.isCapture) {
      final capturedValue = capturedPiece == null
          ? _pieceValues[ChessPieceKind.pawn]!
          : _pieceValues[capturedPiece.kind]!;
      final attackerValue = movingPiece == null
          ? 0
          : _pieceValues[movingPiece.kind]!;
      score += capturedValue * 10 - attackerValue;
    }

    if (move.isPromotion) {
      score += _pieceValues[ChessPieceKind.queen]!;
    }

    if (nextRules.inCheck) {
      score += 220;
    }

    if (move.isCastle) {
      score += 95;
    }

    score += _developmentScore(movingPiece, move);
    score += _centerScore(move.to);
    score -= _hangingPenalty(nextRules, move);

    final evaluation = _evaluatePosition(nextRules, perspective);
    score += evaluation ~/ 8;

    return score;
  }

  int _evaluatePosition(ChessRulesService rules, ChessPieceColor perspective) {
    if (rules.inCheckmate) {
      return rules.turnColor == perspective ? -_mateScore : _mateScore;
    }

    if (rules.inDraw) {
      return 0;
    }

    var score = 0;
    final pieces = rules.pieces;

    for (final entry in pieces.entries) {
      final piece = entry.value;
      final material = _pieceValues[piece.kind]!;
      final positional = _pieceSquareScore(piece, entry.key);
      final signedScore = material + positional;
      score += piece.color == perspective ? signedScore : -signedScore;
    }

    final mobility = rules.legalMoves().length * 2;
    score += rules.turnColor == perspective ? mobility : -mobility;

    if (rules.inCheck) {
      score += rules.turnColor == perspective ? -36 : 36;
    }

    return score;
  }

  int _hangingPenalty(ChessRulesService rulesAfterMove, ChessMove move) {
    final movedPiece = rulesAfterMove.pieceAt(move.to);
    if (movedPiece == null || movedPiece.kind == ChessPieceKind.king) {
      return 0;
    }

    final canBeCaptured = rulesAfterMove.legalMoves().any(
      (reply) => reply.to == move.to && reply.isCapture,
    );

    if (!canBeCaptured) {
      return 0;
    }

    return (_pieceValues[movedPiece.kind]! * 0.56).round();
  }

  int _developmentScore(BoardPiece? piece, ChessMove move) {
    if (piece == null) {
      return 0;
    }

    if (piece.kind == ChessPieceKind.knight ||
        piece.kind == ChessPieceKind.bishop) {
      final startingSquares = piece.color == ChessPieceColor.white
          ? const {'b1', 'c1', 'f1', 'g1'}
          : const {'b8', 'c8', 'f8', 'g8'};

      if (startingSquares.contains(move.from)) {
        return 55;
      }
    }

    if (piece.kind == ChessPieceKind.pawn &&
        (move.to == 'd4' ||
            move.to == 'e4' ||
            move.to == 'd5' ||
            move.to == 'e5')) {
      return 36;
    }

    return 0;
  }

  int _centerScore(String square) {
    return switch (square) {
      'd4' || 'e4' || 'd5' || 'e5' => 36,
      'c3' ||
      'd3' ||
      'e3' ||
      'f3' ||
      'c4' ||
      'f4' ||
      'c5' ||
      'f5' ||
      'c6' ||
      'd6' ||
      'e6' ||
      'f6' => 18,
      _ => 0,
    };
  }

  int _pieceSquareScore(BoardPiece piece, String square) {
    final fileIndex = square.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.parse(square.substring(1));
    final distanceFromCenterFile = (fileIndex - 3.5).abs();
    final distanceFromCenterRank = (rank - 4.5).abs();
    final centerBonus =
        ((7 - distanceFromCenterFile - distanceFromCenterRank) * 4).round();

    return switch (piece.kind) {
      ChessPieceKind.pawn =>
        centerBonus +
            (piece.color == ChessPieceColor.white ? rank : 9 - rank) * 3,
      ChessPieceKind.knight || ChessPieceKind.bishop => centerBonus * 2,
      ChessPieceKind.rook => centerBonus ~/ 2,
      ChessPieceKind.queen => centerBonus,
      ChessPieceKind.king => 0,
    };
  }

  ChessMove _randomFrom(List<ChessMove> moves) {
    return moves[_random.nextInt(moves.length)];
  }

  static const _mateScore = 100000;
  static const _positiveInfinity = 1000000000;
  static const _negativeInfinity = -1000000000;
  static const _advancedResponseDepth = 1;
  static const _maxRootMoves = 20;
  static const _maxSearchMoves = 18;

  static const _pieceValues = {
    ChessPieceKind.pawn: 100,
    ChessPieceKind.knight: 320,
    ChessPieceKind.bishop: 330,
    ChessPieceKind.rook: 500,
    ChessPieceKind.queen: 900,
    ChessPieceKind.king: 0,
  };
}

class _ScoredMove {
  const _ScoredMove({required this.move, required this.score});

  final ChessMove move;
  final int score;
}
