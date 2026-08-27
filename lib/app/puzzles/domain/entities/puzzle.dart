class Puzzle {
  const Puzzle({
    required this.id,
    required this.objective,
    required this.fen,
    required this.sideToMove,
    required this.orientation,
    required this.moves,
    required this.playerMoveIndexes,
    required this.theme,
    required this.difficulty,
    required this.world,
    required this.chapter,
    required this.level,
    required this.hint,
  });

  final String id;
  final String objective;
  final String fen;
  final String sideToMove;
  final String orientation;
  final List<String> moves;
  final Set<int> playerMoveIndexes;
  final String theme;
  final int difficulty;
  final int world;
  final int chapter;
  final int level;
  final PuzzleHint hint;

  int get playerMoveCount => playerMoveIndexes.length;
}

class PuzzleHint {
  const PuzzleHint({required this.text, required this.from, required this.to});

  final String text;
  final String? from;
  final String? to;
}
