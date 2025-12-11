import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/providers/auth_providers.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import 'presentation/providers/user_settings_notifier.dart';
import 'widgets/sections/auth_section.dart';
import 'widgets/sections/feature_flags_section.dart';
import 'widgets/sections/legal_section.dart';
import 'widgets/sections/new_notification_section.dart';
import 'widgets/sections/new_premium_section.dart';
import 'widgets/sections/support_section.dart';
import 'widgets/sections/tts_settings_section.dart';

/// Refactored Settings Page with Clean Architecture
/// Uses modular components and unified notifier
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsState = ref.watch(userSettingsProvider);
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeSettings();
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: ResponsiveContentWrapper(
            child: Column(
              children: [
                _buildModernHeader(context, isDark),
                Expanded(
                  child: settingsState.when(
                    data: (state) => _buildSettingsContent(),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erro ao carregar configurações',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => ref
                                .read(userSettingsProvider.notifier)
                                .refresh(),
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      children: const [
        SizedBox(height: 16),
        AuthSection(),
        SizedBox(height: 16),
        // New refactored sections using new notifiers
        NewPremiumSection(),
        SizedBox(height: 16),
        NewNotificationSection(),
        SizedBox(height: 16),
        // Legacy sections (to be removed after migration)
        // PremiumSection(),
        // NotificationsSection(),
        TtsSettingsSection(),
        FeatureFlagsSection(),
        LegalSection(),
        SupportSection(),
        SizedBox(height: 32),
      ],
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark) {
    return ModernHeaderWidget(
      title: 'Configurações',
      subtitle: 'Preferências e ajustes do app',
      leftIcon: Icons.settings,
      showBackButton: false,
      showActions: true,
      isDark: isDark,
      additionalActions: [
        IconButton(
          onPressed: () => _showThemeDialog(context),
          icon: const Icon(Icons.brightness_auto, color: Colors.white, size: 19),
          tooltip: 'Alterar tema',
        ),
      ],
    );
  }

  void _showThemeDialog(BuildContext context) {
    final settingsState = ref.read(userSettingsProvider).value;
    final isDark = settingsState?.isDarkTheme ?? false;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              'Claro',
              'Tema claro sempre ativo',
              Icons.brightness_high,
              !isDark,
              () => _changeTheme(false),
            ),
            _buildThemeOption(
              'Escuro',
              'Tema escuro sempre ativo',
              Icons.brightness_2,
              isDark,
              () => _changeTheme(true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _changeTheme(bool isDark) {
    ref.read(userSettingsProvider.notifier).setDarkTheme(isDark);
  }

  Widget _buildThemeOption(
    String title,
    String subtitle,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onTap();
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeSettings() async {
    try {
      // Get user ID from auth provider
      final authState = ref.read(authProvider).value;
      if (authState?.currentUser?.id != null) {
        await ref.read(userSettingsProvider.notifier).initialize(authState!.currentUser!.id);
      } else {
        // Initialize with anonymous ID if not authenticated
        debugPrint('User not authenticated for settings initialization');
      }
    } catch (e) {
      debugPrint('Error initializing settings: $e');
    }
  }
}
