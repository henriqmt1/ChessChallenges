import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_edition.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/chess/chess_asset_paths.dart';
import '../../../../shared/chess/game_exit_guard.dart';
import '../../../../shared/chess/promotion_choice_sheet.dart';
import '../../../../shared/feedback/app_feedback.dart';
import '../../../../shared/monetization/ads_view_model.dart';
import '../../../../shared/monetization/premium_sheet.dart';
import '../../../campaign/presentation/viewmodels/campaign_progress_view_model.dart';
import '../../../progress/presentation/viewmodels/player_progress_view_model.dart';
import '../../../../shared/chess/chess_board.dart';
import '../../domain/bot_difficulty.dart';
import '../viewmodels/bot_game_view_model.dart';
import '../viewmodels/bot_game_state.dart';
import '../../../../shared/widgets/app_design_system.dart';

const _botBeginnerAccent = AppColors.localGameAccent;
const _botIntermediateAccent = AppColors.objectiveAccent;
const _botAdvancedAccent = AppColors.botAccent;
const _botChooserAccent = AppColors.botAccent;

class BotGamePage extends ConsumerStatefulWidget {
  const BotGamePage({super.key});

  @override
  ConsumerState<BotGamePage> createState() => _BotGamePageState();
}

class _BotGamePageState extends ConsumerState<BotGamePage> {
  bool _activityReported = false;
  bool _finishAdHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref.invalidate(botGameViewModelProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BotGameState>(botGameViewModelProvider, (previous, next) {
      if (previous != null &&
          next.selectedSquare != null &&
          previous.selectedSquare != next.selectedSquare) {
        unawaited(AppFeedback.selectPiece());
      }

      if (previous != null && next.moveCount > previous.moveCount) {
        if (!previous.inCheck &&
            next.inCheck &&
            next.status == BotGameStatus.playing) {
          unawaited(AppFeedback.check());
        } else {
          unawaited(AppFeedback.movePiece());
        }
      }

      if (previous?.status == BotGameStatus.playing &&
          next.status != BotGameStatus.playing) {
        if (next.winner == ChessPieceColor.white) {
          unawaited(AppFeedback.success());
        } else if (next.status == BotGameStatus.checkmate) {
          unawaited(AppFeedback.check());
        }

        if (!_finishAdHandled) {
          _finishAdHandled = true;
          final difficulty = next.difficulty;
          if (difficulty != null) {
            unawaited(
              ref
                  .read(playerProgressViewModelProvider.notifier)
                  .recordBotGameFinished(
                    difficulty: difficulty,
                    winner: next.winner,
                    draw: next.status == BotGameStatus.draw,
                  ),
            );
          }
          unawaited(_showAdAfterFinishedGame());
        }
      }

      if (previous != null &&
          previous.status != BotGameStatus.playing &&
          next.status == BotGameStatus.playing) {
        _finishAdHandled = false;
        _activityReported = false;
      }

      if (!_activityReported && next.qualifiesForDailyActivity) {
        _activityReported = true;
        unawaited(
          ref.read(campaignProgressViewModelProvider.notifier).recordActivity(),
        );
      }
    });

    final state = ref.watch(botGameViewModelProvider);
    final viewModel = ref.read(botGameViewModelProvider.notifier);

    return GameExitGuard(
      needsConfirmation:
          state.status == BotGameStatus.playing && state.moveCount > 0,
      onExit: state.isPlayingGame
          ? viewModel.returnToDifficultySelection
          : null,
      builder: (requestExit) => Scaffold(
        body: AppPageFrame(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: _BotGameTopBar(
                  state: state,
                  onBack: state.isPlayingGame ? requestExit : null,
                  onReset: state.isPlayingGame
                      ? () {
                          unawaited(_confirmResetGame(viewModel.resetGame));
                        }
                      : null,
                  onShowLastMove: state.isPlayingGame
                      ? viewModel.showLastMovePreview
                      : null,
                ),
              ),
            ),
            if (state.status == BotGameStatus.choosingDifficulty) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                sliver: SliverToBoxAdapter(
                  child: _DifficultySelector(onSelected: viewModel.startGame),
                ),
              ),
            ] else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(
                  child: _BotGameStatusCard(state: state),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverToBoxAdapter(
                  child: ChessBoard(
                    pieces: state.pieces,
                    selectedSquare: state.selectedSquare,
                    legalTargets: state.legalTargets,
                    orientation: ChessBoardOrientation.white,
                    highlightedMove: state.showLastMove ? state.lastMove : null,
                    onSquareTap: (square) {
                      unawaited(_onSquareTapped(viewModel, square));
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _onSquareTapped(
    BotGameViewModel viewModel,
    String square,
  ) async {
    if (!viewModel.isSelectedMovePromotion(square)) {
      viewModel.onSquareTapped(square);
      return;
    }

    final promotion = await showPromotionChoiceSheet(
      context,
      color: ref.read(botGameViewModelProvider).turn,
    );
    if (!mounted || promotion == null) {
      return;
    }

    ref
        .read(botGameViewModelProvider.notifier)
        .moveSelectedTo(square, promotion: promotion);
  }

  Future<void> _confirmResetGame(VoidCallback onConfirmed) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.localGameResetDialogTitle),
          content: Text(context.l10n.localGameResetDialogMessage),
          actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        AppSizes.minimumButtonHeight,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      context.l10n.localGameResetCancelAction,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size.fromHeight(
                        AppSizes.minimumButtonHeight,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      context.l10n.localGameResetConfirmAction,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    onConfirmed();
  }

  Future<void> _showAdAfterFinishedGame() async {
    final premium = ref.read(appEditionProvider) == AppEdition.premium;
    final ads = ref.read(adsViewModelProvider.notifier);
    final adWasShown = await ads.showAfterBotGameIfEligible(isPremium: premium);

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
    }
  }
}

class _BotGameTopBar extends StatelessWidget {
  const _BotGameTopBar({
    required this.state,
    required this.onBack,
    required this.onReset,
    required this.onShowLastMove,
  });

  final BotGameState state;
  final VoidCallback? onBack;
  final VoidCallback? onReset;
  final VoidCallback? onShowLastMove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurface(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppToolbarIconButton(
                key: const ValueKey('bot-game-back-button'),
                tooltip: context.l10n.backTooltip,
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: onBack,
                iconSize: AppIconSizes.status,
                backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.55,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  context.l10n.botGameTitle,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              if (state.difficulty != null) ...[
                const SizedBox(width: AppSpacing.xs),
                _DifficultyChip(difficulty: state.difficulty!),
              ],
            ],
          ),
          if (onReset != null) ...[
            const SizedBox(height: AppSpacing.sm),
            LayoutBuilder(
              builder: (context, constraints) {
                final lastMoveButton = FilledButton.tonalIcon(
                  key: const ValueKey('bot-game-show-last-move-button'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                      AppSizes.minimumButtonHeight,
                    ),
                  ),
                  onPressed: state.lastMove == null ? null : onShowLastMove,
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(
                    context.l10n.showLastMoveAction,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
                final resetButton = OutlinedButton.icon(
                  key: const ValueKey('bot-game-reset-button'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    minimumSize: const Size.fromHeight(
                      AppSizes.minimumButtonHeight,
                    ),
                  ),
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: Text(
                    context.l10n.localGameRestartButton,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );

                if (constraints.maxWidth < 380) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      lastMoveButton,
                      const SizedBox(height: AppSpacing.sm),
                      resetButton,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: lastMoveButton),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: resetButton),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  const _DifficultySelector({required this.onSelected});

  final ValueChanged<BotDifficulty> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.botGameChooseDifficultyTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          context.l10n.botGameChooseDifficultySubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _DifficultyCard(
          key: const ValueKey('bot-difficulty-beginner'),
          difficulty: BotDifficulty.beginner,
          title: context.l10n.botDifficultyBeginnerTitle,
          description: context.l10n.botDifficultyBeginnerDescription,
          icon: Icons.sentiment_satisfied_alt_rounded,
          onTap: onSelected,
        ),
        const SizedBox(height: AppSpacing.md),
        _DifficultyCard(
          key: const ValueKey('bot-difficulty-intermediate'),
          difficulty: BotDifficulty.intermediate,
          title: context.l10n.botDifficultyIntermediateTitle,
          description: context.l10n.botDifficultyIntermediateDescription,
          icon: Icons.psychology_alt_rounded,
          onTap: onSelected,
        ),
        const SizedBox(height: AppSpacing.md),
        _DifficultyCard(
          key: const ValueKey('bot-difficulty-advanced'),
          difficulty: BotDifficulty.advanced,
          title: context.l10n.botDifficultyAdvancedTitle,
          description: context.l10n.botDifficultyAdvancedDescription,
          icon: Icons.auto_awesome_rounded,
          onTap: onSelected,
        ),
      ],
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    super.key,
    required this.difficulty,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final BotDifficulty difficulty;
  final String title;
  final String description;
  final IconData icon;
  final ValueChanged<BotDifficulty> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = _difficultyAccentColor(difficulty);
    final isDark = colorScheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.standard * 2),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.standard * 2),
          onTap: () => onTap(difficulty),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isDark ? 0.18 : 0.12),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.18),
                    ),
                    borderRadius: BorderRadius.circular(
                      AppRadii.standard * 1.5,
                    ),
                  ),
                  child: SizedBox.square(
                    dimension: 56,
                    child: Icon(
                      icon,
                      color: accentColor,
                      size: AppIconSizes.large,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.l10n.botGameStartAction,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: accentColor,
                            size: AppIconSizes.small,
                          ),
                        ],
                      ),
                    ],
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

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({required this.difficulty});

  final BotDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final accentColor = _difficultyAccentColor(difficulty);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: accentColor.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          _difficultyLabel(context, difficulty),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _BotGameStatusCard extends StatelessWidget {
  const _BotGameStatusCard({required this.state});

  final BotGameState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = _title(context);
    final description = _description(context);
    final icon = _icon();
    final accentColor = _accentColor(colorScheme);
    final isHighAlert =
        state.inCheck || state.status == BotGameStatus.checkmate;
    final backgroundColor = isHighAlert
        ? accentColor
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.72);
    final foregroundColor = isHighAlert
        ? AppColors.white
        : colorScheme.onSurface;
    final secondaryColor = isHighAlert
        ? AppColors.white.withValues(alpha: 0.86)
        : colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.standard * 2),
        border: Border.all(
          color: isHighAlert
              ? AppColors.whiteBorder20
              : colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isHighAlert ? 0.28 : 0.12),
            blurRadius: isHighAlert ? 26 : 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: isHighAlert
                    ? AppColors.whiteOverlay15
                    : accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.standard * 1.5),
              ),
              child: SizedBox.square(
                dimension: isHighAlert ? 58 : 50,
                child: Icon(
                  icon,
                  color: isHighAlert ? AppColors.white : accentColor,
                  size: isHighAlert
                      ? AppIconSizes.display
                      : AppIconSizes.extraLarge,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: state.inCheck ? 0.8 : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: secondaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _title(BuildContext context) {
    return switch (state.status) {
      BotGameStatus.choosingDifficulty => context.l10n.botGameTitle,
      BotGameStatus.checkmate =>
        state.winner == ChessPieceColor.white
            ? context.l10n.botGameYouWonTitle
            : context.l10n.botGameBotWonTitle,
      BotGameStatus.draw => context.l10n.botGameDrawTitle,
      BotGameStatus.playing =>
        state.inCheck
            ? context.l10n.localGameCheckTitle
            : state.botThinking
            ? context.l10n.botGameThinkingTitle
            : context.l10n.botGameYourTurnTitle,
    };
  }

  String _description(BuildContext context) {
    return switch (state.status) {
      BotGameStatus.choosingDifficulty =>
        context.l10n.botGameChooseDifficultySubtitle,
      BotGameStatus.checkmate =>
        state.winner == ChessPieceColor.white
            ? context.l10n.botGameYouWonDescription
            : context.l10n.botGameBotWonDescription,
      BotGameStatus.draw => context.l10n.botGameDrawDescription,
      BotGameStatus.playing =>
        state.inCheck
            ? state.turn == ChessPieceColor.white
                  ? context.l10n.botGamePlayerInCheckDescription
                  : context.l10n.botGameBotInCheckDescription
            : state.botThinking
            ? context.l10n.botGameThinkingDescription
            : context.l10n.botGameReadyDescription,
    };
  }

  IconData _icon() {
    return switch (state.status) {
      BotGameStatus.choosingDifficulty => Icons.smart_toy_rounded,
      BotGameStatus.checkmate => Icons.emoji_events_rounded,
      BotGameStatus.draw => Icons.handshake_rounded,
      BotGameStatus.playing =>
        state.inCheck
            ? Icons.warning_amber_rounded
            : state.botThinking
            ? Icons.memory_rounded
            : Icons.touch_app_rounded,
    };
  }

  Color _accentColor(ColorScheme colorScheme) {
    return switch (state.status) {
      BotGameStatus.choosingDifficulty => _botChooserAccent,
      BotGameStatus.checkmate =>
        state.winner == ChessPieceColor.white
            ? AppColors.success
            : AppColors.danger,
      BotGameStatus.draw => colorScheme.onSurfaceVariant,
      BotGameStatus.playing =>
        state.inCheck
            ? AppColors.danger
            : state.botThinking
            ? colorScheme.onSurface
            : state.difficulty == null
            ? _botChooserAccent
            : _difficultyAccentColor(state.difficulty!),
    };
  }
}

Color _difficultyAccentColor(BotDifficulty difficulty) {
  return switch (difficulty) {
    BotDifficulty.beginner => _botBeginnerAccent,
    BotDifficulty.intermediate => _botIntermediateAccent,
    BotDifficulty.advanced => _botAdvancedAccent,
  };
}

String _difficultyLabel(BuildContext context, BotDifficulty difficulty) {
  return switch (difficulty) {
    BotDifficulty.beginner => context.l10n.botDifficultyBeginnerTitle,
    BotDifficulty.intermediate => context.l10n.botDifficultyIntermediateTitle,
    BotDifficulty.advanced => context.l10n.botDifficultyAdvancedTitle,
  };
}
