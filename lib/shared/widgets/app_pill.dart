import 'package:flutter/material.dart';

import '../../core/theme/app_dimensions.dart';

/// A compact, consistently padded label used for status and actions.
class AppPill extends StatelessWidget {
  const AppPill({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.xs,
      vertical: AppSpacing.xxs,
    ),
    this.borderRadius,
  });

  final Widget child;
  final Color? color;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            color ??
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.62),
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: borderColor ?? colorScheme.outlineVariant),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
