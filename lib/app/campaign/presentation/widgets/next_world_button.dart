import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class NextWorldButton extends StatelessWidget {
  const NextWorldButton({
    super.key,
    required this.enabled,
    required this.targetWorld,
    required this.completedLevels,
    required this.totalLevels,
    required this.onTap,
  });

  final bool enabled;
  final int targetWorld;
  final int completedLevels;
  final int totalLevels;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = enabled
        ? AppColors.primary
        : colorScheme.surfaceContainerHighest;
    final foregroundColor = enabled
        ? AppColors.white
        : colorScheme.onSurfaceVariant;
    final borderColor = enabled
        ? AppColors.primaryBorder
        : colorScheme.outlineVariant;
    final shadowColor = enabled
        ? AppColors.primaryDark
        : colorScheme.shadow.withValues(alpha: 0.24);

    return Semantics(
      button: true,
      enabled: enabled,
      label: context.l10n.goToWorld(targetWorld),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          key: const ValueKey('next-world-button'),
          borderRadius: BorderRadius.circular(AppRadii.standard),
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppRadii.standard),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: enabled ? 18 : 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: enabled
                          ? AppColors.whiteOverlay15
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadii.standard),
                    ),
                    child: SizedBox.square(
                      dimension: AppSizes.nextWorldIconContainer,
                      child: Icon(
                        enabled
                            ? Icons.arrow_forward_rounded
                            : Icons.lock_rounded,
                        color: foregroundColor,
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
                          enabled
                              ? context.l10n.goToWorld(targetWorld)
                              : context.l10n.nextWorld,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: foregroundColor,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          enabled
                              ? context.l10n.newChallengesUnlocked
                              : context.l10n.completeLevelsToUnlock(
                                  completedLevels,
                                  totalLevels,
                                ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: foregroundColor),
                        ),
                      ],
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
