import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chess/chess.dart' as chess;

Future<void> main() async {
  final client = HttpClient()
    ..userAgent = 'ChessChalenges curriculum builder (educational project)'
    ..connectionTimeout = const Duration(seconds: 15);
  final selectedIds = <String>{};
  final worlds = <Map<String, Object?>>[];
  final output = File('assets/puzzles/curated_lichess_puzzles.json');

  if (output.existsSync()) {
    final existing =
        jsonDecode(output.readAsStringSync()) as Map<String, dynamic>;
    for (final value in existing['worlds'] as List) {
      final world = Map<String, Object?>.from(value as Map);
      worlds.add(world);
      for (final puzzle in world['puzzles']! as List) {
        selectedIds.add((puzzle as Map)['sourceId'] as String);
      }
    }
  }

  try {
    for (final plan in _plans) {
      if (worlds.any((world) => world['world'] == plan.world)) {
        continue;
      }

      final puzzles = <Map<String, Object?>>[];
      var attempts = 0;

      while (puzzles.length < 10 && attempts < plan.maxAttempts) {
        attempts++;
        final candidate = await _fetchCandidate(client, plan.angle, attempts);
        if (candidate == null || !selectedIds.add(candidate.id)) {
          continue;
        }

        final playerMoveCount = (candidate.solution.length + 1) ~/ 2;
        if (candidate.rating < plan.minRating ||
            candidate.rating > plan.maxRating ||
            playerMoveCount < plan.minPlayerMoves ||
            playerMoveCount > plan.maxPlayerMoves) {
          selectedIds.remove(candidate.id);
          continue;
        }

        puzzles.add({
          'sourceId': candidate.id,
          'fen': candidate.fen,
          'moves': candidate.solution,
          'rating': candidate.rating,
          'plays': candidate.plays,
          'themes': candidate.themes,
        });
        stdout.writeln(
          'World ${plan.world}: ${puzzles.length}/10 '
          '${candidate.id} (${candidate.rating}, $playerMoveCount moves)',
        );
        await Future<void>.delayed(const Duration(milliseconds: 120));
      }

      if (puzzles.length != 10) {
        throw StateError(
          'World ${plan.world} found only ${puzzles.length}/10 candidates '
          'after $attempts attempts.',
        );
      }

      worlds.add({
        'world': plan.world,
        'angle': plan.angle,
        'puzzles': puzzles,
      });
      _writeCurated(worlds);
    }
  } finally {
    client.close(force: true);
  }

  stdout.writeln('Saved ${selectedIds.length} curated puzzles.');
}

void _writeCurated(List<Map<String, Object?>> worlds) {
  final output = File('assets/puzzles/curated_lichess_puzzles.json');
  const encoder = JsonEncoder.withIndent('  ');
  output.writeAsStringSync('${encoder.convert({'worlds': worlds})}\n');
}

Future<_Candidate?> _fetchCandidate(
  HttpClient client,
  String angle,
  int nonce,
) async {
  try {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final uri = Uri.parse(
      'https://lichess.org/training/$angle?curriculum=$timestamp-$nonce',
    );
    final request = await client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'text/html');
    final response = await request.close().timeout(const Duration(seconds: 20));
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      return null;
    }

    final html = await utf8.decoder.bind(response).join();
    final match = RegExp(
      r'<script type="application/json" id="page-init-data">(.*?)</script>',
      dotAll: true,
    ).firstMatch(html);
    if (match == null) {
      return null;
    }

    final root = jsonDecode(match.group(1)!) as Map<String, dynamic>;
    final data = root['data'] as Map<String, dynamic>;
    final gameData = data['game'] as Map<String, dynamic>;
    final puzzleData = data['puzzle'] as Map<String, dynamic>;
    final game = chess.Chess();
    final pgn = gameData['pgn'] as String;
    if (!game.load_pgn(pgn)) {
      return null;
    }

    final solution = List<String>.from(puzzleData['solution'] as List);
    final validation = chess.Chess.fromFEN(game.fen);
    for (final move in solution) {
      if (!_applyUci(validation, move)) {
        return null;
      }
    }

    return _Candidate(
      id: puzzleData['id'] as String,
      fen: game.fen,
      solution: solution,
      rating: puzzleData['rating'] as int,
      plays: puzzleData['plays'] as int,
      themes: List<String>.from(puzzleData['themes'] as List),
    );
  } on Object catch (error) {
    stderr.writeln('Skipping $angle candidate: $error');
    return null;
  }
}

bool _applyUci(chess.Chess game, String uciMove) {
  final move = <String, String>{
    'from': uciMove.substring(0, 2),
    'to': uciMove.substring(2, 4),
  };
  if (uciMove.length == 5) {
    move['promotion'] = uciMove.substring(4);
  }
  return game.move(move);
}

final class _Candidate {
  const _Candidate({
    required this.id,
    required this.fen,
    required this.solution,
    required this.rating,
    required this.plays,
    required this.themes,
  });

  final String id;
  final String fen;
  final List<String> solution;
  final int rating;
  final int plays;
  final List<String> themes;
}

final class _WorldPlan {
  const _WorldPlan({
    required this.world,
    required this.angle,
    required this.minRating,
    required this.maxRating,
    required this.minPlayerMoves,
    required this.maxPlayerMoves,
  });

  final int world;
  final String angle;
  final int minRating;
  final int maxRating;
  final int minPlayerMoves;
  final int maxPlayerMoves;
  int get maxAttempts => 160;
}

const _plans = <_WorldPlan>[
  _WorldPlan(
    world: 2,
    angle: 'mateIn1',
    minRating: 0,
    maxRating: 1500,
    minPlayerMoves: 1,
    maxPlayerMoves: 1,
  ),
  _WorldPlan(
    world: 3,
    angle: 'hangingPiece',
    minRating: 0,
    maxRating: 1650,
    minPlayerMoves: 1,
    maxPlayerMoves: 2,
  ),
  _WorldPlan(
    world: 4,
    angle: 'fork',
    minRating: 1200,
    maxRating: 1800,
    minPlayerMoves: 2,
    maxPlayerMoves: 3,
  ),
  _WorldPlan(
    world: 5,
    angle: 'pin',
    minRating: 1300,
    maxRating: 1900,
    minPlayerMoves: 2,
    maxPlayerMoves: 3,
  ),
  _WorldPlan(
    world: 6,
    angle: 'discoveredAttack',
    minRating: 1400,
    maxRating: 2000,
    minPlayerMoves: 2,
    maxPlayerMoves: 4,
  ),
  _WorldPlan(
    world: 7,
    angle: 'defensiveMove',
    minRating: 1500,
    maxRating: 2100,
    minPlayerMoves: 2,
    maxPlayerMoves: 4,
  ),
  _WorldPlan(
    world: 8,
    angle: 'endgame',
    minRating: 1450,
    maxRating: 2000,
    minPlayerMoves: 2,
    maxPlayerMoves: 4,
  ),
  _WorldPlan(
    world: 9,
    angle: 'sacrifice',
    minRating: 1500,
    maxRating: 2200,
    minPlayerMoves: 3,
    maxPlayerMoves: 5,
  ),
  _WorldPlan(
    world: 10,
    angle: 'veryLong',
    minRating: 1600,
    maxRating: 3000,
    minPlayerMoves: 4,
    maxPlayerMoves: 7,
  ),
];
