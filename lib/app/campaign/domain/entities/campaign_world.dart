class CampaignWorld {
  const CampaignWorld({
    required this.index,
    required this.theme,
    required this.difficultyBand,
    required this.emblemAsset,
  });

  final int index;
  final String theme;
  final String difficultyBand;
  final String emblemAsset;
}

const campaignWorlds = <CampaignWorld>[
  CampaignWorld(
    index: 1,
    theme: 'fundamentals',
    difficultyBand: 'easy',
    emblemAsset: 'assets/chess/ui/world_1_knight.png',
  ),
  CampaignWorld(
    index: 2,
    theme: 'mateIn1',
    difficultyBand: 'easy',
    emblemAsset: 'assets/chess/ui/world_2_queen.png',
  ),
  CampaignWorld(
    index: 3,
    theme: 'material',
    difficultyBand: 'easy',
    emblemAsset: 'assets/chess/ui/world_3_rook.png',
  ),
  CampaignWorld(
    index: 4,
    theme: 'fork',
    difficultyBand: 'medium',
    emblemAsset: 'assets/chess/ui/world_4_knight.png',
  ),
  CampaignWorld(
    index: 5,
    theme: 'pin',
    difficultyBand: 'medium',
    emblemAsset: 'assets/chess/ui/world_5_bishop.png',
  ),
  CampaignWorld(
    index: 6,
    theme: 'discoveredAttack',
    difficultyBand: 'medium',
    emblemAsset: 'assets/chess/ui/world_6_rook.png',
  ),
  CampaignWorld(
    index: 7,
    theme: 'defense',
    difficultyBand: 'medium',
    emblemAsset: 'assets/chess/ui/world_7_king.png',
  ),
  CampaignWorld(
    index: 8,
    theme: 'endgame',
    difficultyBand: 'advanced',
    emblemAsset: 'assets/chess/ui/world_8_pawn.png',
  ),
  CampaignWorld(
    index: 9,
    theme: 'combination',
    difficultyBand: 'advanced',
    emblemAsset: 'assets/chess/ui/world_9_queen.png',
  ),
  CampaignWorld(
    index: 10,
    theme: 'mastery',
    difficultyBand: 'advanced',
    emblemAsset: 'assets/chess/ui/world_10_king.png',
  ),
];
