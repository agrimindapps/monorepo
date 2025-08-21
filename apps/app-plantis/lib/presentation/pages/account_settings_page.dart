import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core/core.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_item.dart';
import '../widgets/user_profile_card.dart';
import '../widgets/premium_subscription_card.dart';
import '../../features/development/presentation/pages/data_inspector_page.dart';
import '../../features/legal/presentation/pages/terms_of_service_page.dart';
import '../../features/legal/presentation/pages/privacy_policy_page.dart';
import '../../features/legal/presentation/pages/promotional_page.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/services/test_data_generator_service.dart';
import '../../core/services/data_cleaner_service.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Minha Conta',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem-vindo, Usuário Anônimo',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            // Profile Card
            UserProfileCard(
              name: 'Lucinei Robson Lo...',
              email: 'lucinei@controlsoft.com.br',
              membershipInfo: 'Membro desde 10 dias',
              initials: 'LR',
              onTap: () {
                // Handle profile tap
              },
            ),

            // Premium Subscription Card
            PremiumSubscriptionCard(
              planName: 'Plano Gratuito',
              description: 'Desbloqueie recursos premium',
              features: [
                'Plantas ilimitadas',
                'Backup automático na nuvem',
                'Relatórios avançados de cuidados',
                'Lembretes personalizados',
              ],
              ctaText: 'Assinar Premium',
              onSubscribeTap: () {
                // Handle subscription tap
                _showSubscriptionDialog(context);
              },
            ),

            // Configurations Section
            SettingsSection(
              title: 'Configurações',
              children: [
                SettingsItem(
                  icon: Icons.notifications,
                  title: 'Notificações',
                  subtitle: 'Configure quando ser notificado',
                  iconColor: theme.colorScheme.primary,
                  isFirst: true,
                  onTap: () {
                    // Handle notifications tap
                  },
                ),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return SettingsItem(
                      icon: Icons.dark_mode,
                      title: 'Tema',
                      subtitle:
                          themeProvider.isDarkMode
                              ? 'Tema escuro ativo'
                              : themeProvider.isLightMode
                              ? 'Tema claro ativo'
                              : 'Seguir sistema',
                      iconColor:
                          themeProvider.isDarkMode
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.primary,
                      isLast: true,
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          if (value) {
                            themeProvider.setDarkTheme();
                          } else {
                            themeProvider.setLightTheme();
                          }
                        },
                        activeColor: theme.colorScheme.primary,
                      ),
                      onTap: () {
                        // Toggle theme
                        if (themeProvider.isDarkMode) {
                          themeProvider.setLightTheme();
                        } else {
                          themeProvider.setDarkTheme();
                        }
                      },
                    );
                  },
                ),
              ],
            ),

            // Legal Section
            SettingsSection(
              title: 'Legal',
              children: [
                SettingsItem(
                  icon: Icons.privacy_tip,
                  title: 'Política de Privacidade',
                  subtitle: 'Como protegemos seus dados',
                  iconColor: theme.colorScheme.primary,
                  isFirst: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                ),
                SettingsItem(
                  icon: Icons.description,
                  title: 'Termos de Uso',
                  subtitle: 'Termos e condições de uso',
                  iconColor: theme.colorScheme.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsOfServicePage(),
                      ),
                    );
                  },
                ),
                SettingsItem(
                  icon: Icons.info,
                  title: 'Sobre o App',
                  subtitle: 'Versão e informações do app',
                  iconColor: theme.colorScheme.primary,
                  isLast: true,
                  onTap: () {
                    // Handle about tap
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),

            // Development Section
            SettingsSection(
              title: 'Desenvolvimento',
              children: [
                SettingsItem(
                  icon: Icons.storage,
                  title: 'Inspetor de Dados',
                  subtitle: 'Visualizar dados locais do app',
                  iconColor: theme.colorScheme.secondary,
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
                  title: 'Gerar dados de teste',
                  iconColor: theme.colorScheme.tertiary,
                  onTap: () {
                    _showGenerateTestDataDialog(context);
                  },
                ),
                SettingsItem(
                  icon: Icons.clear_all,
                  title: 'Limpar todos os registros',
                  iconColor: theme.colorScheme.error,
                  onTap: () {
                    _showClearDataDialog(context);
                  },
                ),
                SettingsItem(
                  icon: Icons.campaign,
                  title: 'Página promocional',
                  iconColor: theme.colorScheme.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PromotionalPage(),
                      ),
                    );
                  },
                ),
                SettingsItem(
                  icon: Icons.verified,
                  title: 'Gerar Licença Local',
                  subtitle: 'Ativa premium por 30 dias',
                  iconColor: theme.colorScheme.secondary,
                  onTap: () {
                    // Handle local license tap
                  },
                ),
                SettingsItem(
                  icon: Icons.remove_circle,
                  title: 'Revogar Licença Local',
                  subtitle: 'Remove licença de teste',
                  iconColor: theme.colorScheme.error,
                  isLast: true,
                  onTap: () {
                    // Handle revoke license tap
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.exit_to_app, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Sair do App Plantas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // Account tab selected
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Tarefas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Minhas plantas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Minha conta',
          ),
        ],
        onTap: (index) {
          // Handle navigation
          switch (index) {
            case 0:
              // Navigate to tasks
              break;
            case 1:
              // Navigate to plants
              Navigator.of(context).popUntil((route) => route.isFirst);
              break;
            case 2:
              // Already on account page
              break;
          }
        },
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Assinar Premium',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              'Deseja ativar o plano premium para acessar todos os recursos?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Handle subscription
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Assinar',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Sobre o App',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plantis - Gerenciamento de Plantas',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Versão: 1.0.0',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Build: 1',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sistema de cuidados e lembretes para suas plantas',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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

  void _showClearDataDialog(BuildContext context) async {
    // Primeiro, obter estatísticas dos dados
    final dataCleanerService = di.sl<DataCleanerService>();
    final stats = await dataCleanerService.getDataStats();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Limpar Todos os Dados',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Esta ação irá remover permanentemente:',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (stats.hasData) ...[
                  Text(
                    '• ${stats.plantsCount} plantas',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '• ${stats.tasksCount} tarefas',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Esta ação não pode ser desfeita. Continuar?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Não há dados para limpar.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
                ElevatedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final theme = Theme.of(context);

                    navigator.pop();

                    // Show loading
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
                            ),
                          );
                        },
                        (_) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                '${stats.totalItems} itens removidos com sucesso',
                              ),
                              backgroundColor: theme.colorScheme.primary,
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
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: Text(
                    'Limpar Tudo',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                ),
            ],
          ),
    );
  }

  void _showGenerateTestDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Gerar Dados de Teste',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              'Isso criará plantas e tarefas fictícias para testar a interface. Continuar?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final theme = Theme.of(context);

                  navigator.pop();

                  // Show loading
                  _showLoadingDialog(context);

                  try {
                    final testDataService = di.sl<TestDataGeneratorService>();
                    await testDataService.generateTestData();

                    navigator.pop(); // Close loading

                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Dados de teste gerados com sucesso!',
                        ),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                    );
                  } catch (e) {
                    navigator.pop(); // Close loading

                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Erro ao gerar dados: $e'),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Gerar',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showLoadingDialog(
    BuildContext context, [
    String message = 'Gerando dados de teste...',
  ]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Sair do App',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              'Tem certeza que deseja sair?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Handle logout
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(
                  'Sair',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
