import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme mode (system/light/dark). Persistence is a later concern (Isar);
/// for the MVP this lives in memory and drives the in-app theme toggle.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  /// Cycle through the light/dark options for the app-bar toggle.
  void toggle() {
    state = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system =>
        // Resolve "system" to the opposite of what's currently shown.
        _platformIsDark ? ThemeMode.light : ThemeMode.dark,
    };
  }

  bool get _platformIsDark =>
      PlatformDispatcher.instance.platformBrightness == Brightness.dark;
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// App locale. `null` means "follow the device"; the toggle flips explicitly
/// between English and Arabic so RTL can be demonstrated on any device.
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  void toggle() {
    final current = state?.languageCode ??
        PlatformDispatcher.instance.locale.languageCode;
    state = current == 'ar' ? const Locale('en') : const Locale('ar');
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);
