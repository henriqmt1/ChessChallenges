import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../progress/domain/player_progress.dart';
import '../../../progress/presentation/viewmodels/player_progress_controller.dart';
import '../../data/objective_challenge_data_source.dart';
import '../../domain/objective_challenge_level.dart';
import 'objective_challenge_game_page.dart';

class ObjectiveChallengesPage extends ConsumerWidget {
  const ObjectiveChallengesPage({super.key});

  static const int levelCount = 30;
  static const int totalStars = levelCount * 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(objectiveChallengeLevelsProvider);
    final progress = ref
        .watch(playerProgressControllerProvider)
        .maybeWhen(data: (progress) => progress, orElse: PlayerProgress.empty);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth
                .clamp(0, AppSizes.contentMaxWidth)
                .toDouble();
            final gridWidth = maxWidth - (AppSpacing.lg * 2);
            final columns = gridWidth < 340 ? 2 : 3;

            return Center(
              child: SizedBox(
                width: maxWidth,
                child: CustomScrollView(
                  key: const ValueKey('objective-challenges-page'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      sliver: SliverToBoxAdapter(child: _ObjectiveTopBar()),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xs,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: const _ObjectiveHeroCard(),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _ObjectiveSectionHeader(
                          earnedStars: progress.objectiveStars,
                          totalStars: totalStars,
                        ),
                      ),
                    ),
                    levelsAsync.when(
                      data: (levels) => SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.md,
                        ),
                        sliver: SliverGrid(
                          key: const ValueKey('objective-level-grid'),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisSpacing: AppSpacing.sm,
                                crossAxisSpacing: AppSpacing.sm,
                                childAspectRatio: columns == 2 ? 1.02 : 0.76,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final level = levels[index];
                            final stars =
                                progress.objectiveStarsByLevel[level.level] ??
                                0;
                            final previousStars = level.level == 1
                                ? 1
                                : progress.objectiveStarsByLevel[level.level -
                                          1] ??
                                      0;

                            return _ObjectiveLevelCard(
                              level: level,
                              stars: stars,
                              unlocked: previousStars > 0,
                              onTap: () => _openLevel(context, level),
                            );
                          }, childCount: levels.length),
                        ),
                      ),
                      loading: () => const SliverPadding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        sliver: SliverToBoxAdapter(
                          child: Center(child: Text('Carregando desafios...')),
                        ),
                      ),
                      error: (_, _) => SliverPadding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            'Não foi possível carregar os desafios agora.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.xl,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _ObjectiveFutureLevelsNote(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openLevel(BuildContext context, ObjectiveChallengeLevel level) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ObjectiveChallengeGamePage(level: level),
      ),
    );
  }
}

class _ObjectiveTopBar extends StatelessWidget {
  const _ObjectiveTopBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.standard * 2),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            IconButton(
              tooltip: context.l10n.backTooltip,
              onPressed: () => Navigator.of(context).pop(),
              color: colorScheme.onSurface,
              style: IconButton.styleFrom(
                minimumSize: const Size.square(44),
                maximumSize: const Size.square(44),
                padding: EdgeInsets.zero,
                backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.55,
                ),
                side: BorderSide(color: colorScheme.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.standard),
                ),
              ),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: AppIconSizes.status,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                context.l10n.objectiveChallengesTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectiveHeroCard extends StatelessWidget {
  const _ObjectiveHeroCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppRadii.standard * 2.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryGlow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.whiteOverlay15,
                borderRadius: BorderRadius.circular(AppRadii.standard * 1.5),
                border: Border.all(color: AppColors.whiteBorder20),
              ),
              child: const SizedBox.square(
                dimension: 54,
                child: Icon(
                  Icons.stars_rounded,
                  color: AppColors.white,
                  size: AppIconSizes.display,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.objectiveChallengesHeroTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    context.l10n.objectiveChallengesHeroSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.86),
                      fontWeight: FontWeight.w700,
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _ObjectiveHeroChip(
                        icon: Icons.flag_rounded,
                        label: context.l10n.objectiveChallengesLevelCount(
                          ObjectiveChallengesPage.levelCount,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectiveHeroChip extends StatelessWidget {
  const _ObjectiveHeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.whiteOverlay15,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.whiteBorder20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.white, size: AppIconSizes.small),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectiveSectionHeader extends StatelessWidget {
  const _ObjectiveSectionHeader({
    required this.earnedStars,
    required this.totalStars,
  });

  final int earnedStars;
  final int totalStars;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          child: Text(
            context.l10n.objectiveChallengesProgress(earnedStars, totalStars),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _ObjectiveLevelCard extends StatelessWidget {
  const _ObjectiveLevelCard({
    required this.level,
    required this.stars,
    required this.unlocked,
    required this.onTap,
  });

  final ObjectiveChallengeLevel level;
  final int stars;
  final bool unlocked;
  final VoidCallback onTap;

  IconData get _icon {
    switch ((level.level - 1) % 6) {
      case 0:
        return Icons.gps_fixed_rounded;
      case 1:
        return Icons.bolt_rounded;
      case 2:
        return Icons.shield_rounded;
      case 3:
        return Icons.psychology_rounded;
      case 4:
        return Icons.workspace_premium_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  Color get _iconAccentColor {
    switch ((level.level - 1) % 6) {
      case 0:
        return const Color(0xFF0EA5E9);
      case 1:
        return const Color(0xFFF59E0B);
      case 2:
        return const Color(0xFF22C55E);
      case 3:
        return const Color(0xFFEC4899);
      case 4:
        return AppColors.primaryDark;
      default:
        return const Color(0xFFFF7A1A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final iconAccentColor = _iconAccentColor;
    final foreground = unlocked
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;
    final borderColor = unlocked
        ? AppColors.primary.withValues(alpha: 0.38)
        : colorScheme.outlineVariant;
    final surfaceColor = unlocked
        ? colorScheme.surface
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.62);
    final iconBackground = unlocked
        ? iconAccentColor.withValues(alpha: isDark ? 0.18 : 0.12)
        : colorScheme.surfaceContainerHighest;
    final iconColor = unlocked
        ? iconAccentColor
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.72);
    final iconBorderColor = unlocked
        ? iconAccentColor.withValues(alpha: isDark ? 0.28 : 0.18)
        : colorScheme.outlineVariant.withValues(alpha: 0.45);

    return Semantics(
      label: context.l10n.objectiveChallengeLevelSemantics(level.level),
      enabled: unlocked,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.standard * 2),
          onTap: unlocked ? onTap : null,
          child: DecoratedBox(
            key: ValueKey('objective-level-${level.level}'),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(AppRadii.standard * 2),
              border: Border.all(color: borderColor),
              boxShadow: [
                if (unlocked)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: iconBackground,
                          borderRadius: BorderRadius.circular(
                            AppRadii.standard,
                          ),
                          border: Border.all(color: iconBorderColor),
                        ),
                        child: SizedBox.square(
                          dimension: 36,
                          child: Icon(
                            _icon,
                            color: iconColor,
                            size: AppIconSizes.status,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (!unlocked)
                        Icon(
                          key: ValueKey('objective-level-${level.level}-lock'),
                          Icons.lock_rounded,
                          color: iconColor,
                          size: AppIconSizes.small,
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '${level.level}',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ObjectiveStars(enabled: unlocked, stars: stars),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ObjectiveFutureLevelsNote extends StatelessWidget {
  const _ObjectiveFutureLevelsNote();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      key: const ValueKey('objective-future-levels-note'),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(AppRadii.standard * 1.5),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: colorScheme.onSurfaceVariant,
              size: AppIconSizes.small,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                context.l10n.objectiveChallengesFutureLevelsNote,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectiveStars extends StatelessWidget {
  const _ObjectiveStars({required this.enabled, required this.stars});

  final bool enabled;
  final int stars;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = enabled
        ? const Color(0xFFFFC83D)
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.38);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < 3; index++)
          Icon(
            enabled && index < stars
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: color,
            size: AppIconSizes.small,
          ),
      ],
    );
  }
}
