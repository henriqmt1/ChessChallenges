import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

abstract final class AppToast {
  static OverlayEntry? _activeEntry;

  static void showError(BuildContext context, String message) {
    if (_activeEntry != null && !_activeEntry!.mounted) {
      _activeEntry = null;
    }

    if (_activeEntry != null) {
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ErrorToast(
        message: message,
        onDismissed: () {
          if (_activeEntry != entry) {
            return;
          }

          entry.remove();
          _activeEntry = null;
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }
}

class _ErrorToast extends StatefulWidget {
  const _ErrorToast({required this.message, required this.onDismissed});

  final String message;
  final VoidCallback onDismissed;

  @override
  State<_ErrorToast> createState() => _ErrorToastState();
}

class _ErrorToastState extends State<_ErrorToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _position;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 180),
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _position = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(curve);

    unawaited(_controller.forward());
    _dismissTimer = Timer(const Duration(milliseconds: 2800), _dismiss);
  }

  Future<void> _dismiss() async {
    if (_isDismissing || !mounted) {
      return;
    }

    _isDismissing = true;
    await _controller.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _position,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.contentMaxWidth,
                ),
                child: Material(
                  key: const ValueKey('app-error-toast'),
                  color: AppColors.danger,
                  elevation: 10,
                  shadowColor: AppColors.danger,
                  borderRadius: BorderRadius.circular(AppRadii.standard * 2),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DecoratedBox(
                          decoration: const BoxDecoration(
                            color: AppColors.whiteOverlay15,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox.square(
                            dimension: 36,
                            child: Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.white,
                              size: AppIconSizes.status,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
