import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local_puzzle_data_source.dart';
import '../../data/repositories/local_puzzle_repository.dart';
import '../../domain/repositories/puzzle_repository.dart';
import '../../domain/usecases/get_demo_puzzles_use_case.dart';

final localPuzzleDataSourceProvider = Provider<LocalPuzzleDataSource>((ref) {
  return const LocalPuzzleDataSource();
});

final puzzleRepositoryProvider = Provider<PuzzleRepository>((ref) {
  return LocalPuzzleRepository(ref.watch(localPuzzleDataSourceProvider));
});

final getDemoPuzzlesUseCaseProvider = Provider<GetDemoPuzzlesUseCase>((ref) {
  return GetDemoPuzzlesUseCase(ref.watch(puzzleRepositoryProvider));
});
