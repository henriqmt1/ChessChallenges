import '../../domain/entities/campaign_level_node.dart';

class CampaignMapState {
  const CampaignMapState({
    required this.nodes,
    required this.worldIndex,
    required this.worldTheme,
    required this.unlockedWorldCount,
    required this.completedCount,
    required this.currentLevelIndex,
    required this.offensiveCount,
    required this.isActivityCompletedToday,
  });

  final List<CampaignLevelNode> nodes;
  final int worldIndex;
  final String worldTheme;
  final int unlockedWorldCount;
  final int completedCount;
  final int currentLevelIndex;
  final int offensiveCount;
  final bool isActivityCompletedToday;

  static const xpPerLevel = 10;
  static const totalWorlds = 10;

  int get totalPlayableLevels {
    return nodes.where((node) => node.puzzle != null).length;
  }

  int get earnedWorldXp {
    return completedCount * xpPerLevel;
  }

  int get totalWorldXp {
    return totalPlayableLevels * xpPerLevel;
  }

  double get worldXpProgress {
    if (totalWorldXp == 0) {
      return 0;
    }

    return earnedWorldXp / totalWorldXp;
  }

  bool get canGoToNextWorld {
    return !isLastWorld &&
        totalPlayableLevels > 0 &&
        completedCount >= totalPlayableLevels;
  }

  bool get isLastWorld => worldIndex >= totalWorlds;

  bool isWorldUnlocked(int world) => world <= unlockedWorldCount;
}
