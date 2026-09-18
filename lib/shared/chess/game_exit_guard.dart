import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';

/// Protects active games for both toolbar and system back navigation.
class GameExitGuard extends StatefulWidget {
  const GameExitGuard({
    super.key,
    required this.needsConfirmation,
    required this.builder,
    this.onExit,
  });

  final bool needsConfirmation;
  final Widget Function(VoidCallback requestExit) builder;
  final VoidCallback? onExit;

  @override
  State<GameExitGuard> createState() => _GameExitGuardState();
}

class _GameExitGuardState extends State<GameExitGuard> {
  bool _dialogOpen = false;
  bool _allowPop = false;

  Future<void> _requestExit() async {
    if (_dialogOpen) return;
    if (widget.needsConfirmation) {
      _dialogOpen = true;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.leaveGameTitle),
          content: Text(context.l10n.leaveGameMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.keepPlayingAction),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.leaveGameAction),
            ),
          ],
        ),
      );
      _dialogOpen = false;
      if (!mounted || confirmed != true) return;
    }
    if (!mounted) return;
    final onExit = widget.onExit;
    if (onExit != null) {
      onExit();
    } else {
      setState(() => _allowPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: widget.onExit == null && (!widget.needsConfirmation || _allowPop),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestExit();
      },
      child: widget.builder(_requestExit),
    );
  }
}
