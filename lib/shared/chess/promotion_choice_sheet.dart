import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import 'chess_asset_paths.dart';

Future<ChessPieceKind?> showPromotionChoiceSheet(
  BuildContext context, {
  required ChessPieceColor color,
}) {
  return showModalBottomSheet<ChessPieceKind>(
    context: context,
    showDragHandle: true,
    builder: (context) => _PromotionChoiceSheet(color: color),
  );
}

class _PromotionChoiceSheet extends StatelessWidget {
  const _PromotionChoiceSheet({required this.color});

  final ChessPieceColor color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.promotionChoiceTitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              context.l10n.promotionChoiceSubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth = (constraints.maxWidth - AppSpacing.sm) / 2;
                final choices = [
                  (ChessPieceKind.queen, context.l10n.promotionQueen),
                  (ChessPieceKind.rook, context.l10n.promotionRook),
                  (ChessPieceKind.bishop, context.l10n.promotionBishop),
                  (ChessPieceKind.knight, context.l10n.promotionKnight),
                ];

                return Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: choices
                      .map((choice) {
                        return SizedBox(
                          width: tileWidth,
                          height: 68,
                          child: _PromotionChoiceTile(
                            color: color,
                            kind: choice.$1,
                            label: choice.$2,
                          ),
                        );
                      })
                      .toList(growable: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionChoiceTile extends StatelessWidget {
  const _PromotionChoiceTile({
    required this.color,
    required this.kind,
    required this.label,
  });

  final ChessPieceColor color;
  final ChessPieceKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        key: ValueKey('promotion-choice-${kind.name}'),
        borderRadius: BorderRadius.circular(AppRadii.standard * 1.5),
        onTap: () => Navigator.of(context).pop(kind),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(AppRadii.standard * 1.5),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 42,
                  child: SvgPicture.asset(
                    ChessAssetPaths.piece(color: color, kind: kind),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
