import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/feedback/app_feedback.dart';
import '../../../../shared/feedback/app_toast.dart';
import '../../../puzzles/presentation/l10n/puzzle_localizations.dart';
import '../../../puzzles/presentation/pages/puzzle_page.dart';
import '../../domain/entities/campaign_level_node.dart';
import '../../domain/entities/campaign_world.dart';
import '../viewmodels/campaign_map_state.dart';
import '../viewmodels/campaign_map_view_model.dart';
import '../viewmodels/campaign_progress_notifier.dart';
import '../viewmodels/campaign_progress_state.dart';
import '../widgets/campaign_path.dart';
import '../widgets/next_world_button.dart';

class CampaignPage extends ConsumerStatefulWidget {
  const CampaignPage({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  ConsumerState<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends ConsumerState<CampaignPage> {
  ProviderSubscription<AsyncValue<CampaignProgressState>>?
  _progressSubscription;
  bool _initialWorldSynced = false;

  @override
  void initState() {
    super.initState();

    _progressSubscription = ref.listenManual(campaignProgressProvider, (
      _,
      next,
    ) {
      final progress = next.value;
      if (_initialWorldSynced || progress == null) {
        return;
      }

      _syncInitialWorld(progress.currentLevelIndex);
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _progressSubscription?.close();
    super.dispose();
  }

  void _syncInitialWorld(int currentLevelIndex) {
    Future<void>(() {
      if (!mounted || _initialWorldSynced) {
        return;
      }

      _initialWorldSynced = true;
      ref
          .read(selectedWorldProvider.notifier)
          .selectCurrentLevelWorld(currentLevelIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(campaignMapViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: asyncState.when(
          data: (state) => _CampaignContent(
            state: state,
            showBackButton: widget.showBackButton,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(context.l10n.campaignLoadError(error.toString())),
            ),
          ),
        ),
      ),
    );
  }
}

class _CampaignContent extends ConsumerStatefulWidget {
  const _CampaignContent({required this.state, required this.showBackButton});

  final CampaignMapState state;
  final bool showBackButton;

  @override
  ConsumerState<_CampaignContent> createState() => _CampaignContentState();
}

class _CampaignContentState extends ConsumerState<_CampaignContent> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth
            .clamp(0, AppSizes.contentMaxWidth)
            .toDouble();

        return Center(
          child: SizedBox(
            width: maxWidth,
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              radius: const Radius.circular(AppRadii.pill),
              thickness: 5,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (widget.showBackButton)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            key: const ValueKey('campaign-back-button'),
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: Text(context.l10n.backTooltip),
                          ),
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _WorldToolbar(state: widget.state),
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
                      child: CampaignPath(
                        nodes: widget.state.nodes,
                        onNodeTap: (node) => _handleNodeTap(context, ref, node),
                      ),
                    ),
                  ),
                  if (!widget.state.isLastWorld)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        96,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: NextWorldButton(
                          enabled: widget.state.canGoToNextWorld,
                          targetWorld: widget.state.worldIndex + 1,
                          completedLevels: widget.state.completedCount,
                          totalLevels: widget.state.totalPlayableLevels,
                          onTap: () =>
                              _handleNextWorldTap(context, ref, widget.state),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleNextWorldTap(
    BuildContext context,
    WidgetRef ref,
    CampaignMapState state,
  ) {
    if (state.canGoToNextWorld) {
      ref.read(selectedWorldProvider.notifier).select(state.worldIndex + 1);
      unawaited(
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
      );
      return;
    }

    unawaited(AppFeedback.failure());

    AppToast.showError(context, context.l10n.completeWorldToUnlockMessage);
  }

  void _handleNodeTap(
    BuildContext context,
    WidgetRef ref,
    CampaignLevelNode node,
  ) {
    if (node.status == CampaignLevelNodeStatus.current) {
      unawaited(AppFeedback.levelTap());
    }

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.transparent,
        builder: (sheetContext) => _LevelPreviewSheet(
          node: node,
          state: widget.state,
          onStart: node.isPlayable
              ? () {
                  Navigator.of(sheetContext).pop();
                  _openPuzzle(context, ref, node);
                }
              : null,
        ),
      ),
    );
  }

  void _openPuzzle(
    BuildContext context,
    WidgetRef ref,
    CampaignLevelNode node,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PuzzlePage(
          initialPuzzleIndex: node.index,
          showSelector: false,
          awardsXpOnCompletion:
              node.status != CampaignLevelNodeStatus.completed,
          onCompleted: (levelIndex) {
            unawaited(
              ref
                  .read(campaignProgressProvider.notifier)
                  .completeLevel(levelIndex),
            );
          },
        ),
      ),
    );
  }
}

class _WorldToolbar extends ConsumerWidget {
  const _WorldToolbar({required this.state});

  final CampaignMapState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.standard * 2),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 108,
              child: _WorldEmblem(world: campaignWorlds[state.worldIndex - 1]),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    key: const ValueKey('world-selector'),
                    borderRadius: BorderRadius.circular(AppRadii.standard),
                    onTap: () => _showWorldSelector(context, ref, state),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            context.l10n.worldLabel(state.worldIndex),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colorScheme.onSurface,
                          size: AppIconSizes.standard,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    localizedPuzzleTheme(context.l10n, state.worldTheme),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${state.earnedWorldXp}/${state.totalWorldXp} XP',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: state.worldXpProgress,
                          minHeight: AppSizes.progressThin,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
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

class _WorldEmblem extends StatelessWidget {
  const _WorldEmblem({required this.world});

  final CampaignWorld world;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.25,
      child: Image.asset(
        world.emblemAsset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        semanticLabel: context.l10n.worldLabel(world.index),
      ),
    );
  }
}

Future<void> _showWorldSelector(
  BuildContext context,
  WidgetRef ref,
  CampaignMapState state,
) async {
  final colorScheme = Theme.of(context).colorScheme;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: colorScheme.surface,
    builder: (sheetContext) => SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          itemCount: campaignWorlds.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xxs),
          itemBuilder: (context, index) {
            final world = campaignWorlds[index];
            final unlocked = state.isWorldUnlocked(world.index);
            final selected = state.worldIndex == world.index;

            return ListTile(
              key: ValueKey('world-option-${world.index}'),
              selected: selected,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.standard),
              ),
              leading: _WorldSelectorEmblem(
                world: world,
                unlocked: unlocked,
                selected: selected,
              ),
              title: Text(
                context.l10n.worldLabel(world.index),
                style: unlocked
                    ? null
                    : TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              subtitle: Text(
                '${localizedPuzzleTheme(context.l10n, world.theme)}'
                ' • ${localizedDifficulty(context.l10n, world.difficultyBand)}',
                style: unlocked
                    ? null
                    : TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              trailing: Icon(
                !unlocked
                    ? Icons.lock_rounded
                    : selected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: unlocked ? null : colorScheme.onSurfaceVariant,
              ),
              onTap: () {
                ref.read(selectedWorldProvider.notifier).select(world.index);
                Navigator.of(sheetContext).pop();
              },
            );
          },
        ),
      ),
    ),
  );
}

class _WorldSelectorEmblem extends StatelessWidget {
  const _WorldSelectorEmblem({
    required this.world,
    required this.unlocked,
    required this.selected,
  });

  final CampaignWorld world;
  final bool unlocked;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: selected
            ? Border.all(color: colorScheme.primary, width: 2)
            : null,
      ),
      child: SizedBox.square(
        dimension: 48,
        child: Opacity(
          opacity: unlocked ? 1 : 0.55,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxs),
            child: Image.asset(
              world.emblemAsset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              semanticLabel: context.l10n.worldLabel(world.index),
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelPreviewSheet extends StatelessWidget {
  const _LevelPreviewSheet({
    required this.node,
    required this.state,
    required this.onStart,
  });

  final CampaignLevelNode node;
  final CampaignMapState state;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final completed = node.status == CampaignLevelNodeStatus.completed;
    final locked = !node.isPlayable;
    final puzzle = node.puzzle;
    final title = locked
        ? context.l10n.lockedLevelTitle(node.numberInWorld)
        : completed
        ? context.l10n.reviewLevelTitle(node.numberInWorld)
        : context.l10n.levelLabel(node.numberInWorld);
    final actionLabel = locked
        ? context.l10n.lockedLevelAction
        : completed
        ? context.l10n.reviewLevelAction
        : context.l10n.startWithXp(CampaignMapState.xpPerLevel);
    final description = locked
        ? context.l10n.completePreviousLevelsToUnlock
        : completed
        ? context.l10n.xpAlreadyCollectedDescription
        : context.l10n.completeToAddXpDescription;
    final theme = puzzle == null
        ? context.l10n.comingSoon
        : localizedPuzzleTheme(context.l10n, puzzle.theme);

    final colorScheme = Theme.of(context).colorScheme;
    final sheetColor = locked ? colorScheme.surface : AppColors.primary;
    final foregroundColor = locked ? colorScheme.onSurface : AppColors.white;
    final secondaryColor = locked
        ? colorScheme.onSurfaceVariant
        : AppColors.primaryOnDark;
    final chipColor = locked
        ? colorScheme.surfaceContainerHighest
        : AppColors.whiteOverlay15;
    final chipBorderColor = locked
        ? colorScheme.outlineVariant
        : AppColors.whiteBorder20;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: sheetColor,
        border: locked
            ? Border(top: BorderSide(color: colorScheme.outlineVariant))
            : null,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.standard),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(AppRadii.standard),
                    ),
                    child: SizedBox.square(
                      dimension: AppSizes.feedbackIcon,
                      child: Icon(
                        locked
                            ? Icons.lock_rounded
                            : completed
                            ? Icons.check_rounded
                            : Icons.play_arrow_rounded,
                        color: locked ? AppColors.danger : foregroundColor,
                        size: AppIconSizes.display,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: foregroundColor,
                                fontSize: AppFontSizes.sectionTitle,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          context.l10n.worldTheme(state.worldIndex, theme),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: secondaryColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _PreviewChip(
                      icon: Icons.flag_rounded,
                      label: context.l10n.levelProgress(
                        node.numberInWorld,
                        state.totalPlayableLevels,
                      ),
                      foregroundColor: foregroundColor,
                      backgroundColor: chipColor,
                      borderColor: chipBorderColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _PreviewChip(
                      icon: locked
                          ? Icons.lock_outline_rounded
                          : completed
                          ? Icons.verified_rounded
                          : Icons.bolt_rounded,
                      label: locked
                          ? context.l10n.lockedLevelAction
                          : completed
                          ? context.l10n.xpCollected
                          : context.l10n.xpAmount(CampaignMapState.xpPerLevel),
                      foregroundColor: locked
                          ? AppColors.danger
                          : foregroundColor,
                      backgroundColor: chipColor,
                      borderColor: chipBorderColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: secondaryColor),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: locked
                      ? colorScheme.surfaceContainerHighest
                      : AppColors.white,
                  foregroundColor: locked
                      ? colorScheme.onSurfaceVariant
                      : AppColors.primaryDark,
                  disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                  disabledForegroundColor: colorScheme.onSurfaceVariant,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (locked) ...[
                      const Icon(Icons.lock_rounded, size: AppIconSizes.small),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Text(actionLabel),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({
    required this.icon,
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  final IconData icon;
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.standard),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: foregroundColor, size: AppIconSizes.small),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foregroundColor,
                  fontSize: AppFontSizes.compactLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
