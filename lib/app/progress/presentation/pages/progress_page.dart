import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/feedback/app_toast.dart';
import '../../../bot_game/domain/bot_difficulty.dart';
import '../../domain/player_progress.dart';
import '../viewmodels/account_sync_view_model.dart';
import '../viewmodels/player_progress_view_model.dart';
import '../../../../shared/widgets/app_design_system.dart';

class ProgressPage extends ConsumerStatefulWidget {
  const ProgressPage({super.key});

  @override
  ConsumerState<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends ConsumerState<ProgressPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(
        ref.read(playerProgressViewModelProvider.notifier).refreshRemote(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(playerProgressViewModelProvider);
    final syncState = ref.watch(accountSyncViewModelProvider);
    final progress = progressAsync.maybeWhen(
      data: (value) => value,
      orElse: PlayerProgress.empty,
    );

    return Scaffold(
      body: AppPageFrame(
        scrollKey: const ValueKey('progress-page'),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            sliver: SliverToBoxAdapter(
              child: AppPageHeader(
                title: context.l10n.progressTitle,
                subtitle: context.l10n.progressSubtitle,
                onBack: () => Navigator.of(context).pop(),
                titleMaxLines: 1,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              child: _ProgressHeroCard(progress: progress),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              child: _ProgressSyncCard(
                state: syncState,
                onGoogle: () => _runSyncAction(
                  context,
                  () => ref
                      .read(accountSyncViewModelProvider.notifier)
                      .linkGoogle(),
                ),
                onApple: () => _runSyncAction(
                  context,
                  () => ref
                      .read(accountSyncViewModelProvider.notifier)
                      .linkApple(),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            sliver: SliverToBoxAdapter(
              child: _ProgressStatsGrid(progress: progress),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runSyncAction(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on AccountSyncException catch (error) {
      if (!context.mounted) {
        return;
      }

      AppToast.showError(context, _syncErrorMessage(context, error.error));
    }
  }

  String _syncErrorMessage(BuildContext context, AccountSyncError error) {
    return switch (error) {
      AccountSyncError.firebaseUnavailable =>
        context.l10n.progressSyncErrorFirebase,
      AccountSyncError.googleConfigurationMissing =>
        context.l10n.progressSyncErrorGoogleConfig,
      AccountSyncError.appleUnavailable =>
        context.l10n.progressSyncErrorAppleConfig,
      AccountSyncError.providerDisabled =>
        context.l10n.progressSyncErrorProviderDisabled,
      AccountSyncError.accountAlreadyExists =>
        context.l10n.progressSyncErrorAccountExists,
      AccountSyncError.network => context.l10n.progressSyncErrorNetwork,
      AccountSyncError.canceled => context.l10n.progressSyncCanceled,
      AccountSyncError.generic => context.l10n.progressSyncErrorGeneric,
    };
  }
}

class _ProgressHeroCard extends StatelessWidget {
  const _ProgressHeroCard({required this.progress});

  final PlayerProgress progress;

  @override
  Widget build(BuildContext context) {
    final synced = progress.lastSyncedAt != null;
    final statusLabel = synced
        ? context.l10n.progressSynced
        : context.l10n.progressLocalOnly;

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
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.whiteOverlay15,
                borderRadius: BorderRadius.circular(AppRadii.standard * 1.5),
                border: Border.all(color: AppColors.whiteBorder20),
              ),
              child: const SizedBox.square(
                dimension: 56,
                child: Icon(
                  Icons.emoji_events_rounded,
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
                    context.l10n.progressHeroTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    context.l10n.progressHeroSubtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.88),
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ProgressStatusChip(label: statusLabel, synced: synced),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStatusChip extends StatelessWidget {
  const _ProgressStatusChip({required this.label, required this.synced});

  final String label;
  final bool synced;

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
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              synced ? Icons.cloud_done_rounded : Icons.phone_iphone_rounded,
              color: AppColors.white,
              size: AppIconSizes.small,
            ),
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

class _ProgressSyncCard extends StatelessWidget {
  const _ProgressSyncCard({
    required this.state,
    required this.onGoogle,
    required this.onApple,
  });

  final AccountSyncState state;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showApple = switch (Theme.of(context).platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };
    final connected = state.isLinked;
    final account =
        state.accountLabel ?? context.l10n.progressSyncConnectedFallback;
    final title = connected
        ? context.l10n.progressSyncConnectedTitle
        : context.l10n.progressSyncGuestTitle;
    final description = connected
        ? context.l10n.progressSyncConnectedDescription(account)
        : context.l10n.progressSyncGuestDescription;
    final badge = connected
        ? context.l10n.progressSyncConnectedBadge
        : context.l10n.progressSyncGuestBadge;
    final accent = connected ? AppColors.success : AppColors.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.lerp(colorScheme.surface, accent, isDark ? 0.05 : 0.025),
        borderRadius: BorderRadius.circular(AppRadii.standard * 2),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.10 : 0.07),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(
                      AppRadii.standard * 1.4,
                    ),
                  ),
                  child: SizedBox.square(
                    dimension: 48,
                    child: Icon(
                      connected
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_upload_rounded,
                      color: accent,
                      size: AppIconSizes.large,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.progressSyncSection,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _SyncBadge(label: badge, color: accent),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (state.isBusy)
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: accent,
                  ),
                ),
              )
            else if (connected)
              _SyncConnectedPill(
                label: context.l10n.progressSynced,
                color: accent,
              )
            else
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _SyncProviderButton(
                    onPressed: onGoogle,
                    icon: const Icon(Icons.g_mobiledata_rounded),
                    label: Text(context.l10n.progressSyncGoogleAction),
                    color: const Color(0xFF4285F4),
                  ),
                  if (showApple)
                    _SyncProviderButton(
                      onPressed: onApple,
                      icon: const Icon(Icons.apple_rounded),
                      label: Text(context.l10n.progressSyncAppleAction),
                      color: colorScheme.onSurface,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SyncProviderButton extends StatelessWidget {
  const _SyncProviderButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  final VoidCallback onPressed;
  final Widget icon;
  final Widget label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: IconTheme.merge(
        data: IconThemeData(color: color, size: AppIconSizes.status),
        child: icon,
      ),
      label: DefaultTextStyle.merge(
        style: TextStyle(color: colorScheme.onSurface),
        child: label,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        backgroundColor: colorScheme.surface,
        side: BorderSide(color: colorScheme.outlineVariant),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.standard * 1.5),
        ),
      ),
    );
  }
}

class _SyncConnectedPill extends StatelessWidget {
  const _SyncConnectedPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: color.withValues(alpha: 0.24)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: color,
                size: AppIconSizes.small,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ProgressStatsGrid extends StatelessWidget {
  const _ProgressStatsGrid({required this.progress});

  static const _objectiveTotalStars = 90;

  final PlayerProgress progress;

  @override
  Widget build(BuildContext context) {
    final advancedBotWins = progress.botWinsForDifficulty(
      BotDifficulty.advanced.name,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProgressSection(
          title: context.l10n.progressRoutineSection,
          children: [
            _ProgressStatCard(
              data: _ProgressStatData(
                label: context.l10n.progressCurrentStreak,
                value: '${progress.offensiveCount}',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.fireActive,
              ),
            ),
            _ProgressStatCard(
              data: _ProgressStatData(
                label: context.l10n.progressBestStreak,
                value: '${progress.bestOffensiveCount}',
                icon: Icons.whatshot_rounded,
                color: const Color(0xFFF59E0B),
              ),
            ),
            _ProgressStatCard(
              data: _ProgressStatData(
                label: context.l10n.progressActiveDays,
                value: '${progress.activeDays}',
                icon: Icons.calendar_month_rounded,
                color: const Color(0xFF22C55E),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _ProgressSection(
          title: context.l10n.progressLearningSection,
          children: [
            _ProgressStatCard(
              data: _ProgressStatData(
                label: context.l10n.progressGuidedLessons,
                value: '${progress.guidedLessonsCompleted}',
                icon: Icons.school_rounded,
                color: AppColors.primary,
              ),
            ),
            _ProgressStatCard(
              data: _ProgressStatData(
                label: context.l10n.progressObjectiveStars,
                value: '${progress.objectiveStars}/$_objectiveTotalStars',
                icon: Icons.stars_rounded,
                color: const Color(0xFFFACC15),
              ),
            ),
            _ProgressStatCard(
              data: _ProgressStatData(
                label: context.l10n.progressObjectiveChallenges,
                value: '${progress.objectiveChallengesCompleted}',
                icon: Icons.flag_rounded,
                color: const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _ProgressSection(
          title: context.l10n.progressGamesSection,
          fullWidthCards: true,
          children: [
            _ProgressSummaryCard(
              title: context.l10n.progressBotGames,
              value: '${progress.botGamesPlayed}',
              subtitle: context.l10n.progressBotSummary(
                progress.botWins,
                advancedBotWins,
              ),
              icon: Icons.smart_toy_rounded,
              color: const Color(0xFF0EA5E9),
            ),
            _ProgressSummaryCard(
              title: context.l10n.progressLocalGames,
              value: '${progress.localGamesPlayed}',
              subtitle: context.l10n.progressLocalSummary(progress.localDraws),
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF22C55E),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.title,
    required this.children,
    this.fullWidthCards = false,
  });

  final String title;
  final List<Widget> children;
  final bool fullWidthCards;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = !fullWidthCards && constraints.maxWidth >= 360;
            final cardWidth = twoColumns
                ? (constraints.maxWidth - AppSpacing.sm) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final child in children)
                  SizedBox(width: cardWidth, child: child),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ProgressSummaryCard extends StatelessWidget {
  const _ProgressSummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.lerp(colorScheme.surface, color, isDark ? 0.05 : 0.025),
        borderRadius: BorderRadius.circular(AppRadii.standard * 2),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.10 : 0.07),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(AppRadii.standard * 1.4),
              ),
              child: SizedBox.square(
                dimension: 48,
                child: Icon(icon, color: color, size: AppIconSizes.large),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        value,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
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

class _ProgressStatCard extends StatelessWidget {
  const _ProgressStatCard({required this.data});

  final _ProgressStatData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.lerp(
          colorScheme.surface,
          data.color,
          isDark ? 0.05 : 0.025,
        ),
        borderRadius: BorderRadius.circular(AppRadii.standard * 2),
        border: Border.all(color: data.color.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: data.color.withValues(alpha: isDark ? 0.10 : 0.07),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(AppRadii.standard * 1.4),
              ),
              child: SizedBox.square(
                dimension: 44,
                child: Icon(
                  data.icon,
                  color: data.color,
                  size: AppIconSizes.large,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    data.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.18,
                      fontWeight: FontWeight.w700,
                    ),
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

class _ProgressStatData {
  const _ProgressStatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}
