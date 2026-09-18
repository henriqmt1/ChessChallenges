import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/chess/chess_asset_paths.dart';
import '../../../shared/chess/chess_rules_service.dart';
import '../domain/objective_challenge_level.dart';

final objectiveChallengeLevelsProvider =
    FutureProvider<List<ObjectiveChallengeLevel>>((ref) {
      return const ObjectiveChallengeDataSource().loadLevels();
    });

class ObjectiveChallengeDataSource {
  const ObjectiveChallengeDataSource();

  static const _assetPath = 'assets/puzzles/campaign_v1.json';
  // The objective mode has its own progression. It intentionally samples
  // different campaign themes instead of exposing ten consecutive mate-in-one
  // positions at the beginning of the map.
  static const _sourceGlobalLevels = <int>[
    11,
    12,
    13,
    21,
    22,
    23,
    24,
    25,
    31,
    32,
    33,
    34,
    35,
    36,
    41,
    42,
    43,
    44,
    45,
    50,
    51,
    53,
    55,
    58,
    61,
    63,
    65,
    71,
    82,
    91,
  ];

  Future<List<ObjectiveChallengeLevel>> loadLevels() async {
    final payload = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(payload) as Map<String, dynamic>;
    final puzzles = (json['puzzles'] as List).cast<Map<String, dynamic>>();
    final puzzlesByGlobalLevel = <int, Map<String, dynamic>>{
      for (final puzzle in puzzles) puzzle['globalLevel'] as int: puzzle,
    };

    return [
      for (final entry in _sourceGlobalLevels.indexed)
        _levelFromJson(puzzlesByGlobalLevel[entry.$2]!, level: entry.$1 + 1),
    ];
  }

  ObjectiveChallengeLevel _levelFromJson(
    Map<String, dynamic> json, {
    required int level,
  }) {
    final fen = json['fen'] as String;
    final playerColor = _colorFromJson(json['sideToMove'] as String);
    final solutionMoves = List<String>.from(json['moves'] as List);
    final playerMoveIndexes = Set<int>.from(json['playerMoveIndexes'] as List);
    final minimumPlayerMoves = playerMoveIndexes.length;
    final startRules = ChessRulesService.fromFen(fen);
    final startMaterialBalance = materialBalance(startRules, playerColor);

    final solvedRules = ChessRulesService.fromFen(fen);
    for (final move in solutionMoves) {
      solvedRules.applyUciMove(move);
    }

    final goal = _goalFromSolvedLine(
      solvedRules: solvedRules,
      playerColor: playerColor,
      startMaterialBalance: startMaterialBalance,
    );
    final isMateInOne =
        goal.type == ObjectiveChallengeGoalType.checkmate &&
        playerMoveIndexes.length == 1 &&
        solutionMoves.length == 1;

    return ObjectiveChallengeLevel(
      id: json['id'] as String,
      level: level,
      sourceLevel: (json['globalLevel'] as int?) ?? level,
      objective: json['objective'] as String,
      fen: fen,
      playerColor: playerColor,
      solutionMoves: solutionMoves,
      playerMoveIndexes: playerMoveIndexes,
      scoring: isMateInOne
          ? const ObjectiveChallengeScoring.attempts(oneStarLimit: 3)
          : ObjectiveChallengeScoring.moves(
              threeStarLimit: minimumPlayerMoves,
              twoStarLimit: minimumPlayerMoves + 1,
              oneStarLimit: minimumPlayerMoves + 2,
            ),
      startMaterialBalance: startMaterialBalance,
      goal: goal,
    );
  }

  ObjectiveChallengeGoal _goalFromSolvedLine({
    required ChessRulesService solvedRules,
    required ChessPieceColor playerColor,
    required int startMaterialBalance,
  }) {
    if (solvedRules.inCheckmate &&
        _winnerFromCheckmate(solvedRules) == playerColor) {
      return const ObjectiveChallengeGoal.checkmate();
    }

    final materialGain =
        materialBalance(solvedRules, playerColor) - startMaterialBalance;
    return ObjectiveChallengeGoal.materialGain(math.max(1, materialGain));
  }

  ChessPieceColor? _winnerFromCheckmate(ChessRulesService rules) {
    if (!rules.inCheckmate) {
      return null;
    }

    return rules.turnColor == ChessPieceColor.white
        ? ChessPieceColor.black
        : ChessPieceColor.white;
  }

  ChessPieceColor _colorFromJson(String value) {
    return switch (value.toLowerCase()) {
      'b' || 'black' => ChessPieceColor.black,
      _ => ChessPieceColor.white,
    };
  }
}

int materialBalance(ChessRulesService rules, ChessPieceColor perspective) {
  var score = 0;

  for (final piece in rules.pieces.values) {
    final value = _pieceValue(piece.kind);
    score += piece.color == perspective ? value : -value;
  }

  return score;
}

int _pieceValue(ChessPieceKind kind) {
  return switch (kind) {
    ChessPieceKind.pawn => 1,
    ChessPieceKind.knight => 3,
    ChessPieceKind.bishop => 3,
    ChessPieceKind.rook => 5,
    ChessPieceKind.queen => 9,
    ChessPieceKind.king => 0,
  };
}
