import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';

enum ThemeModeOption { light, dark }

class ThemeNotifier extends StateNotifier<ThemeModeOption> {
  ThemeNotifier() : super(ThemeModeOption.light);

  void toggleTheme() {
    state = state == ThemeModeOption.light ? ThemeModeOption.dark : ThemeModeOption.light;
  }
}

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeModeOption>((ref) {
  return ThemeNotifier();
});

final themeProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(themeNotifierProvider);
  return mode == ThemeModeOption.light ? AppTheme.lightTheme : AppTheme.darkTheme;
});