import 'package:chess_chalenges/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('provides Portuguese, English, and Spanish catalogs', () {
    final portuguese = lookupAppLocalizations(const Locale('pt', 'BR'));
    final english = lookupAppLocalizations(const Locale('en'));
    final spanish = lookupAppLocalizations(const Locale('es'));

    expect(portuguese.appTitle, 'Chess Chalenges');
    expect(portuguese.worldXp(0, 30), 'XP do mundo: 0/30');
    expect(portuguese.hintTooltip, 'Dica');
    expect(portuguese.faqPageTitle, 'Central de ajuda');

    expect(english.worldLabel(1), 'World 1');
    expect(english.offensiveCount(0), 'Streak 0');
    expect(english.faqPageTitle, 'Help center');

    expect(spanish.worldXp(0, 30), 'XP del mundo: 0/30');
    expect(spanish.hintTooltip, 'Pista');
    expect(spanish.faqPageTitle, 'Centro de ayuda');
  });
}
