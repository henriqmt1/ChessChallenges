import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_runtime_config.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/feedback/app_toast.dart';
import '../../campaign/domain/entities/campaign_world.dart';
import '../../home/presentation/pages/home_page.dart';
import '../app_startup.dart';

class AppStartupGate extends ConsumerStatefulWidget {
  const AppStartupGate({
    super.key,
    this.minimumDisplayDuration = Duration.zero,
  });

  static const logoAsset = 'assets/branding/app_logo.png';
  final Duration minimumDisplayDuration;

  @override
  ConsumerState<AppStartupGate> createState() => _AppStartupGateState();
}

class _AppStartupGateState extends ConsumerState<AppStartupGate> {
  bool _started = false;
  bool _ready = false;
  Object? _error;
  bool _updateDialogScheduled = false;
  String? _shownUpdateKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      unawaited(_bootstrap());
    }
  }

  Future<void> _bootstrap() async {
    setState(() {
      _error = null;
      _ready = false;
    });

    final minimumDisplay = Future<void>.delayed(widget.minimumDisplayDuration);

    try {
      await Future.wait([
        minimumDisplay,
        ref.read(appStartupProvider.future),
        _precacheVisuals(),
      ]);
      if (mounted) {
        setState(() => _ready = true);
        _scheduleForceUpdate(ref.read(appRuntimeConfigViewModelProvider));
      }
    } on Object catch (error) {
      await minimumDisplay;
      if (mounted) {
        setState(() => _error = error);
      }
    }
  }

  Future<void> _precacheVisuals() async {
    await Future.wait([
      precacheImage(const AssetImage(AppStartupGate.logoAsset), context),
      for (final world in campaignWorlds)
        precacheImage(AssetImage(world.emblemAsset), context),
    ]);
  }

  void _retry() {
    ref.invalidate(appStartupProvider);
    unawaited(_bootstrap());
  }

  void _scheduleForceUpdate(AppRuntimeConfig config) {
    final updateKey =
        '${config.minimumSupportedBuild}:${config.storeUrl}:${config.currentBuild}';
    if (!_ready ||
        !config.requiresUpdate ||
        _updateDialogScheduled ||
        _shownUpdateKey == updateKey) {
      return;
    }

    _updateDialogScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _updateDialogScheduled = false;
      if (!mounted || !_ready || !config.requiresUpdate) {
        return;
      }
      _shownUpdateKey = updateKey;
      await _showForceUpdateDialog(config);
    });
  }

  Future<void> _showForceUpdateDialog(AppRuntimeConfig config) async {
    final languageCode = Localizations.localeOf(context).languageCode;
    final remoteMessage = config.messageFor(languageCode);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: _ForceUpdateDialog(
          title: dialogContext.l10n.forceUpdateTitle,
          message: remoteMessage.isEmpty
              ? dialogContext.l10n.forceUpdateDefaultMessage
              : remoteMessage,
          actionLabel: dialogContext.l10n.forceUpdateAction,
          onUpdate: () => _openStore(config.storeUrl),
        ),
      ),
    );
  }

  Future<void> _openStore(String storeUrl) async {
    try {
      final opened = await launchUrl(
        Uri.parse(storeUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        AppToast.showError(context, context.l10n.forceUpdateStoreError);
      }
    } on Object {
      if (mounted) {
        AppToast.showError(context, context.l10n.forceUpdateStoreError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppRuntimeConfig>(appRuntimeConfigViewModelProvider, (_, next) {
      _scheduleForceUpdate(next);
    });

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _ready
          ? const HomePage(key: ValueKey('home-page'))
          : _AnimatedSplash(
              key: const ValueKey('animated-splash'),
              error: _error,
              onRetry: _retry,
            ),
    );
  }
}

class _ForceUpdateDialog extends StatelessWidget {
  const _ForceUpdateDialog({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onUpdate,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.standard * 3),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.system_update_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: AppIconSizes.large,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: onUpdate,
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedSplash extends StatefulWidget {
  const _AnimatedSplash({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object? error;
  final VoidCallback onRetry;

  @override
  State<_AnimatedSplash> createState() => _AnimatedSplashState();
}

class _AnimatedSplashState extends State<_AnimatedSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.97,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          const Positioned(
            top: -90,
            right: -80,
            child: _SplashOrb(size: 250, opacity: 0.08),
          ),
          const Positioned(
            bottom: -120,
            left: -100,
            child: _SplashOrb(size: 300, opacity: 0.07),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _pulse,
                      child: Image.asset(
                        AppStartupGate.logoAsset,
                        key: const ValueKey('splash-logo'),
                        width: 210,
                        height: 210,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      context.l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: widget.error == null
                          ? _LoadingLabel(
                              key: const ValueKey('splash-loading'),
                              label: context.l10n.splashLoadingLabel,
                            )
                          : Column(
                              key: const ValueKey('splash-error'),
                              children: [
                                Text(
                                  context.l10n.splashLoadError,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.white),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                FilledButton.tonalIcon(
                                  onPressed: widget.onRetry,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: Text(context.l10n.splashRetryAction),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingLabel extends StatelessWidget {
  const _LoadingLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.primaryOnDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class _SplashOrb extends StatelessWidget {
  const _SplashOrb({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withValues(alpha: opacity),
      ),
      child: SizedBox.square(dimension: size),
    );
  }
}
