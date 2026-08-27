import '../entities/puzzle.dart';
import '../repositories/puzzle_repository.dart';

class GetDemoPuzzlesUseCase {
  const GetDemoPuzzlesUseCase(this._repository);

  final PuzzleRepository _repository;

  Future<List<Puzzle>> call() {
    return _repository.getDemoPuzzles();
  }
}
