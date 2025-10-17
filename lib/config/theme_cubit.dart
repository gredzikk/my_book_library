import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

enum ThemeState { light, dark }

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeCubit() : super(ThemeState.light) {
    _loadTheme();
  }

  /// Load saved theme preference
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      emit(isDark ? ThemeState.dark : ThemeState.light);
    } catch (e) {
      // If there's an error, default to light theme
      emit(ThemeState.light);
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newTheme = state == ThemeState.light
        ? ThemeState.dark
        : ThemeState.light;

    emit(newTheme);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, newTheme == ThemeState.dark);
    } catch (e) {
      // Handle error silently, theme will reset on app restart
    }
  }

  /// Get current theme mode
  ThemeMode get themeMode =>
      state == ThemeState.dark ? ThemeMode.dark : ThemeMode.light;
}
