import 'package:chess_chalenges/core/theme/app_theme.dart';
import 'package:chess_chalenges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Widget localizedTestApp({
  required Widget home,
  Locale locale = const Locale('pt', 'BR'),
}) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
