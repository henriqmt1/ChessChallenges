import '../../domain/entities/puzzle.dart';

class PuzzleModel extends Puzzle {
  PuzzleModel({
    required super.id,
    required super.objective,
    required super.fen,
    required super.sideToMove,
    required super.orientation,
    required super.moves,
    required super.playerMoveIndexes,
    required super.theme,
    required super.difficulty,
    required super.world,
    required super.chapter,
    required super.level,
    required super.hint,
  });

  factory PuzzleModel.fromJson(Map<String, dynamic> json) {
    final hintJson = json['hint'] as Map<String, dynamic>? ?? {};

    return PuzzleModel(
      id: json['id'] as String,
      objective: json['objective'] as String,
      fen: json['fen'] as String,
      sideToMove: json['sideToMove'] as String,
      orientation: json['orientation'] as String,
      moves: List<String>.from(json['moves'] as List),
      playerMoveIndexes: Set<int>.from(json['playerMoveIndexes'] as List),
      theme: json['theme'] as String,
      difficulty: json['difficulty'] as int,
      world: json['world'] as int,
      chapter: json['chapter'] as int,
      level: json['level'] as int,
      hint: PuzzleHint(
        text: hintJson['text'] as String,
        from: hintJson['from'] as String?,
        to: hintJson['to'] as String?,
      ),
    );
  }
}
