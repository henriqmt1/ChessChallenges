import 'package:flutter/material.dart';

import '../../core/theme/app_dimensions.dart';

/// The standard raised surface used across the app.
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(AppRadii.standard * 2);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? colorScheme.surface,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? colorScheme.outlineVariant),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
