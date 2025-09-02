import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection_container.dart' as di;
import '../../shared/widgets/responsive_layout.dart';
import '../../core/services/data_cleaner_service.dart';
import '../../core/services/test_data_generator_service.dart';
import '../../core/theme/plantis_colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart' as auth_providers;
import '../../features/development/presentation/pages/data_inspector_page.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../../shared/widgets/loading/loading_components.dart';
import '../widgets/settings_item.dart';
import '../widgets/settings_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with LoadingPageMixin {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ContextualLoadingListener(
      context: LoadingContexts.settings,
      child: ChangeNotifierProvider<SettingsProvider>.value(
        value: di.sl<SettingsProvider>(), // Using pre-initialized singleton
        child: Scaffold(
          body: ResponsiveLayout(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Consumer2<auth_providers.AuthProvider, SettingsProvider>(
              builder: (context, authProvider, settingsProvider, _) {
                final user = authProvider.currentUser;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Header com título e boas-vindas
                const SizedBox(height: 8),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Minha Conta',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user != null && user.displayName.isNotEmpty
                            ? 'Bem-vindo, ${user.displayName}'
                            : 'Bem-vindo, Usuário Anônimo',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // User Profile Card
                InkWell(
                  onTap: () => context.push('/account-profile'),
                  borderRadius: BorderRadius.circular(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: PlantisColors.primary,
                        child: user?.hasProfilePhoto == true
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  user!.photoUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      user.initials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                user?.initials ?? 'UA',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),

                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Usuário Anônimo',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'usuario@anonimo.com',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getMemberSince(user?.createdAt),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Arrow to profile
                      Icon(
                        Icons.arrow_forward_ios, 
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                    ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

                // Premium Plan Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plan Header
                      Row(
                        children: [
                          const Icon(
                            Icons.star_outline,
                            color: PlantisColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Plano Gratuito',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Desbloqueie recursos premium',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Premium Resources
                      Text(
                        'Recursos Premium:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildPremiumFeature(theme, 'Plantas ilimitadas'),
                      _buildPremiumFeature(theme, 'Backup automático na nuvem'),
                      _buildPremiumFeature(theme, 'Relatórios avançados de cuidados'),
                      _buildPremiumFeature(theme, 'Lembretes personalizados'),

                      const SizedBox(height: 8),

                      Text(
                        'E mais 3 recursos...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Premium Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/premium'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PlantisColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.star),
                          label: const Text(
                            'Assinar Premium',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

            // App Settings Section
            SettingsSection(
              title: 'Configurações do App',
              children: [
                SettingsItem(
                  icon: Icons.notifications,
                  title: 'Notificações',
                  subtitle: 'Configure quando ser notificado sobre tarefas',
                  iconColor: PlantisColors.primary,
                  isFirst: true,
                  onTap: () {
                    context.push('/notifications-settings');
                  },
                ),
                SettingsItem(
                  icon: Icons.dark_mode,
                  title: 'Tema',
                  subtitle: settingsProvider.themeSubtitle,
                  iconColor: settingsProvider.isDarkMode
                      ? PlantisColors.sun
                      : PlantisColors.primaryDark,
                  isLast: true,
                  trailing: Switch(
                    value: settingsProvider.isDarkMode,
                    onChanged: (value) {
                      if (value) {
                        settingsProvider.setDarkTheme();
                      } else {
                        settingsProvider.setLightTheme();
                      }
                    },
                    activeColor: PlantisColors.primary,
                    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                    thumbColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return PlantisColors.primary;
                      }
                      return theme.colorScheme.onSurface.withValues(alpha: 0.6);
                    }),
                    trackColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return PlantisColors.primary.withValues(alpha: 0.5);
                      }
                      return theme.colorScheme.onSurface.withValues(alpha: 0.2);
                    }),
                  ),
                  onTap: () {
                    if (settingsProvider.isDarkMode) {
                      settingsProvider.setLightTheme();
                    } else {
                      settingsProvider.setDarkTheme();
                    }
                  },
                ),
              ],
            ),

            // Account Section
            SettingsSection(
              title: 'Conta',
              children: [
                SettingsItem(
                  icon: Icons.cloud_upload,
                  title: 'Backup na Nuvem',
                  subtitle: 'Proteja seus dados com backup automático',
                  iconColor: PlantisColors.primary,
                  isFirst: true,
                  onTap: () {
                    context.push('/backup-settings');
                  },
                ),
                SettingsItem(
                  icon: Icons.star,
                  title: 'Premium',
                  subtitle: 'Recursos exclusivos e benefícios',
                  iconColor: PlantisColors.sun,
                  isLast: true,
                  onTap: () {
                    context.push('/premium');
                  },
                ),
              ],
            ),

            // Privacy & Legal Section
            SettingsSection(
              title: 'Privacidade e Legal',
              children: [
                SettingsItem(
                  icon: Icons.privacy_tip,
                  title: 'Política de Privacidade',
                  subtitle: 'Como protegemos seus dados',
                  iconColor: PlantisColors.primary,
                  isFirst: true,
                  onTap: () {
                    context.push('/privacy-policy');
                  },
                ),
                SettingsItem(
                  icon: Icons.description,
                  title: 'Termos de Uso',
                  subtitle: 'Termos e condições de uso',
                  iconColor: PlantisColors.primary,
                  onTap: () {
                    context.push('/terms-of-service');
                  },
                ),
                SettingsItem(
                  icon: Icons.campaign,
                  title: 'Ofertas Promocionais',
                  subtitle: 'Conheça nossas promoções especiais',
                  iconColor: PlantisColors.flower,
                  isLast: true,
                  onTap: () {
                    context.push('/promotional');
                  },
                ),
              ],
            ),

            // Development Section - Only visible in debug mode
            if (kDebugMode)
              SettingsSection(
                title: 'Desenvolvimento',
                children: [
                  SettingsItem(
                    icon: Icons.storage,
                    title: 'Inspetor de Dados',
                    subtitle: 'Visualizar dados locais do app',
                    iconColor: PlantisColors.secondary,
                    isFirst: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DataInspectorPage(),
                        ),
                      );
                    },
                  ),
                  SettingsItem(
                    icon: Icons.bug_report,
                    title: 'Gerar Dados de Teste',
                    subtitle: 'Criar plantas e tarefas de exemplo',
                    iconColor: PlantisColors.accent,
                    onTap: () {
                      _showGenerateTestDataDialog(context);
                    },
                  ),
                  SettingsItem(
                    icon: Icons.clear_all,
                    title: 'Limpar Todos os Dados',
                    subtitle: 'Remove todos os registros locais',
                    iconColor: theme.colorScheme.error,
                    isLast: true,
                    onTap: () {
                      _showClearDataDialog(context);
                    },
                  ),
                ],
              ),


            // App Info Section
            SettingsSection(
              title: 'Sobre o App',
              children: [
                SettingsItem(
                  icon: Icons.info,
                  title: 'Informações do App',
                  subtitle: 'Versão, suporte e feedback',
                  iconColor: PlantisColors.primary,
                  isFirst: true,
                  isLast: true,
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),

                const SizedBox(height: 40),
              ],
            );
              },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumFeature(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: theme.colorScheme.onSurfaceVariant,
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }




  String _getMemberSince(DateTime? createdAt) {
    if (createdAt == null) return 'Membro desde 10 dias';

    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays < 30) {
      return 'Membro desde ${difference.inDays} dias';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Membro desde $months ${months == 1 ? 'mês' : 'meses'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Membro desde $years ${years == 1 ? 'ano' : 'anos'}';
    }
  }


  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: PlantisColors.primaryGradient,
              ),
              child: const Icon(
                Icons.eco,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Plantis',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seu companheiro para cuidar de plantas',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Versão', '1.0.0'),
            _buildInfoRow(context, 'Build', '1'),
            _buildInfoRow(context, 'Plataforma', 'Flutter'),
            const SizedBox(height: 16),
            Text(
              'Sistema inteligente de lembretes e cuidados para suas plantas, com sincronização automática e recursos premium.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: PlantisColors.flower,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Feito com carinho para amantes de plantas',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showGenerateTestDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Gerar Dados de Teste',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Isso criará plantas e tarefas fictícias para testar a interface.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PlantisColors.leafLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: PlantisColors.leaf.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: PlantisColors.leaf,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Útil para demonstrações e testes',
                      style: TextStyle(
                        color: PlantisColors.leafDark,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final theme = Theme.of(context);

              navigator.pop();
              _showLoadingDialog(context, 'Gerando dados de teste...');

              try {
                final testDataService = di.sl<TestDataGeneratorService>();
                await testDataService.generateTestData();

                navigator.pop(); // Close loading

                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Dados de teste gerados com sucesso!'),
                    backgroundColor: PlantisColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                navigator.pop(); // Close loading
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Erro ao gerar dados: $e'),
                    backgroundColor: theme.colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Gerar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PlantisColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) async {
    final dataCleanerService = di.sl<DataCleanerService>();
    final stats = await dataCleanerService.getDataStats();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text(
              'Limpar Todos os Dados',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta ação irá remover permanentemente:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            if (stats.hasData) ...[
              _buildDataItem(context, Icons.eco, '${stats.plantsCount} plantas'),
              _buildDataItem(context, Icons.task_alt, '${stats.tasksCount} tarefas'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta ação não pode ser desfeita',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: PlantisColors.leaf,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Não há dados para limpar',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          if (stats.hasData)
            ElevatedButton.icon(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final theme = Theme.of(context);

                navigator.pop();
                _showLoadingDialog(context, 'Limpando dados...');

                try {
                  final result = await dataCleanerService.clearAllData();
                  navigator.pop(); // Close loading

                  result.fold(
                    (failure) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Erro: ${failure.message}'),
                          backgroundColor: theme.colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    (_) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            '${stats.totalItems} itens removidos com sucesso',
                          ),
                          backgroundColor: PlantisColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                } catch (e) {
                  navigator.pop(); // Close loading
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Erro inesperado: $e'),
                      backgroundColor: theme.colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.delete_forever),
              label: const Text('Limpar Tudo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: PlantisColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}