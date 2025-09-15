import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection_container.dart' as di;
import '../../core/providers/auth_provider.dart';
import '../../core/services/device_identity_service.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import 'constants/settings_design_tokens.dart';
import 'presentation/providers/settings_provider.dart';
import 'widgets/dialogs/theme_selection_dialog.dart';
import 'widgets/sections/about_section.dart';
import 'widgets/sections/auth_section.dart';
import 'widgets/sections/development_section.dart';
import 'widgets/sections/feature_flags_section.dart';
import 'widgets/sections/premium_section.dart';
import 'widgets/sections/support_section.dart';

/// Refactored Settings Page with Clean Architecture
/// Uses modular components and unified provider
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsProvider _settingsProvider;
  
  @override
  void initState() {
    super.initState();
    _settingsProvider = di.sl<SettingsProvider>();
    // Initialize provider only once
    _initializeProvider(_settingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ChangeNotifierProvider.value(
      value: _settingsProvider,
      child: Scaffold(
        backgroundColor: theme.cardColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: ResponsiveContentWrapper(
              child: Column(
                children: [
                  _buildModernHeader(context, isDark),
                Expanded(
                  child: Consumer<SettingsProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (provider.error != null) {
                        return Center(
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
                                provider.error!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => provider.refresh(),
                                child: const Text('Tentar Novamente'),
                              ),
                            ],
                          ),
                        );
                      }

                      return _buildSettingsContent();
                    },
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent() {
    return Consumer<ReceitaAgroAuthProvider>(
      builder: (context, authProvider, child) {
        return ListView(
          padding: const EdgeInsets.all(8.0),
          children: const [
            // 👤 SEÇÃO DE CONTA/LOGIN (primeiro item - sempre visível)
            AuthSection(),
            SizedBox(height: 4),
            
            // 💎 PREMIUM/ASSINATURA (sempre visível)
            PremiumSection(),
            SizedBox(height: 4),
            
            // 🆘 SUPORTE (sempre visível)
            SupportSection(),
            SizedBox(height: 4),
            
            // 🔧 SEÇÕES DE DESENVOLVIMENTO (condicional)
            FeatureFlagsSection(),
            DevelopmentSection(),
            SizedBox(height: 4),
            
            // ℹ️ SOBRE O APP (sempre visível)
            AboutSection(),
            
            // Espaço extra para melhor rolagem
            SizedBox(height: 24),
          ],
        );
      },
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
        _buildThemeSettingsButton(context),
      ],
    );
  }

  Widget _buildThemeSettingsButton(BuildContext context) {
    return Semantics(
      label: 'Configurações de tema',
      hint: 'Toque para abrir as opções de tema',
      button: true,
      child: GestureDetector(
        onTap: () => _openThemeDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(
            SettingsDesignTokens.paletteIcon,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 17,
          ),
        ),
      ),
    );
  }

  Future<void> _openThemeDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const ThemeSelectionDialog(),
    );
  }

  Future<void> _initializeProvider(SettingsProvider provider) async {
    // Avoid multiple initializations if provider is already loaded
    if (provider.hasSettings && !provider.isLoading) {
      return;
    }
    
    try {
      final deviceService = di.sl<DeviceIdentityService>();
      final deviceId = await deviceService.getDeviceUuid();
      await provider.initialize(deviceId);
    } catch (e) {
      debugPrint('Error initializing settings: $e');
      // Fallback to anonymous user
      await provider.initialize('anonymous-${DateTime.now().millisecondsSinceEpoch}');
    }
  }
}