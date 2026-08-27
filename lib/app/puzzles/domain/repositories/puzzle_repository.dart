import '../entities/puzzle.dart';

abstract interface class PuzzleRepository {
  Future<List<Puzzle>> getDemoPuzzles();
}
