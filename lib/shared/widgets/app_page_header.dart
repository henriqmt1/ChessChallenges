import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_dimensions.dart';
import 'app_surface.dart';
import 'app_toolbar_icon_button.dart';

/// Standard header for secondary pages, with optional subtitle and action.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.subtitle,
    this.trailing,
    this.titleMaxLines = 2,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final Widget? trailing;
  final int titleMaxLines;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurface(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          AppToolbarIconButton(
            tooltip: context.l10n.backTooltip,
            onPressed: onBack,
            icon: Icons.arrow_back_ios_new_rounded,
            iconSize: AppIconSizes.status,
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.55,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: subtitle == null
                ? _Title(title: title, maxLines: titleMaxLines)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Title(title: title, maxLines: titleMaxLines),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.title, required this.maxLines});

  final String title;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}
