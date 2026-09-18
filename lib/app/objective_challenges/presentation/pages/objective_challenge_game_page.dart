import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/chess/chess_asset_paths.dart';
import '../../../../shared/chess/promotion_choice_sheet.dart';
import '../../../../shared/feedback/app_feedback.dart';
import '../../../../shared/feedback/app_toast.dart';
import '../../../progress/presentation/viewmodels/player_progress_view_model.dart';
import '../../domain/objective_challenge_level.dart';
import '../viewmodels/objective_challenge_game_view_model.dart';
import '../viewmodels/objective_challenge_game_state.dart';
import '../../../../shared/chess/chess_board.dart';
import '../../../../shared/widgets/app_design_system.dart';

class ObjectiveChallengeGamePage extends ConsumerStatefulWidget {
  const ObjectiveChallengeGamePage({super.key, required this.level});

  final ObjectiveChallengeLevel level;

  @override
  ConsumerState<ObjectiveChallengeGamePage> createState() =>
      _ObjectiveChallengeGamePageState();
}

class _ObjectiveChallengeGamePageState
    extends ConsumerState<ObjectiveChallengeGamePage> {
  bool _terminalSheetVisible = false;

  @override
  Widget build(BuildContext context) {
    final provider = objectiveChallengeGameViewModelProvider(widget.level);
    final state = ref.watch(provider);
    ref.listen<ObjectiveChallengeGameState>(provider, _onStateChanged);
    final colorScheme = Theme.of(context).colorScheme;

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
              child: AppPageHeader(
                title: 'Desafio ${widget.level.level}',
                subtitle:
                    widget.level.goal.type ==
                        ObjectiveChallengeGoalType.checkmate
                    ? 'Xeque-mate'
                    : 'Ganho de material',
                onBack: () => Navigator.of(context).pop(),
                trailing: AppToolbarIconButton(
                  tooltip: 'Reiniciar',
                  onPressed: () => ref.read(provider.notifier).resetSession(),
                  icon: Icons.restart_alt_rounded,
                  iconSize: AppIconSizes.status,
                ),
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
              child: _ObjectiveStatusCard(
                title: _statusTitle(state),
                description: _statusDescription(state),
                icon: _statusIcon(state),
                accentColor: _statusColor(state),
                objective: widget.level.objective,
                goalLabel: _goalLabel,
                moveLabel: _progressLabel(state),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            sliver: SliverToBoxAdapter(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.standard * 1.5),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: ChessBoard(
                    pieces: state.pieces,
                    selectedSquare: state.selectedSquare,
                    legalTargets: state.legalTargets,
                    highlightedMove: state.lastMove,
                    orientation:
                        widget.level.playerColor == ChessPieceColor.black
                        ? ChessBoardOrientation.black
                        : ChessBoardOrientation.white,
                    onSquareTap: _onSquareTapped,
                  ),
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
              child: _ObjectiveTipCard(playerColor: widget.level.playerColor),
            ),
          ),
        ],
      ),
    );
  }

  String get _goalLabel {
    if (widget.level.isMateInOne) {
      return 'Meta: mate em 1';
    }

    return switch (widget.level.goal.type) {
      ObjectiveChallengeGoalType.checkmate => 'Meta: dar xeque-mate',
      ObjectiveChallengeGoalType.materialGain =>
        'Meta: ganhar +${widget.level.goal.targetMaterialGain} de material',
    };
  }

  String _progressLabel(ObjectiveChallengeGameState state) {
    if (widget.level.isMateInOne) {
      return 'Tentativas: ${state.playerMoveCount}/${widget.level.oneStarLimit}';
    }

    return 'Jogadas: ${state.playerMoveCount}/${widget.level.oneStarLimit}';
  }

  String _statusTitle(ObjectiveChallengeGameState state) {
    return switch (state.status) {
      ObjectiveChallengeSessionStatus.completed => 'Objetivo concluído',
      ObjectiveChallengeSessionStatus.failed => 'Tentativas esgotadas',
      ObjectiveChallengeSessionStatus.playing =>
        state.botThinking
            ? 'Bot pensando...'
            : state.lastMateAttemptMissed
            ? 'Não foi mate'
            : state.inCheck
            ? 'Atenção: xeque'
            : widget.level.isMateInOne
            ? 'Ache o mate'
            : 'Sua vez',
    };
  }

  String _statusDescription(ObjectiveChallengeGameState state) {
    return switch (state.status) {
      ObjectiveChallengeSessionStatus.completed =>
        widget.level.isMateInOne
            ? 'Você encontrou o mate em ${_attemptText(state.playerMoveCount)} e ganhou ${state.earnedStars} estrelas.'
            : 'Você terminou em ${state.playerMoveCount} jogadas e ganhou ${state.earnedStars} estrelas.',
      ObjectiveChallengeSessionStatus.failed =>
        widget.level.isMateInOne
            ? 'As ${widget.level.oneStarLimit} tentativas acabaram. Reinicie e procure outro lance.'
            : 'O limite era ${widget.level.oneStarLimit} jogadas. Reinicie e tente uma linha melhor.',
      ObjectiveChallengeSessionStatus.playing =>
        state.botThinking
            ? 'O bot vai tentar defender como se fosse o avançado.'
            : state.lastMateAttemptMissed
            ? 'A posição voltou ao início. Você ainda tem ${_attemptText(_remainingAttempts(state))}.'
            : widget.level.isMateInOne
            ? 'Encontre o lance que dá xeque-mate agora.'
            : 'Procure cumprir a meta usando o menor número de jogadas.',
    };
  }

  IconData _statusIcon(ObjectiveChallengeGameState state) {
    return switch (state.status) {
      ObjectiveChallengeSessionStatus.completed => Icons.emoji_events_rounded,
      ObjectiveChallengeSessionStatus.failed => Icons.close_rounded,
      ObjectiveChallengeSessionStatus.playing =>
        state.botThinking
            ? Icons.psychology_rounded
            : state.lastMateAttemptMissed
            ? Icons.close_rounded
            : state.inCheck
            ? Icons.warning_rounded
            : Icons.flag_rounded,
    };
  }

  Color _statusColor(ObjectiveChallengeGameState state) {
    return switch (state.status) {
      ObjectiveChallengeSessionStatus.completed => AppColors.success,
      ObjectiveChallengeSessionStatus.failed => AppColors.danger,
      ObjectiveChallengeSessionStatus.playing =>
        state.lastMateAttemptMissed
            ? AppColors.danger
            : state.inCheck
            ? AppColors.fireActive
            : AppColors.primary,
    };
  }

  int _remainingAttempts(ObjectiveChallengeGameState state) {
    return (widget.level.oneStarLimit - state.playerMoveCount).clamp(
      0,
      widget.level.oneStarLimit,
    );
  }

  String _attemptText(int count) {
    return count == 1 ? '1 tentativa' : '$count tentativas';
  }

  Future<void> _onSquareTapped(String square) async {
    final provider = objectiveChallengeGameViewModelProvider(widget.level);
    final state = ref.read(provider);
    final controller = ref.read(provider.notifier);

    if (!state.canInteract(widget.level.playerColor)) {
      return;
    }

    final selectedSquare = state.selectedSquare;
    if (selectedSquare != null &&
        state.legalTargets.contains(square) &&
        controller.isSelectedMovePromotion(square)) {
      final promotion = await showPromotionChoiceSheet(
        context,
        color: widget.level.playerColor,
      );
      if (!mounted || promotion == null) {
        return;
      }

      controller.moveSelectedTo(square, promotion: promotion);
      return;
    }

    controller.onSquareTapped(square);
  }

  void _onStateChanged(
    ObjectiveChallengeGameState? previous,
    ObjectiveChallengeGameState next,
  ) {
    if (previous != null && next.moveSoundCount > previous.moveSoundCount) {
      unawaited(AppFeedback.movePiece());
    }

    if (previous != null &&
        next.missedMateAttemptCount > previous.missedMateAttemptCount) {
      unawaited(AppFeedback.failure());
      AppToast.showError(context, 'Esse lance não dá mate. Tente outro.');
    }

    if (previous?.status != ObjectiveChallengeSessionStatus.completed &&
        next.status == ObjectiveChallengeSessionStatus.completed) {
      unawaited(_handleCompletion(next));
    }

    if (previous?.status == ObjectiveChallengeSessionStatus.playing &&
        next.status == ObjectiveChallengeSessionStatus.failed) {
      unawaited(AppFeedback.failure());
      unawaited(_showFailureSheet(next));
    }
  }

  Future<void> _handleCompletion(ObjectiveChallengeGameState state) async {
    final stars = state.earnedStars;
    unawaited(AppFeedback.success());
    await ref
        .read(playerProgressViewModelProvider.notifier)
        .recordObjectiveStars(level: widget.level.level, stars: stars);

    if (!mounted || _terminalSheetVisible) {
      return;
    }

    _terminalSheetVisible = true;
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _ObjectiveResultSheet(
        success: true,
        title: 'Objetivo concluído!',
        description: widget.level.isMateInOne
            ? 'Você encontrou o mate em ${_attemptText(state.playerMoveCount)} e ganhou $stars estrelas.'
            : 'Você finalizou em ${state.playerMoveCount} jogadas e ganhou $stars estrelas.',
        stars: stars,
        scoring: widget.level.scoring,
        primaryLabel: 'Continuar',
        onPrimary: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
    _terminalSheetVisible = false;
  }

  Future<void> _showFailureSheet(ObjectiveChallengeGameState state) async {
    if (!mounted || _terminalSheetVisible) {
      return;
    }

    _terminalSheetVisible = true;
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _ObjectiveResultSheet(
        success: false,
        title: 'Falha no objetivo',
        description: widget.level.isMateInOne
            ? 'As ${widget.level.oneStarLimit} tentativas acabaram. Revise as fugas do rei e tente encontrar o mate.'
            : 'Você passou do limite de ${widget.level.oneStarLimit} jogadas ou deixou o bot escapar. Tente outra linha.',
        stars: 0,
        scoring: widget.level.scoring,
        primaryLabel: 'Tentar de novo',
        secondaryLabel: 'Sair',
        onPrimary: () {
          Navigator.of(context).pop();
          ref
              .read(
                objectiveChallengeGameViewModelProvider(widget.level).notifier,
              )
              .resetSession();
        },
        onSecondary: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
    _terminalSheetVisible = false;
  }
}

class _ObjectiveStatusCard extends StatelessWidget {
  const _ObjectiveStatusCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.objective,
    required this.goalLabel,
    required this.moveLabel,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String objective;
  final String goalLabel;
  final String moveLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.standard * 2),
        border: Border.all(color: accentColor.withValues(alpha: 0.32)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(
                      AppRadii.standard * 1.5,
                    ),
                  ),
                  child: SizedBox.square(
                    dimension: 48,
                    child: Icon(icon, color: accentColor),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              objective,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _ObjectiveChip(label: goalLabel, icon: Icons.flag_rounded),
                _ObjectiveChip(label: moveLabel, icon: Icons.touch_app_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectiveChip extends StatelessWidget {
  const _ObjectiveChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppIconSizes.small, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectiveTipCard extends StatelessWidget {
  const _ObjectiveTipCard({required this.playerColor});

  final ChessPieceColor playerColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colorLabel = playerColor == ChessPieceColor.white
        ? 'brancas'
        : 'pretas';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(AppRadii.standard * 1.5),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          'Você joga de $colorLabel. Complete o objetivo com o menor número de '
          'jogadas possível para ganhar mais estrelas.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ObjectiveResultSheet extends StatelessWidget {
  const _ObjectiveResultSheet({
    required this.success,
    required this.title,
    required this.description,
    required this.stars,
    required this.scoring,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final bool success;
  final String title;
  final String description;
  final int stars;
  final ObjectiveChallengeScoring scoring;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = success ? AppColors.success : AppColors.danger;

    return SafeArea(
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
            DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 62,
                child: Icon(
                  success
                      ? Icons.emoji_events_rounded
                      : Icons.sentiment_dissatisfied_rounded,
                  color: accent,
                  size: AppIconSizes.display,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < 3; index++)
                  Icon(
                    index < stars
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: const Color(0xFFFFC83D),
                    size: AppIconSizes.display,
                  ),
              ],
            ),
            if (!success) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _starRule,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(backgroundColor: accent),
              child: Text(primaryLabel),
            ),
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: AppSpacing.xs),
              TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
            ],
          ],
        ),
      ),
    );
  }

  String get _starRule {
    if (scoring.countsAttempts) {
      return '1ª tentativa — 3 estrelas\n'
          '2ª tentativa — 2 estrelas\n'
          '3ª tentativa — 1 estrela';
    }

    return 'Até ${scoring.threeStarLimit} jogadas — 3 estrelas\n'
        'Até ${scoring.twoStarLimit} jogadas — 2 estrelas\n'
        'Até ${scoring.oneStarLimit} jogadas — 1 estrela';
  }
}
