import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/campaign_level_node.dart';

class CampaignLevelButton extends StatelessWidget {
  const CampaignLevelButton({
    super.key,
    required this.node,
    required this.onTap,
  });

  final CampaignLevelNode node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _LevelButtonStyle.fromStatus(
      node.status,
      Theme.of(context).colorScheme,
    );

    return Semantics(
      button: true,
      label: node.status == CampaignLevelNodeStatus.locked
          ? context.l10n.lockedLevelTitle(node.numberInWorld)
          : context.l10n.levelLabel(node.numberInWorld),
      enabled: true,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          onTap: onTap,
          child: SizedBox.square(
            key: ValueKey('campaign-level-${node.index}'),
            dimension: AppSizes.campaignNode,
            child: Stack(
              alignment: Alignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: style.shadowColor,
                  ),
                  child: const SizedBox.square(
                    dimension: AppSizes.campaignNode,
                  ),
                ),
                Positioned(
                  top: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: style.backgroundColor,
                      border: Border.all(color: style.borderColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: style.glowColor,
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SizedBox.square(
                      dimension: AppSizes.campaignNodeFace,
                      child: Center(
                        child: _LevelButtonContent(node: node, style: style),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelButtonContent extends StatelessWidget {
  const _LevelButtonContent({required this.node, required this.style});

  final CampaignLevelNode node;
  final _LevelButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final icon = switch (node.status) {
      CampaignLevelNodeStatus.completed => Icons.check_rounded,
      CampaignLevelNodeStatus.locked => Icons.lock_rounded,
      CampaignLevelNodeStatus.current => switch (node.type) {
        CampaignLevelNodeType.boss => Icons.workspace_premium_rounded,
        CampaignLevelNodeType.normal => null,
      },
    };

    if (icon != null) {
      return Icon(
        icon,
        color: style.foregroundColor,
        size: AppIconSizes.extraLarge,
      );
    }

    return Text(
      '${node.numberInWorld}',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: style.foregroundColor,
        fontSize: AppFontSizes.sectionTitle,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _LevelButtonStyle {
  const _LevelButtonStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.shadowColor,
    required this.glowColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final Color shadowColor;
  final Color glowColor;

  factory _LevelButtonStyle.fromStatus(
    CampaignLevelNodeStatus status,
    ColorScheme colorScheme,
  ) {
    return switch (status) {
      CampaignLevelNodeStatus.completed => const _LevelButtonStyle(
        backgroundColor: AppColors.success,
        foregroundColor: AppColors.white,
        borderColor: AppColors.successBorder,
        shadowColor: AppColors.successDark,
        glowColor: AppColors.successGlow,
      ),
      CampaignLevelNodeStatus.current => const _LevelButtonStyle(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        borderColor: AppColors.primaryBorder,
        shadowColor: AppColors.primaryDark,
        glowColor: AppColors.primaryGlow,
      ),
      CampaignLevelNodeStatus.locked => _LevelButtonStyle(
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurfaceVariant,
        borderColor: colorScheme.outlineVariant,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.24),
        glowColor: AppColors.transparent,
      ),
    };
  }
}
