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
  static const _firstSourceIndex = 10;
  static const _levelCount = 30;

  Future<List<ObjectiveChallengeLevel>> loadLevels() async {
    final payload = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(payload) as Map<String, dynamic>;
    final puzzles = json['puzzles'] as List;
    final selectedPuzzles = puzzles
        .skip(_firstSourceIndex)
        .take(_levelCount)
        .cast<Map<String, dynamic>>()
        .toList(growable: false);

    return [
      for (final entry in selectedPuzzles.indexed)
        _levelFromJson(entry.$2, level: entry.$1 + 1),
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

    return ObjectiveChallengeLevel(
      id: json['id'] as String,
      level: level,
      sourceLevel: (json['globalLevel'] as int?) ?? level,
      objective: json['objective'] as String,
      fen: fen,
      playerColor: playerColor,
      solutionMoves: solutionMoves,
      playerMoveIndexes: playerMoveIndexes,
      minimumPlayerMoves: minimumPlayerMoves,
      maximumPlayerMoves: minimumPlayerMoves + 2,
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
