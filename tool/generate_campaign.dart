import 'dart:convert';
import 'dart:io';

import 'package:chess/chess.dart' as chess;

void main() {
  final curated = _loadCuratedPuzzles();
  final puzzles = <Map<String, Object?>>[];
  final worldEntries = <Map<String, Object?>>[];
  final signatures = <String>{};

  for (final world in _worlds) {
    final sourcePuzzles = world.index == 1
        ? _openingPuzzles()
        : curated[world.index] ?? const <_SourcePuzzle>[];
    if (sourcePuzzles.length != 10) {
      throw StateError(
        'World ${world.index} must contain 10 curated puzzles, '
        'found ${sourcePuzzles.length}.',
      );
    }

    final worldPuzzles = <Map<String, Object?>>[];
    for (var localIndex = 0; localIndex < sourcePuzzles.length; localIndex++) {
      final source = sourcePuzzles[localIndex];
      final globalIndex = ((world.index - 1) * 10) + localIndex;
      final id = 'level-${(globalIndex + 1).toString().padLeft(3, '0')}';
      final playerMoveIndexes = <int>[
        for (var moveIndex = 0; moveIndex < source.moves.length; moveIndex += 2)
          moveIndex,
      ];

      _validatePuzzle(id: id, fen: source.fen, moves: source.moves);
      _validateCurriculum(
        id: id,
        world: world.index,
        playerMoveCount: playerMoveIndexes.length,
      );

      final signature = '${source.fen}|${source.moves.join(' ')}';
      if (!signatures.add(signature)) {
        throw StateError('$id duplicates another campaign position and line.');
      }

      final firstPlayerMove = source.moves.first;
      final entry = <String, Object?>{
        'id': id,
        'title': 'Fase ${localIndex + 1}',
        'objective': source.objective ?? world.objective,
        'fen': source.fen,
        'sideToMove': _sideToMove(source.fen),
        'orientation': _sideToMove(source.fen) == 'w' ? 'white' : 'black',
        'moves': source.moves,
        'playerMoveIndexes': playerMoveIndexes,
        'theme': world.theme,
        'difficulty': world.index,
        'difficultyBand': _difficultyBand(world.index),
        'world': world.index,
        'chapter': 1,
        'level': localIndex + 1,
        'globalLevel': globalIndex + 1,
        'hint': {
          'text': source.hint ?? world.hint,
          'from': firstPlayerMove.substring(0, 2),
          'to': firstPlayerMove.substring(2, 4),
        },
        if (source.sourceId != null)
          'source': {
            'provider': 'lichess',
            'puzzleId': source.sourceId,
            'rating': source.rating,
            'plays': source.plays,
            'themes': source.themes,
          },
      };

      puzzles.add(entry);
      worldPuzzles.add(entry);
    }

    worldEntries.add({
      'index': world.index,
      'title': world.title,
      'theme': world.theme,
      'difficultyBand': _difficultyBand(world.index),
      'firstGlobalLevel': ((world.index - 1) * 10) + 1,
      'lastGlobalLevel': world.index * 10,
      'playerMoveCountRange': {
        'min': worldPuzzles
            .map((entry) => (entry['playerMoveIndexes'] as List).length)
            .reduce(_min),
        'max': worldPuzzles
            .map((entry) => (entry['playerMoveIndexes'] as List).length)
            .reduce(_max),
      },
    });
  }

  final campaign = <String, Object?>{
    'schemaVersion': 3,
    'id': 'chess_chalenges_campaign_v1',
    'moveFormat': 'uci',
    'totalWorlds': _worlds.length,
    'levelsPerWorld': 10,
    'totalLevels': puzzles.length,
    'worlds': worldEntries,
    'puzzles': puzzles,
  };

  final output = File('assets/puzzles/campaign_v1.json');
  const encoder = JsonEncoder.withIndent('  ');
  output.writeAsStringSync('${encoder.convert(campaign)}\n');
  stdout.writeln(
    'Generated and validated ${puzzles.length} unique curriculum levels at '
    '${output.path}.',
  );
}

Map<int, List<_SourcePuzzle>> _loadCuratedPuzzles() {
  final file = File('assets/puzzles/curated_lichess_puzzles.json');
  if (!file.existsSync()) {
    throw StateError(
      '${file.path} is missing. Run '
      '`dart run tool/fetch_curated_lichess_puzzles.dart` first.',
    );
  }

  final root = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final result = <int, List<_SourcePuzzle>>{};
  for (final rawWorld in root['worlds'] as List) {
    final world = rawWorld as Map<String, dynamic>;
    final worldNumber = world['world'] as int;
    result[worldNumber] = [
      for (final rawPuzzle in world['puzzles'] as List)
        _SourcePuzzle.fromLichess(rawPuzzle as Map<String, dynamic>),
    ];
  }
  return result;
}

List<_SourcePuzzle> _openingPuzzles() {
  return [
    _opening(
      moves: const ['e2e4', 'e7e5', 'g1f3', 'b8c6', 'f1c4', 'g8f6', 'd2d3'],
      objective: 'Domine o centro e desenvolva as peças menores com propósito.',
      hint: 'Comece ocupando o centro com o peão do rei.',
    ),
    _opening(
      setupMoves: const ['d2d4', 'd7d5'],
      moves: const [
        'c2c4',
        'e7e6',
        'b1c3',
        'g8f6',
        'c1g5',
        'f8e7',
        'e2e3',
        'b8d7',
        'g1f3',
      ],
      objective:
          'Pressione o centro e desenvolva sem mover a mesma peça duas vezes.',
      hint: 'Abra espaço com o peão da dama antes de desenvolver.',
    ),
    _opening(
      setupMoves: const ['e2e4', 'c7c5'],
      moves: const [
        'g1f3',
        'd7d6',
        'd2d4',
        'c5d4',
        'f3d4',
        'g8f6',
        'b1c3',
        'a7a6',
        'c1e3',
      ],
      objective:
          'Abra o centro, recapture com uma peça e complete o desenvolvimento.',
      hint: 'O peão do rei disputa imediatamente as casas centrais.',
    ),
    _opening(
      setupMoves: const ['e2e4', 'e7e6', 'd2d4', 'd7d5'],
      moves: const ['b1c3', 'g8f6', 'e4e5', 'f6d7', 'f2f4', 'c7c5', 'g1f3'],
      objective: 'Ganhe espaço e sustente a cadeia de peões antes de atacar.',
      hint: 'Construa primeiro a dupla de peões no centro.',
    ),
    _opening(
      setupMoves: const ['e2e4', 'c7c6', 'd2d4', 'd7d5'],
      moves: const ['b1c3', 'd5e4', 'c3e4', 'c8f5', 'e4g3', 'f5g6', 'h2h4'],
      objective:
          'Recupere o peão central desenvolvendo e ganhe espaço na ala do rei.',
      hint: 'Ocupe o centro antes de reagir à troca de peões.',
    ),
    _opening(
      setupMoves: const ['c2c4', 'e7e5'],
      moves: const [
        'b1c3',
        'g8f6',
        'g2g3',
        'd7d5',
        'c4d5',
        'f6d5',
        'f1g2',
        'd5b6',
        'g1f3',
      ],
      objective:
          'Controle o centro pelo flanco e desenvolva o bispo na diagonal longa.',
      hint: 'Use o peão da coluna c para atacar o centro à distância.',
    ),
    _opening(
      setupMoves: const ['e2e4'],
      moves: const [
        'c7c5',
        'g1f3',
        'd7d6',
        'd2d4',
        'c5d4',
        'f3d4',
        'g8f6',
        'b1c3',
        'a7a6',
      ],
      objective: 'Com as pretas, ataque o centro e desenvolva com tempo.',
      hint: 'Responda ao peão do rei contestando a casa d4.',
    ),
    _opening(
      setupMoves: const ['d2d4'],
      moves: const [
        'g8f6',
        'c2c4',
        'e7e6',
        'b1c3',
        'f8b4',
        'e2e3',
        'd7d5',
        'f1d3',
        'c7c5',
      ],
      objective:
          'Desenvolva com uma cravada, prepare o roque e pressione o centro.',
      hint: 'Desenvolva o cavalo antes de comprometer os peões centrais.',
    ),
    _opening(
      setupMoves: const ['e2e4', 'e7e5', 'g1f3'],
      moves: const [
        'b8c6',
        'f1c4',
        'g8f6',
        'd2d3',
        'f8c5',
        'c2c3',
        'd7d6',
        'b2b4',
        'c5b6',
      ],
      objective:
          'Iguale o desenvolvimento, proteja o rei e só então prepare o centro.',
      hint: 'Defenda o peão de e5 desenvolvendo o cavalo.',
    ),
    _opening(
      setupMoves: const [
        'e2e4',
        'e7e5',
        'g1f3',
        'b8c6',
        'f1c4',
        'g8f6',
        'd2d3',
        'f8c5',
      ],
      moves: const ['e1g1', 'd7d6', 'c2c3', 'a7a6', 'b1d2', 'c8g4', 'h2h3'],
      objective:
          'Faça o roque: o rei anda duas casas e a torre vai para o outro lado dele.',
      hint: 'Mova o rei de e1 para g1; a torre irá automaticamente para f1.',
    ),
  ];
}

_SourcePuzzle _opening({
  List<String> setupMoves = const [],
  required List<String> moves,
  required String objective,
  required String hint,
}) {
  final game = chess.Chess();
  for (final move in setupMoves) {
    if (!_applyUci(game, move)) {
      throw StateError('Invalid opening setup move $move after ${game.fen}.');
    }
  }
  return _SourcePuzzle(
    fen: game.fen,
    moves: moves,
    objective: objective,
    hint: hint,
  );
}

void _validateCurriculum({
  required String id,
  required int world,
  required int playerMoveCount,
}) {
  final minimum = switch (world) {
    1 => 4,
    2 || 3 => 1,
    4 || 5 || 6 || 7 || 8 => 2,
    9 => 3,
    10 => 4,
    _ => 1,
  };
  if (playerMoveCount < minimum) {
    throw StateError(
      '$id has $playerMoveCount player moves; world $world requires $minimum.',
    );
  }
}

void _validatePuzzle({
  required String id,
  required String fen,
  required List<String> moves,
}) {
  if (moves.isEmpty || moves.length.isEven) {
    throw StateError('$id must end after a player move.');
  }

  final game = chess.Chess.fromFEN(fen);
  for (final uciMove in moves) {
    if (!_applyUci(game, uciMove)) {
      throw StateError('$id contains illegal move $uciMove after ${game.fen}.');
    }
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

String _sideToMove(String fen) => fen.split(' ')[1];

String _difficultyBand(int world) {
  if (world <= 3) return 'easy';
  if (world <= 7) return 'medium';
  return 'advanced';
}

int _min(int left, int right) => left < right ? left : right;
int _max(int left, int right) => left > right ? left : right;

final class _WorldDefinition {
  const _WorldDefinition({
    required this.index,
    required this.title,
    required this.theme,
    required this.objective,
    required this.hint,
  });

  final int index;
  final String title;
  final String theme;
  final String objective;
  final String hint;
}

final class _SourcePuzzle {
  const _SourcePuzzle({
    required this.fen,
    required this.moves,
    this.objective,
    this.hint,
    this.sourceId,
    this.rating,
    this.plays,
    this.themes = const [],
  });

  factory _SourcePuzzle.fromLichess(Map<String, dynamic> json) {
    return _SourcePuzzle(
      fen: json['fen'] as String,
      moves: List<String>.from(json['moves'] as List),
      sourceId: json['sourceId'] as String,
      rating: json['rating'] as int,
      plays: json['plays'] as int,
      themes: List<String>.from(json['themes'] as List),
    );
  }

  final String fen;
  final List<String> moves;
  final String? objective;
  final String? hint;
  final String? sourceId;
  final int? rating;
  final int? plays;
  final List<String> themes;
}

const _worlds = <_WorldDefinition>[
  _WorldDefinition(
    index: 1,
    title: 'Fundamentos em jogo',
    theme: 'fundamentals',
    objective: 'Desenvolva as peças com propósito e proteja o rei.',
    hint: 'Procure uma jogada que controle o centro e desenvolva uma peça.',
  ),
  _WorldDefinition(
    index: 2,
    title: 'Mate em 1',
    theme: 'mateIn1',
    objective: 'Dê xeque-mate em um lance.',
    hint: 'Cheque todas as fugas do rei antes de jogar.',
  ),
  _WorldDefinition(
    index: 3,
    title: 'Peças sem defesa',
    theme: 'material',
    objective: 'Aproveite a peça solta e conquiste vantagem material.',
    hint: 'Compare atacantes e defensores antes de capturar.',
  ),
  _WorldDefinition(
    index: 4,
    title: 'Garfos',
    theme: 'fork',
    objective: 'Use uma ameaça dupla e converta o ganho de material.',
    hint: 'Procure uma casa de onde uma peça ataque dois alvos.',
  ),
  _WorldDefinition(
    index: 5,
    title: 'Cravadas',
    theme: 'pin',
    objective: 'Explore uma peça cravada para ganhar material ou atacar o rei.',
    hint: 'Observe peças alinhadas com o rei ou com uma peça mais valiosa.',
  ),
  _WorldDefinition(
    index: 6,
    title: 'Ataques descobertos',
    theme: 'discoveredAttack',
    objective: 'Libere uma linha de ataque e calcule a continuação forçada.',
    hint: 'Uma peça está bloqueando a ação de outra peça sua.',
  ),
  _WorldDefinition(
    index: 7,
    title: 'Defesa e contra-ataque',
    theme: 'defense',
    objective: 'Encontre a defesa precisa e transforme-a em contra-ataque.',
    hint: 'Considere cheques, capturas e ameaças do adversário primeiro.',
  ),
  _WorldDefinition(
    index: 8,
    title: 'Finais essenciais',
    theme: 'endgame',
    objective: 'Calcule o final com precisão e melhore a atividade das peças.',
    hint: 'No final, cada tempo e cada casa do rei importam.',
  ),
  _WorldDefinition(
    index: 9,
    title: 'Sacrifícios e combinações',
    theme: 'combination',
    objective:
        'Calcule o sacrifício até recuperar o material ou decidir a partida.',
    hint:
        'Não pare na primeira captura: veja a resposta forçada e a continuação.',
  ),
  _WorldDefinition(
    index: 10,
    title: 'Cálculo avançado',
    theme: 'mastery',
    objective: 'Encontre e execute toda a variante forçada.',
    hint: 'Calcule cheques, capturas e ameaças até a posição se estabilizar.',
  ),
];
