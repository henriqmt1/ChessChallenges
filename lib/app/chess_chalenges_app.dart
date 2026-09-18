import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_mode_view_model.dart';
import '../l10n/app_localizations.dart';
import 'startup/presentation/app_startup_gate.dart';

class ChessChalengesApp extends ConsumerWidget {
  const ChessChalengesApp({
    super.key,
    this.locale,
    this.startupMinimumDuration = const Duration(milliseconds: 1800),
  });

  final Locale? locale;
  final Duration startupMinimumDuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(themeModeViewModelProvider).value ?? ThemeMode.light;

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: _resolveLocale,
      home: AppStartupGate(minimumDisplayDuration: startupMinimumDuration),
    );
  }

  Locale _resolveLocale(Locale? deviceLocale, Iterable<Locale> supported) {
    const fallback = Locale('pt', 'BR');

    if (deviceLocale == null) {
      return fallback;
    }

    if (deviceLocale.languageCode == 'pt') {
      return fallback;
    }

    for (final locale in supported) {
      if (locale.languageCode == deviceLocale.languageCode) {
        return locale;
      }
    }

    return fallback;
  }
}
