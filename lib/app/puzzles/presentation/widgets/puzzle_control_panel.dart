import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../l10n/puzzle_localizations.dart';
import '../viewmodels/puzzle_state.dart';

class PuzzleControlPanel extends StatelessWidget {
  const PuzzleControlPanel({
    super.key,
    required this.state,
    required this.onHint,
    required this.onReset,
    required this.onSolution,
    required this.onContinue,
  });

  final PuzzleState state;
  final VoidCallback onHint;
  final VoidCallback onReset;
  final VoidCallback onSolution;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final completed = state.status == PuzzleStatus.completed;
    final failed = state.status == PuzzleStatus.failed;
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.standard),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: state.totalPlayerMoves == 0
                        ? 0
                        : state.completedPlayerMoves / state.totalPlayerMoves,
                    minHeight: AppSizes.progressThin,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completed ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${state.completedPlayerMoves}/${state.totalPlayerMoves}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.localizedMessage(context.l10n),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: failed
                    ? AppColors.danger
                    : completed
                    ? AppColors.success
                    : colorScheme.onSurface,
              ),
            ),
            if (state.solutionVisible) ...[
              const SizedBox(height: 6),
              Text(
                state.solutionText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: state.canInteract && !state.hintUsed
                        ? onHint
                        : null,
                    child: Text(context.l10n.hintButton),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSolution,
                    child: Text(context.l10n.solutionButton),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: FilledButton(
                    onPressed: completed ? onContinue : onReset,
                    child: Text(
                      completed
                          ? context.l10n.mapButton
                          : failed
                          ? context.l10n.restartButton
                          : context.l10n.resetButton,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
