import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/theme_settings_entity.dart';
import '../../domain/interfaces/segregated_settings_interfaces.dart';

part 'theme_notifier_refactored.g.dart';

/// ✅ REFACTORED: ThemeNotifier - Follows SRP
///
/// OLD APPROACH (SettingsNotifier):
/// - Responsável por 7+ serviços diferentes
/// - >590 linhas de código
/// - Difícil de testar e manter
///
/// NEW APPROACH (ThemeNotifier):
/// - Responsabilidade ÚNICA: Gerenciar configurações de tema
/// - ~100 linhas de código
/// - Fácil de testar e reutilizar
/// - Pode ser usado independentemente de outros notifiers
///
/// BENEFITS:
/// ✅ Single Responsibility: Uma classe, uma responsabilidade
/// ✅ Testability: Fácil mockar e testar
/// ✅ Reusability: Pode ser usado em diferentes contextos
/// ✅ Maintainability: Mudanças em tema não afetam outro estado

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  Future<IThemeSettings> build() async {
    // Load current theme settings
    // In a real app, you'd load from repository
    return IThemeSettings.from(ThemeSettingsEntity.defaults());
  }

  /// Update dark theme setting
  Future<void> setDarkTheme(bool isDark) async {
    state = const AsyncValue<IThemeSettings>.loading();

    state = await AsyncValue.guard<IThemeSettings>(() async {
      // Aqui você atualizaria via use case
      // final updateUseCase = ref.read(updateUserSettingsProvider);
      // await updateUseCase(...);

      // Por enquanto, retorna a interface atualizada
      final updated = ThemeSettingsEntity.defaults().copyWith(
        isDarkTheme: isDark,
      );
      return IThemeSettings.from(updated);
    });
  }

  /// Update language
  Future<void> setLanguage(String languageCode) async {
    state = const AsyncValue<IThemeSettings>.loading();

    state = await AsyncValue.guard<IThemeSettings>(() async {
      final updated = ThemeSettingsEntity.defaults().copyWith(
        language: languageCode,
      );
      return IThemeSettings.from(updated);
    });
  }

  /// Reset to default theme
  Future<void> resetToDefaults() async {
    state = AsyncValue.data(
      IThemeSettings.from(ThemeSettingsEntity.defaults()),
    );
  }
}
