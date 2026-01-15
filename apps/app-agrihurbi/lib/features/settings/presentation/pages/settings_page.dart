import 'package:app_agrihurbi/core/providers/app_providers.dart';
import 'package:app_agrihurbi/features/settings/domain/entities/settings_entity.dart';
import 'package:app_agrihurbi/features/settings/presentation/dialogs/feedback_dialog.dart';
import 'package:app_agrihurbi/features/settings/presentation/providers/settings_provider.dart';
import 'package:app_agrihurbi/features/settings/presentation/widgets/settings_section.dart';
import 'package:app_agrihurbi/features/settings/presentation/widgets/settings_tile.dart';
import 'package:app_agrihurbi/features/settings/presentation/widgets/support_section.dart';
import 'package:core/core.dart' show ConsumerStatefulWidget, ConsumerState;
import 'package:flutter/material.dart';

/// Settings Page
///
/// Comprehensive settings page for app configuration,
/// user preferences, and system settings
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(settingsProvider.notifier);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Builder(
        builder: (context) {
          if (provider.isLoadingSettings) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError && !provider.isInitialized) {
            return _buildErrorWidget(provider.errorMessage!);
          }

          return _buildSettingsContent(provider);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Configurações'),
      elevation: 0,
      actions: [
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.file_upload),
                      SizedBox(width: 8),
                      Text('Exportar Configurações'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'import',
                  child: Row(
                    children: [
                      Icon(Icons.file_download),
                      SizedBox(width: 8),
                      Text('Importar Configurações'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      Icon(Icons.restore),
                      SizedBox(width: 8),
                      Text('Resetar ao Padrão'),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildSettingsContent(SettingsNotifier provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (provider.hasSuccess) _buildSuccessMessage(provider.successMessage!),
        if (provider.hasError) _buildErrorMessage(provider.errorMessage!),

        _buildThemeSection(provider),
        const SizedBox(height: 24),

        _buildNotificationSection(provider),
        const SizedBox(height: 24),

        _buildDataSection(provider),
        const SizedBox(height: 24),

        _buildPrivacySection(provider),
        const SizedBox(height: 24),

        _buildDisplaySection(provider),
        const SizedBox(height: 24),

        _buildSecuritySection(provider),
        const SizedBox(height: 24),

        _buildBackupSection(provider),
        const SizedBox(height: 24),

        _buildSupportSection(),
        const SizedBox(height: 24),

        _buildAboutSection(),
      ],
    );
  }

  Widget _buildSuccessMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.green.shade700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => ref.read(settingsProvider.notifier).clearMessages(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.red.shade700)),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => ref.read(settingsProvider.notifier).clearMessages(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(SettingsNotifier provider) {
    return SettingsSection(
      title: 'Aparência',
      icon: Icons.palette,
      children: [
        SettingsTile.dropdown<AppTheme>(
          title: 'Tema',
          subtitle: 'Aparência do aplicativo',
          value: provider.theme,
          items:
              AppTheme.values
                  .map(
                    (theme) => DropdownMenuItem(
                      value: theme,
                      child: Text(theme.displayName),
                    ),
                  )
                  .toList(),
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (theme) {
                    if (theme != null) {
                      provider.updateTheme(theme);
                    }
                  },
        ),
        SettingsTile.dropdown<String>(
          title: 'Idioma',
          subtitle: 'Idioma do aplicativo',
          value: provider.language,
          items: const [
            DropdownMenuItem(value: 'pt_BR', child: Text('Português (BR)')),
            DropdownMenuItem(value: 'en_US', child: Text('English (US)')),
            DropdownMenuItem(value: 'es_ES', child: Text('Español')),
          ],
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (language) {
                    if (language != null) {
                      provider.updateLanguage(language);
                    }
                  },
        ),
      ],
    );
  }

  Widget _buildNotificationSection(SettingsNotifier provider) {
    final notifications = provider.notifications;

    return SettingsSection(
      title: 'Notificações',
      icon: Icons.notifications,
      children: [
        SettingsTile.switchTile(
          title: 'Notificações Push',
          subtitle: 'Receber notificações push',
          value: notifications.pushNotifications,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.togglePushNotifications(value);
                  },
        ),
        SettingsTile.switchTile(
          title: 'Notícias',
          subtitle: 'Notificações sobre novas notícias',
          value: notifications.newsNotifications,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.toggleNewsNotifications(value);
                  },
        ),
        SettingsTile.switchTile(
          title: 'Alertas de Mercado',
          subtitle: 'Alertas sobre preços de commodities',
          value: notifications.marketAlerts,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.toggleMarketAlerts(value);
                  },
        ),
        SettingsTile.switchTile(
          title: 'Alertas Meteorológicos',
          subtitle: 'Alertas sobre condições climáticas',
          value: notifications.weatherAlerts,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.toggleWeatherAlerts(value);
                  },
        ),
        SettingsTile.navigation(
          title: 'Horário de Silêncio',
          subtitle:
              '${notifications.quietHoursStart} - ${notifications.quietHoursEnd}',
          onTap: () => _showQuietHoursDialog(provider),
        ),
      ],
    );
  }

  Widget _buildDataSection(SettingsNotifier provider) {
    final dataSettings = provider.dataSettings;

    return SettingsSection(
      title: 'Dados e Sincronização',
      icon: Icons.sync,
      children: [
        SettingsTile.switchTile(
          title: 'Sincronização Automática',
          subtitle: 'Sincronizar dados automaticamente',
          value: dataSettings.autoSync,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.toggleAutoSync(value);
                  },
        ),
        SettingsTile.switchTile(
          title: 'Apenas WiFi',
          subtitle: 'Sincronizar apenas via WiFi',
          value: dataSettings.wifiOnlySync,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.toggleWifiOnlySync(value);
                  },
        ),
        SettingsTile.switchTile(
          title: 'Cache de Imagens',
          subtitle: 'Armazenar imagens localmente',
          value: dataSettings.cacheImages,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.toggleCacheImages(value);
                  },
        ),
        SettingsTile.dropdown<DataExportFormat>(
          title: 'Formato de Exportação',
          subtitle: 'Formato padrão para exportar dados',
          value: dataSettings.exportFormat,
          items:
              DataExportFormat.values
                  .map(
                    (format) => DropdownMenuItem(
                      value: format,
                      child: Text(format.displayName),
                    ),
                  )
                  .toList(),
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (format) {
                    if (format != null) {
                      provider.updateExportFormat(format);
                    }
                  },
        ),
      ],
    );
  }

  Widget _buildPrivacySection(SettingsNotifier provider) {
    final privacy = provider.privacy;

    return SettingsSection(
      title: 'Privacidade',
      icon: Icons.privacy_tip,
      children: [
        SettingsTile.switchTile(
          title: 'Analytics',
          subtitle: 'Permitir coleta de dados de uso',
          value: privacy.analyticsEnabled,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.toggleAnalytics(value);
                  },
        ),
        SettingsTile.switchTile(
          title: 'Relatórios de Erro',
          subtitle: 'Enviar relatórios de erro automaticamente',
          value: privacy.crashReportingEnabled,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.toggleCrashReporting(value);
                  },
        ),
        SettingsTile.switchTile(
          title: 'Compartilhar Dados de Uso',
          subtitle: 'Ajudar a melhorar o aplicativo',
          value: privacy.shareUsageData,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.toggleShareUsageData(value);
                  },
        ),
        SettingsTile.switchTile(
          title: 'Localização',
          subtitle: 'Permitir acesso à localização',
          value: privacy.locationTracking,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.toggleLocationTracking(value);
                  },
        ),
      ],
    );
  }

  Widget _buildDisplaySection(SettingsNotifier provider) {
    final display = provider.display;

    return SettingsSection(
      title: 'Exibição',
      icon: Icons.display_settings,
      children: [
        SettingsTile.slider(
          title: 'Tamanho da Fonte',
          subtitle: 'Ajustar tamanho do texto',
          value: display.fontSize,
          min: 0.8,
          max: 1.5,
          divisions: 7,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.updateFontSize(value);
                  },
        ),
        SettingsTile.switchTile(
          title: 'Alto Contraste',
          subtitle: 'Melhorar visibilidade do texto',
          value: display.highContrast,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.toggleHighContrast(value);
                  },
        ),
        SettingsTile.switchTile(
          title: 'Animações',
          subtitle: 'Exibir animações na interface',
          value: display.animations,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.toggleAnimations(value);
                  },
        ),
        SettingsTile.dropdown<String>(
          title: 'Formato de Data',
          subtitle: 'Como exibir datas',
          value: display.dateFormat,
          items: const [
            DropdownMenuItem(value: 'dd/MM/yyyy', child: Text('DD/MM/AAAA')),
            DropdownMenuItem(value: 'MM/dd/yyyy', child: Text('MM/DD/AAAA')),
            DropdownMenuItem(value: 'yyyy-MM-dd', child: Text('AAAA-MM-DD')),
          ],
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (format) {
                    if (format != null) {
                      provider.updateDateFormat(format);
                    }
                  },
        ),
        SettingsTile.dropdown<String>(
          title: 'Moeda',
          subtitle: 'Moeda padrão para preços',
          value: display.currency,
          items: const [
            DropdownMenuItem(value: 'BRL', child: Text('Real (R\$)')),
            DropdownMenuItem(value: 'USD', child: Text('Dólar (US\$)')),
            DropdownMenuItem(value: 'EUR', child: Text('Euro (€)')),
          ],
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (currency) {
                    if (currency != null) {
                      provider.updateCurrency(currency);
                    }
                  },
        ),
      ],
    );
  }

  Widget _buildSecuritySection(SettingsNotifier provider) {
    final security = provider.security;

    return SettingsSection(
      title: 'Segurança',
      icon: Icons.security,
      children: [
        SettingsTile.switchTile(
          title: 'Autenticação Biométrica',
          subtitle: 'Usar impressão digital ou Face ID',
          value: security.biometricAuth,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.toggleBiometricAuth(value);
                  },
        ),
        SettingsTile.switchTile(
          title: 'Bloquear ao Abrir',
          subtitle: 'Exigir autenticação ao abrir o app',
          value: security.requireAuthOnOpen,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.toggleRequireAuthOnOpen(value);
                  },
        ),
        SettingsTile.dropdown<int>(
          title: 'Bloqueio Automático',
          subtitle: 'Tempo para bloqueio automático',
          value: security.autoLockMinutes,
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 minuto')),
            DropdownMenuItem(value: 2, child: Text('2 minutos')),
            DropdownMenuItem(value: 5, child: Text('5 minutos')),
            DropdownMenuItem(value: 10, child: Text('10 minutos')),
            DropdownMenuItem(value: 15, child: Text('15 minutos')),
            DropdownMenuItem(value: 30, child: Text('30 minutos')),
          ],
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (minutes) {
                    if (minutes != null) {
                      provider.updateAutoLockMinutes(minutes);
                    }
                  },
        ),
      ],
    );
  }

  Widget _buildBackupSection(SettingsNotifier provider) {
    final backup = provider.backup;

    return SettingsSection(
      title: 'Backup e Recuperação',
      icon: Icons.backup,
      children: [
        SettingsTile.switchTile(
          title: 'Backup Automático',
          subtitle: 'Fazer backup automaticamente',
          value: backup.autoBackup,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.toggleAutoBackup(value);
                  },
        ),
        SettingsTile.dropdown<BackupFrequency>(
          title: 'Frequência',
          subtitle: 'Com que frequência fazer backup',
          value: backup.frequency,
          items:
              BackupFrequency.values
                  .map(
                    (frequency) => DropdownMenuItem(
                      value: frequency,
                      child: Text(frequency.displayName),
                    ),
                  )
                  .toList(),
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (frequency) {
                    if (frequency != null) {
                      provider.updateBackupFrequency(frequency);
                    }
                  },
        ),
        SettingsTile.switchTile(
          title: 'Incluir Imagens',
          subtitle: 'Incluir imagens no backup',
          value: backup.includeImages,
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (value) {
                    provider.toggleIncludeImagesInBackup(value);
                  },
        ),
        SettingsTile.dropdown<BackupStorage>(
          title: 'Local do Backup',
          subtitle: 'Onde armazenar backups',
          value: backup.storage,
          items:
              BackupStorage.values
                  .map(
                    (storage) => DropdownMenuItem(
                      value: storage,
                      child: Text(storage.displayName),
                    ),
                  )
                  .toList(),
          onChanged:
              provider.isSavingSettings
                  ? null
                  : (storage) {
                    if (storage != null) {
                      provider.updateBackupStorage(storage);
                    }
                  },
        ),
        if (backup.lastBackupDate != null)
          SettingsTile.info(
            title: 'Último Backup',
            subtitle: backup.lastBackupDate!,
          ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return SupportSection(
      onFeedbackTap: _showFeedbackDialog,
      onRateTap: _showRateAppDialog,
      onContactTap: () => _launchContactSupport(),
    );
  }

  void _showFeedbackDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => const FeedbackDialog(),
    );
  }

  Future<void> _showRateAppDialog() async {
    try {
      final appRatingService = ref.read(appRatingRepositoryProvider);
      final canShow = await appRatingService.canShowRatingDialog();

      if (canShow) {
        if (!mounted) return;
        final success = await appRatingService.showRatingDialog(
          context: context,
        );

        if (mounted && !success) {
          // Se não mostrou o diálogo, abrir a loja diretamente
          final storeOpened = await appRatingService.openAppStore();
          if (!storeOpened && mounted) {
            _showSnackBar('Não foi possível abrir a loja de aplicativos');
          }
        }
      } else {
        // Já avaliou ou não atingiu os critérios, abrir loja diretamente
        final storeOpened = await appRatingService.openAppStore();
        if (!storeOpened && mounted) {
          _showSnackBar('Não foi possível abrir a loja de aplicativos');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao abrir avaliação do app');
      }
    }
  }

  void _launchContactSupport() {
    // Implementar abertura de email ou link de suporte
    _showSnackBar('Funcionalidade de contato será implementada em breve');
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildAboutSection() {
    return SettingsSection(
      title: 'Sobre',
      icon: Icons.info,
      children: [
        SettingsTile.navigation(
          title: 'Versão do Aplicativo',
          subtitle: '1.0.0+1',
          onTap: () => _showAboutDialog(),
        ),
        SettingsTile.navigation(
          title: 'Termos de Uso',
          subtitle: 'Ler termos de uso',
          onTap: () => Navigator.pushNamed(context, '/legal/terms'),
        ),
        SettingsTile.navigation(
          title: 'Política de Privacidade',
          subtitle: 'Ler política de privacidade',
          onTap: () => Navigator.pushNamed(context, '/legal/privacy'),
        ),
        SettingsTile.navigation(
          title: 'Suporte',
          subtitle: 'Obter ajuda e suporte',
          onTap: () => Navigator.pushNamed(context, '/support'),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar configurações',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).loadSettings();
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    final provider = ref.read(settingsProvider.notifier);

    switch (action) {
      case 'export':
        _exportSettings(provider);
        break;
      case 'import':
        _importSettings(provider);
        break;
      case 'reset':
        _showResetDialog(provider);
        break;
    }
  }

  void _exportSettings(SettingsNotifier provider) async {
    final data = await provider.exportSettings();
    if (data != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurações exportadas com sucesso')),
      );
    }
  }

  void _importSettings(SettingsNotifier provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de importação será implementada'),
      ),
    );
  }

  void _showResetDialog(SettingsNotifier provider) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Resetar Configurações'),
            content: const Text(
              'Tem certeza de que deseja resetar todas as configurações para o padrão? '
              'Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  provider.resetToDefaults();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Resetar'),
              ),
            ],
          ),
    );
  }

  void _showQuietHoursDialog(SettingsNotifier provider) {
    final notifications = provider.notifications;
    TimeOfDay startTime = TimeOfDay(
      hour: int.parse(notifications.quietHoursStart.split(':')[0]),
      minute: int.parse(notifications.quietHoursStart.split(':')[1]),
    );
    TimeOfDay endTime = TimeOfDay(
      hour: int.parse(notifications.quietHoursEnd.split(':')[0]),
      minute: int.parse(notifications.quietHoursEnd.split(':')[1]),
    );

    showDialog<void>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Horário de Silêncio'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Início'),
                        subtitle: Text(startTime.format(context)),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: startTime,
                          );
                          if (time != null) {
                            setState(() => startTime = time);
                          }
                        },
                      ),
                      ListTile(
                        title: const Text('Fim'),
                        subtitle: Text(endTime.format(context)),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                          );
                          if (time != null) {
                            setState(() => endTime = time);
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final startStr =
                            '${startTime.hour.toString().padLeft(2, '0')}:'
                            '${startTime.minute.toString().padLeft(2, '0')}';
                        final endStr =
                            '${endTime.hour.toString().padLeft(2, '0')}:'
                            '${endTime.minute.toString().padLeft(2, '0')}';
                        provider.updateQuietHours(startStr, endStr);
                        Navigator.pop(context);
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'AgroMind',
      applicationVersion: '1.0.0+1',
      applicationLegalese: '© 2024 AgroMind Solutions',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Aplicativo completo para gestão agropecuária com calculadoras, '
          'monitoramento climático, notícias e muito mais.',
        ),
      ],
    );
  }
}
