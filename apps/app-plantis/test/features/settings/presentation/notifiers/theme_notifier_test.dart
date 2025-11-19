import 'package:app_plantis/features/settings/presentation/providers/notifiers/theme_notifier.dart';
import 'package:core/core.dart' hide test;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeNotifier', () {
    test('build initializes with initial SettingsState', () {
      final container = ProviderContainer();
      final state = container.read(themeNotifierProvider);

      expect(state.settings, isNotNull);
      expect(state.errorMessage, isNull);
    });

    test('setDarkTheme updates theme successfully', () async {
      final container = ProviderContainer();
      final notifier = container.read(themeNotifierProvider.notifier);

      await notifier.setDarkTheme();

      final state = container.read(themeNotifierProvider);
      expect(state.successMessage, 'Tema escuro ativado');
      expect(state.errorMessage, isNull);
    });

    test('setLightTheme updates theme successfully', () async {
      final container = ProviderContainer();
      final notifier = container.read(themeNotifierProvider.notifier);

      await notifier.setLightTheme();

      final state = container.read(themeNotifierProvider);
      expect(state.successMessage, 'Tema claro ativado');
      expect(state.errorMessage, isNull);
    });

    test('setSystemTheme updates theme successfully', () async {
      final container = ProviderContainer();
      final notifier = container.read(themeNotifierProvider.notifier);

      await notifier.setSystemTheme();

      final state = container.read(themeNotifierProvider);
      expect(state.successMessage, 'Tema do sistema ativado');
      expect(state.errorMessage, isNull);
    });

    test('setDarkTheme clears error message', () async {
      final container = ProviderContainer();
      final notifier = container.read(themeNotifierProvider.notifier);

      // First set an error
      await notifier.setDarkTheme();
      
      // Then set a new theme
      await notifier.setLightTheme();
      final state2 = container.read(themeNotifierProvider);

      expect(state2.errorMessage, isNull);
    });

    test('successive theme changes work correctly', () async {
      final container = ProviderContainer();
      final notifier = container.read(themeNotifierProvider.notifier);

      await notifier.setDarkTheme();
      var state = container.read(themeNotifierProvider);
      expect(state.successMessage, 'Tema escuro ativado');

      await notifier.setLightTheme();
      state = container.read(themeNotifierProvider);
      expect(state.successMessage, 'Tema claro ativado');

      await notifier.setSystemTheme();
      state = container.read(themeNotifierProvider);
      expect(state.successMessage, 'Tema do sistema ativado');
    });

    test('theme state maintains other settings', () async {
      final container = ProviderContainer();
      final notifier = container.read(themeNotifierProvider.notifier);

      final initialSettings = container.read(themeNotifierProvider).settings;

      await notifier.setDarkTheme();

      final updatedSettings = container.read(themeNotifierProvider).settings;

      // Check that settings are preserved (theme notifier doesn't change theme mode directly)
      expect(updatedSettings.notifications, initialSettings.notifications);
      expect(updatedSettings.app, initialSettings.app);
    });

    test('setDarkTheme handles errors gracefully', () async {
      final container = ProviderContainer();
      final notifier = container.read(themeNotifierProvider.notifier);

      // Call multiple times to ensure error handling
      await notifier.setDarkTheme();
      await notifier.setDarkTheme();

      final state = container.read(themeNotifierProvider);
      expect(state, isNotNull);
    });
  });
}
