import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_edition.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/feedback/app_feedback.dart';
import '../../../../shared/monetization/ads_view_model.dart';
import '../../../../shared/monetization/premium_sheet.dart';
import '../../domain/entities/puzzle.dart';
import '../../../../shared/widgets/app_design_system.dart';
import '../l10n/puzzle_localizations.dart';
import '../viewmodels/puzzle_state.dart';
import '../viewmodels/puzzle_view_model.dart';
import '../widgets/chess_board.dart';

class PuzzlePage extends ConsumerStatefulWidget {
  const PuzzlePage({
    super.key,
    this.initialPuzzleIndex = 0,
    this.showSelector = true,
    this.awardsXpOnCompletion = true,
    this.onCompleted,
  });

  final int initialPuzzleIndex;
  final bool showSelector;
  final bool awardsXpOnCompletion;
  final ValueChanged<int>? onCompleted;

  @override
  ConsumerState<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends ConsumerState<PuzzlePage> {
  bool _completionReported = false;
  bool _initialPuzzleApplied = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyInitialPuzzleIfReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<PuzzleState>>(puzzleViewModelProvider, (
      previous,
      next,
    ) {
      final previousState = previous?.value;
      final nextState = next.value;

      if (nextState == null) {
        return;
      }

      _applyInitialPuzzleIfReady();

      if (previousState != null &&
          previousState.selectedPuzzleIndex != nextState.selectedPuzzleIndex) {
        _completionReported = false;
      }

      if (previousState != null &&
          nextState.selectedSquare != null &&
          previousState.selectedSquare != nextState.selectedSquare) {
        final selectionCameFromHint =
            nextState.hintUsed && !previousState.hintUsed;
        if (!selectionCameFromHint) {
          unawaited(AppFeedback.selectPiece());
        }
      }

      if (nextState.status == PuzzleStatus.failed &&
          previousState?.status != PuzzleStatus.failed) {
        unawaited(AppFeedback.failure());
        _showFailureSheet();
      }

      if (nextState.status == PuzzleStatus.completed &&
          previousState?.status != PuzzleStatus.completed) {
        unawaited(
          _playMoveSequence(
            _appliedMoveCount(previousState, nextState),
            playSuccess: true,
          ),
        );

        if (!_completionReported) {
          _completionReported = true;
          widget.onCompleted?.call(nextState.selectedPuzzleIndex);
        }

        _showSuccessSheet(nextState);
        return;
      }

      final appliedMoveCount = _appliedMoveCount(previousState, nextState);
      if (appliedMoveCount > 0 && nextState.status == PuzzleStatus.playing) {
        unawaited(_playMoveSequence(appliedMoveCount));
      }
    });

    final asyncState = ref.watch(puzzleViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: asyncState.when(
          data: (state) =>
              _PuzzleContent(state: state, showSelector: widget.showSelector),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(context.l10n.puzzlesLoadError(error.toString())),
            ),
          ),
        ),
      ),
    );
  }

  static int _appliedMoveCount(
    PuzzleState? previousState,
    PuzzleState nextState,
  ) {
    if (previousState == null ||
        previousState.selectedPuzzleIndex != nextState.selectedPuzzleIndex) {
      return 0;
    }

    return (nextState.currentMoveIndex - previousState.currentMoveIndex).clamp(
      0,
      nextState.puzzle.moves.length,
    );
  }

  static Future<void> _playMoveSequence(
    int moveCount, {
    bool playSuccess = false,
  }) async {
    for (var index = 0; index < moveCount; index++) {
      await AppFeedback.movePiece();
      await Future<void>.delayed(const Duration(milliseconds: 210));
    }

    if (playSuccess) {
      await AppFeedback.success();
    }
  }

  void _applyInitialPuzzleIfReady() {
    if (!mounted || _initialPuzzleApplied) {
      return;
    }

    final current = ref.read(puzzleViewModelProvider).value;
    if (current == null) {
      return;
    }

    _initialPuzzleApplied = true;
    ref
        .read(puzzleViewModelProvider.notifier)
        .selectPuzzle(widget.initialPuzzleIndex);
  }

  Future<void> _showFailureSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.transparent,
      builder: (context) => const _FailureBottomSheet(),
    );
  }

  Future<void> _showSuccessSheet(PuzzleState state) async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.transparent,
      builder: (context) => _SuccessBottomSheet(
        state: state,
        awardsXp: widget.awardsXpOnCompletion,
      ),
    );
  }
}

class _PuzzleContent extends ConsumerWidget {
  const _PuzzleContent({required this.state, required this.showSelector});

  final PuzzleState state;
  final bool showSelector;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(puzzleViewModelProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth
            .clamp(0, AppSizes.contentMaxWidth)
            .toDouble();

        return Center(
          child: SizedBox(
            width: maxWidth,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _PuzzleTopBar(
                      state: state,
                      onHint: () {
                        viewModel.showHint();
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  sliver: SliverToBoxAdapter(child: _PuzzleMeta(state: state)),
                ),
                if (showSelector)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _PuzzleSelector(
                        state: state,
                        onSelected: viewModel.selectPuzzle,
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: ChessBoard(
                      pieces: state.pieces,
                      selectedSquare: state.selectedSquare,
                      legalTargets: state.legalTargets,
                      orientation: _boardOrientationFor(state.puzzle),
                      onSquareTap: viewModel.onSquareTapped,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _StatusBanner(state: state),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

ChessBoardOrientation _boardOrientationFor(Puzzle puzzle) {
  final orientation = puzzle.orientation.toLowerCase().trim();
  if (orientation == 'black' || orientation == 'b') {
    return ChessBoardOrientation.black;
  }

  return ChessBoardOrientation.white;
}

class _PuzzleTopBar extends StatelessWidget {
  const _PuzzleTopBar({required this.state, required this.onHint});

  final PuzzleState state;
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progressValue = state.totalPlayerMoves == 0
        ? 0.0
        : state.completedPlayerMoves / state.totalPlayerMoves;

    return Row(
      children: [
        AppToolbarIconButton(
          tooltip: context.l10n.backTooltip,
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: AppSizes.progressToolbar,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                state.status == PuzzleStatus.completed
                    ? AppColors.success
                    : AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${state.completedPlayerMoves}/${state.totalPlayerMoves}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        AppToolbarIconButton(
          tooltip: state.hintUsed
              ? context.l10n.hintUsedTooltip
              : context.l10n.hintTooltip,
          icon: Icons.lightbulb_outline_rounded,
          onPressed: state.canInteract && !state.hintUsed ? onHint : null,
        ),
      ],
    );
  }
}

class _PuzzleMeta extends StatelessWidget {
  const _PuzzleMeta({required this.state});

  final PuzzleState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.levelLabel(state.puzzle.level),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: AppFontSizes.sectionTitle,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                context.l10n.puzzleMeta(
                  state.puzzle.world,
                  state.puzzle.chapter,
                  state.puzzle.level,
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadii.standard),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              localizedPuzzleTheme(context.l10n, state.puzzle.theme),
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.state});

  final PuzzleState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (state.status) {
      PuzzleStatus.completed => AppColors.success,
      PuzzleStatus.failed => AppColors.danger,
      PuzzleStatus.playing => colorScheme.onSurface,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.standard),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              _statusIcon(state.status),
              color: color,
              size: AppIconSizes.status,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                state.localizedMessage(context.l10n),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _statusIcon(PuzzleStatus status) {
    return switch (status) {
      PuzzleStatus.completed => Icons.check_circle_rounded,
      PuzzleStatus.failed => Icons.cancel_rounded,
      PuzzleStatus.playing => Icons.bolt_rounded,
    };
  }
}

class _PuzzleSelector extends StatelessWidget {
  const _PuzzleSelector({required this.state, required this.onSelected});

  final PuzzleState state;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < state.puzzles.length; index++) ...[
            ChoiceChip(
              label: Text(context.l10n.levelLabel(index + 1)),
              selected: state.selectedPuzzleIndex == index,
              onSelected: (_) => onSelected(index),
              showCheckmark: false,
              selectedColor: colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: state.selectedPuzzleIndex == index
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.standard),
                side: BorderSide(
                  color: state.selectedPuzzleIndex == index
                      ? AppColors.primary
                      : colorScheme.outlineVariant,
                ),
              ),
            ),
            if (index != state.puzzles.length - 1)
              const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _FailureBottomSheet extends ConsumerWidget {
  const _FailureBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _FeedbackSheetFrame(
      accentColor: AppColors.danger,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _FeedbackIcon(
                icon: Icons.close_rounded,
                color: AppColors.danger,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.wrongMoveTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: AppFontSizes.sectionTitle,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.moveNotPlayed,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () {
              ref.read(puzzleViewModelProvider.notifier).retryCurrentMove();
              Navigator.of(context).pop();
            },
            child: Text(context.l10n.retryMove),
          ),
          const SizedBox(height: AppSpacing.xs),
          OutlinedButton(
            onPressed: () {
              ref.read(puzzleViewModelProvider.notifier).resetPuzzle();
              Navigator.of(context).pop();
            },
            child: Text(context.l10n.restartLevel),
          ),
        ],
      ),
    );
  }
}

class _SuccessBottomSheet extends ConsumerStatefulWidget {
  const _SuccessBottomSheet({required this.state, required this.awardsXp});

  final PuzzleState state;
  final bool awardsXp;

  @override
  ConsumerState<_SuccessBottomSheet> createState() =>
      _SuccessBottomSheetState();
}

class _SuccessBottomSheetState extends ConsumerState<_SuccessBottomSheet> {
  bool _continuing = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = widget.awardsXp
        ? context.l10n.perfectTitle
        : context.l10n.reviewCompletedTitle;
    final description = widget.awardsXp
        ? context.l10n.levelCompletedWithXp(widget.state.puzzle.level, 10)
        : context.l10n.levelReviewedXpCollected(widget.state.puzzle.level);

    return _FeedbackSheetFrame(
      accentColor: AppColors.success,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _FeedbackIcon(
                icon: Icons.check_rounded,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: AppFontSizes.sectionTitle,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: 1,
            minHeight: AppSizes.progressRegular,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: _continuing ? null : _continueToMap,
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            child: _continuing
                ? const SizedBox.square(
                    dimension: AppIconSizes.small,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text(context.l10n.continueButton),
          ),
        ],
      ),
    );
  }

  Future<void> _continueToMap() async {
    setState(() => _continuing = true);
    final premium = ref.read(appEditionProvider) == AppEdition.premium;
    final ads = ref.read(adsViewModelProvider.notifier);
    final adWasShown = await ads.showAfterLevelIfEligible(
      isNewCompletion: widget.awardsXp,
      isPremium: premium,
    );

    if (!mounted) {
      return;
    }
    final isStillPremium = ref.read(appEditionProvider) == AppEdition.premium;
    final shouldShowPremiumOffer =
        adWasShown &&
        await ads.shouldShowPremiumOfferAfterAd(isPremium: isStillPremium);
    if (!mounted) {
      return;
    }
    if (shouldShowPremiumOffer) {
      await showPremiumSheet(context, variant: PremiumSheetVariant.afterAd);
      if (!mounted) {
        return;
      }
    }
    final navigator = Navigator.of(context);
    navigator.pop();
    await navigator.maybePop();
  }
}

class _FeedbackSheetFrame extends StatelessWidget {
  const _FeedbackSheetFrame({required this.accentColor, required this.child});

  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.standard),
        ),
        border: Border(top: BorderSide(color: accentColor, width: 5)),
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
          child: child,
        ),
      ),
    );
  }
}

class _FeedbackIcon extends StatelessWidget {
  const _FeedbackIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.standard),
      ),
      child: SizedBox.square(
        dimension: AppSizes.feedbackIcon,
        child: Icon(icon, color: color, size: AppIconSizes.extraLarge),
      ),
    );
  }
}
