import '../../domain/entities/puzzle.dart';
import '../../domain/repositories/puzzle_repository.dart';
import '../datasources/local_puzzle_data_source.dart';

class LocalPuzzleRepository implements PuzzleRepository {
  const LocalPuzzleRepository(this._dataSource);

  final LocalPuzzleDataSource _dataSource;

  @override
  Future<List<Puzzle>> getDemoPuzzles() {
    return _dataSource.loadDemoPuzzles();
  }
}
