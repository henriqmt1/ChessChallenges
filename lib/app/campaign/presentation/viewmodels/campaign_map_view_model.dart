import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../puzzles/presentation/viewmodels/puzzle_dependencies.dart';
import '../../domain/entities/campaign_level_node.dart';
import '../../domain/entities/campaign_world.dart';
import 'campaign_map_state.dart';
import 'campaign_progress_view_model.dart';
import 'campaign_progress_state.dart';

/// Null when all available lessons are complete; never opens a missing level.
final nextCampaignLevelProvider = FutureProvider<int?>((ref) async {
  final progress = await ref.watch(campaignProgressViewModelProvider.future);
  final puzzles = await ref.watch(getDemoPuzzlesUseCaseProvider).call();
  return progress.currentLevelIndex < puzzles.length
      ? progress.currentLevelIndex
      : null;
});

final selectedWorldViewModelProvider =
    NotifierProvider<SelectedWorldViewModel, int>(SelectedWorldViewModel.new);

class SelectedWorldViewModel extends Notifier<int> {
  @override
  int build() => 1;

  void select(int world) {
    state = world.clamp(1, CampaignMapState.totalWorlds);
  }

  void selectCurrentLevelWorld(int currentLevelIndex) {
    const levelsPerWorld = 10;
    select((currentLevelIndex ~/ levelsPerWorld) + 1);
  }
}

final campaignMapViewModelProvider = FutureProvider<CampaignMapState>((
  ref,
) async {
  final puzzles = await ref.watch(getDemoPuzzlesUseCaseProvider).call();
  final selectedWorld = ref.watch(selectedWorldViewModelProvider);
  final progressAsync = ref.watch(campaignProgressViewModelProvider);
  final progress = switch (progressAsync) {
    AsyncData(:final value) => value,
    _ => CampaignProgressState.empty(),
  };
  const levelsPerWorld = 10;
  const offsets = <double>[
    0,
    -0.8,
    0.85,
    0.25,
    -0.95,
    0.75,
    -0.2,
    1,
    0.2,
    -0.75,
  ];

  final worldStartIndex = (selectedWorld - 1) * levelsPerWorld;
  final world = campaignWorlds[selectedWorld - 1];

  final nodes = List.generate(levelsPerWorld, (localIndex) {
    final globalIndex = worldStartIndex + localIndex;
    final puzzle = globalIndex < puzzles.length ? puzzles[globalIndex] : null;
    final status = progress.isCompleted(globalIndex)
        ? CampaignLevelNodeStatus.completed
        : progress.isUnlocked(globalIndex) && puzzle != null
        ? CampaignLevelNodeStatus.current
        : CampaignLevelNodeStatus.locked;

    return CampaignLevelNode(
      index: globalIndex,
      status: status,
      type: _nodeTypeFor(localIndex),
      xOffset: offsets[localIndex],
      puzzle: puzzle,
    );
  });

  final completedInWorld = nodes
      .where((node) => node.status == CampaignLevelNodeStatus.completed)
      .length;
  final unlockedWorldCount =
      ((progress.currentLevelIndex ~/ levelsPerWorld) + 1).clamp(
        1,
        CampaignMapState.totalWorlds,
      );

  return CampaignMapState(
    nodes: nodes,
    worldIndex: selectedWorld,
    worldTheme: world.theme,
    unlockedWorldCount: unlockedWorldCount,
    completedCount: completedInWorld,
    currentLevelIndex: progress.currentLevelIndex,
    offensiveCount: progress.offensiveCount,
    isActivityCompletedToday: progress.hasActivityOn(DateTime.now()),
  );
});

CampaignLevelNodeType _nodeTypeFor(int index) {
  if ((index + 1) % 10 == 0) {
    return CampaignLevelNodeType.boss;
  }

  return CampaignLevelNodeType.normal;
}
