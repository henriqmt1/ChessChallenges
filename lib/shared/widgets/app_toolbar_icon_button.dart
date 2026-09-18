import 'package:flutter/material.dart';

import '../../core/theme/app_dimensions.dart';

/// Standard icon button for page toolbars, with a stable hit target.
class AppToolbarIconButton extends StatelessWidget {
  const AppToolbarIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.size = AppSizes.toolbarButton,
    this.iconSize = AppIconSizes.standard,
    this.backgroundColor,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    final foregroundColor = enabled
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.46);
    final radius = BorderRadius.circular(AppRadii.standard);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: SizedBox.square(
              dimension: size,
              child: Icon(icon, color: foregroundColor, size: iconSize),
            ),
          ),
        ),
      ),
    );
  }
}
