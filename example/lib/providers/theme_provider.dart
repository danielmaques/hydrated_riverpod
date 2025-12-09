import 'package:flutter/material.dart';
import 'package:hydrated_riverpod/hydrated_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme mode notifier - persists user's theme preference
class ThemeModeNotifier extends HydratedNotifier<ThemeMode> {
  @override
  ThemeMode build() => hydrate() ?? ThemeMode.system;

  void setThemeMode(ThemeMode mode) => state = mode;

  void toggle() {
    state = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.dark,
    };
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) => {'mode': state.index};

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    final index = json['mode'] as int?;
    if (index == null || index < 0 || index >= ThemeMode.values.length) {
      return null;
    }
    return ThemeMode.values[index];
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
