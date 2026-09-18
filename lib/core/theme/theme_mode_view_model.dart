import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeViewModelProvider =
    AsyncNotifierProvider<ThemeModeViewModel, ThemeMode>(
      ThemeModeViewModel.new,
    );

class ThemeModeViewModel extends AsyncNotifier<ThemeMode> {
  static const _preferenceKey = 'appearance.themeMode';

  @override
  Future<ThemeMode> build() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_preferenceKey) == ThemeMode.dark.name
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  Future<void> toggle() async {
    final current = state.value ?? ThemeMode.light;
    await setMode(current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = AsyncValue.data(mode);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_preferenceKey, mode.name);
  }
}
