import '../../../puzzles/domain/entities/puzzle.dart';

enum CampaignLevelNodeStatus { completed, current, locked }

enum CampaignLevelNodeType { normal, boss }

class CampaignLevelNode {
  const CampaignLevelNode({
    required this.index,
    required this.status,
    required this.type,
    required this.xOffset,
    required this.puzzle,
  });

  final int index;
  final CampaignLevelNodeStatus status;
  final CampaignLevelNodeType type;
  final double xOffset;
  final Puzzle? puzzle;

  int get numberInWorld => (index % 10) + 1;

  bool get isPlayable =>
      puzzle != null && status != CampaignLevelNodeStatus.locked;
}
