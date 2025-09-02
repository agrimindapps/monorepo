import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection_container.dart' as di;
import '../../core/services/device_identity_service.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import 'presentation/providers/settings_provider.dart';
import 'widgets/sections/about_section.dart';
import 'widgets/sections/app_info_section.dart';
import 'widgets/sections/development_section.dart';
import 'widgets/sections/notifications_section.dart';
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
  @override
  void initState() {
    super.initState();
    // Remove o addPostFrameCallback - não precisamos mais dele
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ChangeNotifierProvider(
      create: (_) => di.sl<SettingsProvider>(),
      builder: (context, child) {
        // Initialize the provider here where we have access to context
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final provider = context.read<SettingsProvider>();
          try {
            final deviceService = di.sl<DeviceIdentityService>();
            final deviceId = await deviceService.getDeviceUuid();
            await provider.initialize(deviceId);
          } catch (e) {
            debugPrint('Error initializing settings: $e');
            // Fallback to anonymous user
            await provider.initialize('anonymous-${DateTime.now().millisecondsSinceEpoch}');
          }
        });
        return child!;
      },
      child: Scaffold(
        backgroundColor: theme.cardColor,
        body: SafeArea(
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
    );
  }

  Widget _buildSettingsContent() {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: const [
        // App Info Section
        AppInfoSection(),
        
        SizedBox(height: 8),
        
        // Premium Section
        PremiumSection(),
        
        SizedBox(height: 8),
        
        // Notifications Section
        NotificationsSection(),

        SizedBox(height: 8),
        
        // Support Section
        SupportSection(),
        
        // Development Section (only shown in debug mode)
        DevelopmentSection(),
        
        SizedBox(height: 8),
        
        // About Section
        AboutSection(),
        
        // Extra space for better scrolling
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return ModernHeaderWidget(
      title: 'Configurações',
      subtitle: 'Preferências e ajustes do app',
      leftIcon: Icons.settings,
      showBackButton: false,
      showActions: true,
      isDark: isDark,
      additionalActions: [
        _buildThemeToggleButton(context, themeProvider),
      ],
    );
  }

  Widget _buildThemeToggleButton(BuildContext context, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () => _toggleTheme(themeProvider),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Icon(
          themeProvider.isDarkMode
              ? Icons.light_mode
              : themeProvider.isLightMode
                  ? Icons.dark_mode
                  : Icons.auto_mode,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 17,
        ),
      ),
    );
  }

  Future<void> _toggleTheme(ThemeProvider themeProvider) async {
    if (themeProvider.isSystemMode) {
      await themeProvider.setThemeMode(ThemeMode.light);
    } else if (themeProvider.isLightMode) {
      await themeProvider.setThemeMode(ThemeMode.dark);
    } else {
      await themeProvider.setThemeMode(ThemeMode.system);
    }
  }
}