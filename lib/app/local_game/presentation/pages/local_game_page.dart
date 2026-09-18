import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_edition.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/chess/chess_asset_paths.dart';
import '../../../../shared/chess/promotion_choice_sheet.dart';
import '../../../../shared/feedback/app_feedback.dart';
import '../../../../shared/monetization/ads_view_model.dart';
import '../../../../shared/monetization/premium_sheet.dart';
import '../../../campaign/presentation/viewmodels/campaign_progress_view_model.dart';
import '../../../progress/presentation/viewmodels/player_progress_view_model.dart';
import '../../../puzzles/presentation/widgets/chess_board.dart';
import '../../../../shared/widgets/app_design_system.dart';
import '../viewmodels/local_game_view_model.dart';
import '../viewmodels/local_game_state.dart';

const _localLastMoveAccent = AppColors.primary;
const _localFlipBoardAccent = Color(0xFF0EA5E9);

class LocalGamePage extends ConsumerStatefulWidget {
  const LocalGamePage({super.key});

  @override
  ConsumerState<LocalGamePage> createState() => _LocalGamePageState();
}

class _LocalGamePageState extends ConsumerState<LocalGamePage> {
  bool _activityReported = false;
  bool _finishAdHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref.invalidate(localGameViewModelProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LocalGameState>(localGameViewModelProvider, (previous, next) {
      if (previous != null &&
          next.selectedSquare != null &&
          previous.selectedSquare != next.selectedSquare) {
        unawaited(AppFeedback.selectPiece());
      }

      if (previous != null && next.moveCount > previous.moveCount) {
        if (!previous.inCheck &&
            next.inCheck &&
            next.status == LocalGameStatus.playing) {
          unawaited(AppFeedback.check());
        } else {
          unawaited(AppFeedback.movePiece());
        }
      }

      if (previous?.status == LocalGameStatus.playing &&
          next.status != LocalGameStatus.playing) {
        unawaited(AppFeedback.success());
        if (!_finishAdHandled) {
          _finishAdHandled = true;
          unawaited(
            ref
                .read(playerProgressViewModelProvider.notifier)
                .recordLocalGameFinished(
                  winner: next.winner,
                  draw: next.status == LocalGameStatus.draw,
                ),
          );
          unawaited(_showAdAfterFinishedGame());
        }
      }

      if (previous != null &&
          previous.status != LocalGameStatus.playing &&
          next.status == LocalGameStatus.playing) {
        _finishAdHandled = false;
      }

      if (!_activityReported && next.qualifiesForDailyActivity) {
        _activityReported = true;
        unawaited(
          ref.read(campaignProgressViewModelProvider.notifier).recordActivity(),
        );
      }
    });

    final state = ref.watch(localGameViewModelProvider);
    final viewModel = ref.read(localGameViewModelProvider.notifier);

    return Scaffold(
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
              child: _LocalGameTopBar(
                canShowLastMove: state.lastMove != null,
                onReset: () {
                  unawaited(_confirmResetGame(viewModel.resetGame));
                },
                onFlipBoard: viewModel.toggleBoard,
                onShowLastMove: viewModel.showLastMovePreview,
              ),
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
              child: _LocalGameStatusCard(state: state),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: ChessBoard(
                pieces: state.pieces,
                selectedSquare: state.selectedSquare,
                legalTargets: state.legalTargets,
                orientation: state.boardFlipped
                    ? ChessBoardOrientation.black
                    : ChessBoardOrientation.white,
                highlightedMove: state.showLastMove ? state.lastMove : null,
                onSquareTap: (square) {
                  unawaited(_onSquareTapped(viewModel, square));
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }

  Future<void> _onSquareTapped(
    LocalGameViewModel viewModel,
    String square,
  ) async {
    if (!viewModel.isSelectedMovePromotion(square)) {
      viewModel.onSquareTapped(square);
      return;
    }

    final promotion = await showPromotionChoiceSheet(
      context,
      color: ref.read(localGameViewModelProvider).turn,
    );
    if (!mounted || promotion == null) {
      return;
    }

    ref
        .read(localGameViewModelProvider.notifier)
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
    final adWasShown = await ads.showAfterLocalGameIfEligible(
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
    }
  }
}

class _LocalGameTopBar extends StatelessWidget {
  const _LocalGameTopBar({
    required this.canShowLastMove,
    required this.onReset,
    required this.onFlipBoard,
    required this.onShowLastMove,
  });

  final bool canShowLastMove;
  final VoidCallback onReset;
  final VoidCallback onFlipBoard;
  final VoidCallback onShowLastMove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return AppSurface(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppToolbarIconButton(
                key: const ValueKey('local-game-back-button'),
                tooltip: context.l10n.backTooltip,
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => Navigator.of(context).maybePop(),
                iconSize: AppIconSizes.status,
                backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.55,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  context.l10n.localGameTitle,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final flipButton = FilledButton.tonalIcon(
                key: const ValueKey('local-game-flip-board-button'),
                style: FilledButton.styleFrom(
                  backgroundColor: _localFlipBoardAccent,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size.fromHeight(
                    AppSizes.minimumButtonHeight,
                  ),
                ),
                onPressed: onFlipBoard,
                icon: const Icon(Icons.screen_rotation_alt_rounded),
                label: Text(
                  context.l10n.localGameFlipBoardAction,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
              final resetButton = OutlinedButton.icon(
                key: const ValueKey('local-game-reset-button'),
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
              final lastMoveButton = FilledButton.tonalIcon(
                key: const ValueKey('local-game-show-last-move-button'),
                style: FilledButton.styleFrom(
                  backgroundColor: _localLastMoveAccent,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: isDark ? 0.62 : 0.72),
                  disabledForegroundColor: colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.46),
                  minimumSize: const Size.fromHeight(
                    AppSizes.minimumButtonHeight,
                  ),
                ),
                onPressed: canShowLastMove ? onShowLastMove : null,
                icon: const Icon(Icons.replay_rounded),
                label: Text(
                  context.l10n.showLastMoveAction,
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
                    flipButton,
                    const SizedBox(height: AppSpacing.sm),
                    resetButton,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  lastMoveButton,
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(child: flipButton),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: resetButton),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LocalGameStatusCard extends StatelessWidget {
  const _LocalGameStatusCard({required this.state});

  final LocalGameState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final side = _sideLabel(context, state.turn);
    final title = switch (state.status) {
      LocalGameStatus.checkmate => context.l10n.localGameCheckmateTitle,
      LocalGameStatus.draw => context.l10n.localGameDrawTitle,
      LocalGameStatus.playing =>
        state.inCheck
            ? context.l10n.localGameCheckTitle
            : context.l10n.localGameTurnTitle(side),
    };
    final description = switch (state.status) {
      LocalGameStatus.checkmate => context.l10n.localGameWinnerLabel(
        _sideLabel(context, state.winner!),
      ),
      LocalGameStatus.draw => context.l10n.localGameDrawDescription,
      LocalGameStatus.playing =>
        state.inCheck
            ? context.l10n.localGameCheckTurnDescription(side)
            : context.l10n.localGameReadyMessage,
    };
    final icon = switch (state.status) {
      LocalGameStatus.checkmate => Icons.emoji_events_rounded,
      LocalGameStatus.draw => Icons.handshake_rounded,
      LocalGameStatus.playing =>
        state.inCheck
            ? Icons.warning_amber_rounded
            : Icons.sports_esports_rounded,
    };
    final accentColor = switch (state.status) {
      LocalGameStatus.checkmate => AppColors.success,
      LocalGameStatus.draw => colorScheme.onSurfaceVariant,
      LocalGameStatus.playing =>
        state.inCheck
            ? AppColors.danger
            : state.turn == ChessPieceColor.white
            ? AppColors.primary
            : colorScheme.onSurface,
    };
    final isHighAlert =
        state.inCheck || state.status == LocalGameStatus.checkmate;
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

  static String _sideLabel(BuildContext context, ChessPieceColor side) {
    return switch (side) {
      ChessPieceColor.white => context.l10n.localGameWhiteSide,
      ChessPieceColor.black => context.l10n.localGameBlackSide,
    };
  }
}
