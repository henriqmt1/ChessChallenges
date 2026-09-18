import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_edition.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_mode_view_model.dart';
import '../../../../shared/monetization/premium_sheet.dart';
import '../../../bot_game/presentation/pages/bot_game_page.dart';
import '../../../campaign/presentation/pages/campaign_page.dart';
import '../../../campaign/presentation/viewmodels/campaign_map_view_model.dart';
import '../../../puzzles/presentation/pages/puzzle_page.dart';
import '../../../campaign/presentation/viewmodels/campaign_progress_view_model.dart';
import '../../../faq/presentation/pages/faq_page.dart';
import '../../../local_game/presentation/pages/local_game_page.dart';
import '../../../objective_challenges/presentation/pages/objective_challenges_page.dart';
import '../../../progress/presentation/pages/progress_page.dart';
import '../../../../shared/widgets/app_design_system.dart';

const _guidedLessonsAccent = AppColors.primary;
const _objectiveChallengesAccent = AppColors.objectiveAccent;
const _botGameAccent = AppColors.botAccent;
const _localPlayersAccent = AppColors.localGameAccent;

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstGuidedLevelCompleted = ref
        .watch(campaignProgressViewModelProvider)
        .maybeWhen(
          data: (progress) => progress.isCompleted(0),
          orElse: () => false,
        );
    final nextLevel = ref.watch(nextCampaignLevelProvider).value;
    final resumeLevel = firstGuidedLevelCompleted ? nextLevel : null;
    final guidedLessonsActionLabel = resumeLevel != null
        ? context.l10n.homeContinueLevel(resumeLevel + 1)
        : context.l10n.homePlayAction;

    return Scaffold(
      body: AppPageFrame(
        scrollKey: const ValueKey('home-scroll'),
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            sliver: SliverToBoxAdapter(child: _HomeToolbar()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            sliver: SliverToBoxAdapter(
              child: _HomeModeList(
                guidedLessonsActionLabel: guidedLessonsActionLabel,
                resumeLevel: resumeLevel,
                onCompleted: (index) {
                  unawaited(
                    ref
                        .read(campaignProgressViewModelProvider.notifier)
                        .completeLevel(index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeModeList extends StatelessWidget {
  const _HomeModeList({
    required this.guidedLessonsActionLabel,
    required this.resumeLevel,
    required this.onCompleted,
  });

  final String guidedLessonsActionLabel;
  final int? resumeLevel;
  final ValueChanged<int> onCompleted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.homeChooseModeTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          context.l10n.homeChooseModeSubtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.24),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ModeCard(
          key: const ValueKey('mode-guided-lessons-card'),
          title: context.l10n.homeGuidedLessonsTitle,
          description: context.l10n.homeGuidedLessonsDescription,
          actionLabel: guidedLessonsActionLabel,
          icon: Icons.school_rounded,
          accentColor: _guidedLessonsAccent,
          enabled: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => resumeLevel == null
                  ? const CampaignPage(showBackButton: true)
                  : PuzzlePage(
                      initialPuzzleIndex: resumeLevel!,
                      showSelector: false,
                      onCompleted: onCompleted,
                    ),
            ),
          ),
        ),
        if (resumeLevel != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const ValueKey('home-campaign-map'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CampaignPage(showBackButton: true),
                ),
              ),
              icon: const Icon(Icons.map_outlined),
              label: Text(context.l10n.mapButton),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        _ModeCard(
          key: const ValueKey('mode-objectives-card'),
          title: context.l10n.homeObjectiveModeTitle,
          description: context.l10n.homeObjectiveModeDescription,
          actionLabel: context.l10n.homePlayAction,
          icon: Icons.star_rounded,
          accentColor: _objectiveChallengesAccent,
          enabled: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ObjectiveChallengesPage(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ModeCard(
          key: const ValueKey('mode-vs-bot-card'),
          title: context.l10n.homeVsBotModeTitle,
          description: context.l10n.homeVsBotModeDescription,
          actionLabel: context.l10n.homePlayAction,
          icon: Icons.smart_toy_rounded,
          accentColor: _botGameAccent,
          enabled: true,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const BotGamePage())),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ModeCard(
          key: const ValueKey('mode-local-players-card'),
          title: context.l10n.homeLocalPlayersModeTitle,
          description: context.l10n.homeLocalPlayersModeDescription,
          actionLabel: context.l10n.homePlayAction,
          icon: Icons.people_alt_rounded,
          accentColor: _localPlayersAccent,
          enabled: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const LocalGamePage()),
          ),
        ),
      ],
    );
  }
}

class _HomeToolbar extends ConsumerWidget {
  const _HomeToolbar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark =
        ref.watch(themeModeViewModelProvider).value == ThemeMode.dark;
    final edition = ref.watch(appEditionProvider);
    final progress = ref
        .watch(campaignProgressViewModelProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    final offensiveCount = progress?.offensiveCount ?? 0;
    final activityDoneToday = progress?.hasActivityOn(DateTime.now()) ?? false;
    final fireColor = activityDoneToday
        ? AppColors.fireActive
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.42);

    return AppSurface(
      padding: const EdgeInsets.all(AppSpacing.sm),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: isDark ? 0.28 : 0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.appTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ToolbarAction(
                key: const ValueKey('theme-mode-toggle'),
                tooltip: isDark
                    ? context.l10n.lightModeTooltip
                    : context.l10n.darkModeTooltip,
                icon: isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                onPressed: () {
                  unawaited(
                    ref.read(themeModeViewModelProvider.notifier).toggle(),
                  );
                },
              ),
              const SizedBox(width: AppSpacing.xs),
              _ToolbarAction(
                key: const ValueKey('faq-button'),
                tooltip: context.l10n.faqTooltip,
                icon: Icons.contact_support_outlined,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const FaqPage()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _EditionBadge(
                  edition: edition,
                  colorScheme: colorScheme,
                  onTap: () => showPremiumSheet(context),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _OffensiveBadge(
                  count: offensiveCount,
                  color: fireColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ProgressPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OffensiveBadge extends StatelessWidget {
  const _OffensiveBadge({
    required this.count,
    required this.color,
    required this.onTap,
  });

  final int count;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.progressTooltip,
      child: Semantics(
        label: context.l10n.offensiveCount(count),
        button: true,
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            key: const ValueKey('offensive-badge'),
            borderRadius: BorderRadius.circular(AppRadii.standard * 1.5),
            onTap: onTap,
            child: AppPill(
              borderRadius: BorderRadius.circular(AppRadii.standard * 1.5),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    key: const ValueKey('offensive-fire'),
                    color: color,
                    size: AppIconSizes.standard,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Flexible(
                    child: Text(
                      '$count',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    super.key,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.icon,
    required this.accentColor,
    this.enabled = false,
    this.onTap,
  });

  final String title;
  final String description;
  final String actionLabel;
  final IconData icon;
  final Color accentColor;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeAccent = enabled ? accentColor : colorScheme.onSurfaceVariant;
    final foregroundColor = colorScheme.onSurface;
    final secondaryColor = colorScheme.onSurfaceVariant;
    final cardTint = Color.lerp(
      colorScheme.surface,
      activeAccent,
      enabled ? (isDark ? 0.055 : 0.035) : 0.0,
    )!;
    final borderColor = Color.lerp(
      colorScheme.outlineVariant,
      activeAccent,
      enabled ? 0.44 : 0.0,
    )!;

    return Opacity(
      opacity: enabled ? 1 : 0.72,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cardTint,
          borderRadius: BorderRadius.circular(AppRadii.standard * 2),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: activeAccent.withValues(alpha: isDark ? 0.10 : 0.08),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.standard * 2),
          child: Stack(
            children: [
              Positioned(
                right: -36,
                top: -40,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeAccent.withValues(alpha: isDark ? 0.11 : 0.08),
                  ),
                  child: const SizedBox.square(dimension: 108),
                ),
              ),
              Positioned(
                left: 0,
                top: AppSpacing.sm,
                bottom: AppSpacing.sm,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: activeAccent,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(AppRadii.pill),
                    ),
                  ),
                  child: const SizedBox(width: 4),
                ),
              ),
              Material(
                color: AppColors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.standard * 2),
                  onTap: enabled ? onTap : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: activeAccent.withValues(
                              alpha: isDark ? 0.18 : 0.12,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppRadii.standard * 1.5,
                            ),
                            border: Border.all(
                              color: activeAccent.withValues(alpha: 0.22),
                            ),
                          ),
                          child: SizedBox.square(
                            dimension: 50,
                            child: Icon(
                              icon,
                              color: activeAccent,
                              size: AppIconSizes.large,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: foregroundColor,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: secondaryColor,
                                      height: 1.28,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              _ModeActionLabel(
                                label: actionLabel,
                                enabled: enabled,
                                accentColor: activeAccent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditionBadge extends StatelessWidget {
  const _EditionBadge({
    required this.edition,
    required this.colorScheme,
    required this.onTap,
  });

  final AppEdition edition;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final premium = edition == AppEdition.premium;
    final color = premium ? AppColors.primary : colorScheme.onSurfaceVariant;

    return Semantics(
      label: premium ? 'Premium' : 'Free',
      button: true,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          key: const ValueKey('app-edition-badge'),
          borderRadius: BorderRadius.circular(AppRadii.standard * 1.5),
          onTap: onTap,
          child: AppPill(
            borderRadius: BorderRadius.circular(AppRadii.standard * 1.5),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  premium
                      ? Icons.diamond_rounded
                      : Icons.workspace_premium_rounded,
                  color: color,
                  size: AppIconSizes.small,
                ),
                const SizedBox(width: AppSpacing.xxs),
                Flexible(
                  child: Text(
                    premium ? 'PRO' : 'FREE',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
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

class _ModeActionLabel extends StatelessWidget {
  const _ModeActionLabel({
    required this.label,
    required this.enabled,
    required this.accentColor,
  });

  final String label;
  final bool enabled;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = enabled ? accentColor : colorScheme.onSurfaceVariant;

    return AppPill(
      color: color.withValues(alpha: enabled ? 0.12 : 0.08),
      borderColor: color.withValues(alpha: 0.20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Icon(
            enabled ? Icons.arrow_forward_rounded : Icons.lock_clock_rounded,
            color: color,
            size: AppIconSizes.small,
          ),
        ],
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  const _ToolbarAction({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppToolbarIconButton(
      tooltip: tooltip,
      icon: icon,
      onPressed: onPressed,
      size: 40,
      iconSize: AppIconSizes.status,
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.55,
      ),
    );
  }
}
