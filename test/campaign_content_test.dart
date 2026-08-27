import 'dart:convert';
import 'dart:io';

import 'package:chess_chalenges/app/campaign/domain/entities/campaign_world.dart';
import 'package:chess_chalenges/shared/chess/chess_rules_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final payload =
      jsonDecode(File('assets/puzzles/campaign_v1.json').readAsStringSync())
          as Map<String, dynamic>;
  final puzzles = (payload['puzzles'] as List).cast<Map<String, dynamic>>();

  test('campaign contains 100 levels across 10 progressive worlds', () {
    expect(payload['schemaVersion'], 3);
    expect(payload['totalWorlds'], 10);
    expect(payload['levelsPerWorld'], 10);
    expect(puzzles, hasLength(100));

    for (var world = 1; world <= 10; world++) {
      expect(
        puzzles.where((puzzle) => puzzle['world'] == world),
        hasLength(10),
      );
    }

    final playerMoveCounts = puzzles
        .map((puzzle) => (puzzle['playerMoveIndexes'] as List).length)
        .toList(growable: false);

    expect(playerMoveCounts.take(10), everyElement(greaterThanOrEqualTo(4)));
    expect(playerMoveCounts.skip(10).take(10), everyElement(1));
    expect(
      playerMoveCounts.skip(20).take(10),
      everyElement(inInclusiveRange(1, 2)),
    );
    expect(
      playerMoveCounts.skip(30).take(50),
      everyElement(greaterThanOrEqualTo(2)),
    );
    expect(
      playerMoveCounts.skip(80).take(10),
      everyElement(greaterThanOrEqualTo(3)),
    );
    expect(playerMoveCounts.skip(90), everyElement(greaterThanOrEqualTo(4)));

    expect(
      puzzles.where((puzzle) => puzzle['difficultyBand'] == 'easy'),
      hasLength(30),
    );
    expect(
      puzzles.where((puzzle) => puzzle['difficultyBand'] == 'medium'),
      hasLength(40),
    );
    expect(
      puzzles.where((puzzle) => puzzle['difficultyBand'] == 'advanced'),
      hasLength(30),
    );
  });

  test('every phase is unique, explained, and backed by curated content', () {
    final signatures = puzzles
        .map(
          (puzzle) => '${puzzle['fen']}|${(puzzle['moves'] as List).join(' ')}',
        )
        .toSet();
    final positions = puzzles.map((puzzle) => puzzle['fen']).toSet();
    final sourcedPuzzles = puzzles.skip(10).toList(growable: false);
    final sourceIds = sourcedPuzzles
        .map((puzzle) => (puzzle['source'] as Map)['puzzleId'])
        .toSet();

    expect(signatures, hasLength(100));
    expect(positions, hasLength(100));
    expect(sourceIds, hasLength(90));
    for (final puzzle in puzzles) {
      expect((puzzle['objective'] as String).trim(), isNotEmpty);
      final hint = puzzle['hint'] as Map<String, dynamic>;
      expect((hint['text'] as String).trim(), isNotEmpty);
    }
    for (final puzzle in sourcedPuzzles) {
      final source = puzzle['source'] as Map<String, dynamic>;
      expect(source['provider'], 'lichess');
      expect(source['rating'], greaterThan(0));
      expect(source['themes'], isNotEmpty);
    }
  });

  test(
    'castling is introduced explicitly instead of appearing in level one',
    () {
      final fundamentals = puzzles.take(10).toList(growable: false);
      final firstLevelMoves = (fundamentals.first['moves'] as List)
          .cast<String>();
      final castlingTutorial = fundamentals.singleWhere(
        (puzzle) => (puzzle['objective'] as String).startsWith('Faça o roque:'),
      );

      expect(firstLevelMoves, isNot(contains('e1g1')));
      expect((castlingTutorial['moves'] as List).first, 'e1g1');
      expect(
        (castlingTutorial['hint'] as Map<String, dynamic>)['text'],
        contains('torre'),
      );
    },
  );

  test('every world has its own 3D emblem asset', () {
    expect(campaignWorlds, hasLength(10));
    expect(
      campaignWorlds.map((world) => world.emblemAsset).toSet(),
      hasLength(10),
    );

    for (final world in campaignWorlds) {
      expect(
        File(world.emblemAsset).existsSync(),
        isTrue,
        reason: 'World ${world.index} is missing ${world.emblemAsset}',
      );
    }
  });

  test('every campaign move is legal from its recorded position', () {
    for (final puzzle in puzzles) {
      final rules = ChessRulesService.fromFen(puzzle['fen'] as String);
      final moves = (puzzle['moves'] as List).cast<String>();

      for (final move in moves) {
        expect(
          rules.isLegalUciMove(move),
          isTrue,
          reason: '${puzzle['id']} has illegal move $move after ${rules.fen}',
        );
        expect(rules.applyUciMove(move), isTrue);
      }
    }
  });
}
