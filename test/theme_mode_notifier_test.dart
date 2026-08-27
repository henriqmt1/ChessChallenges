import 'package:chess_chalenges/core/theme/theme_mode_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('persists the selected theme for the next app session', () async {
    SharedPreferences.setMockInitialValues({});

    final firstSession = ProviderContainer();
    expect(await firstSession.read(themeModeProvider.future), ThemeMode.light);

    await firstSession.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
    firstSession.dispose();

    final nextSession = ProviderContainer();
    addTearDown(nextSession.dispose);

    expect(await nextSession.read(themeModeProvider.future), ThemeMode.dark);
  });
}
