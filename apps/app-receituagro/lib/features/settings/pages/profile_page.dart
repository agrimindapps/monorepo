import 'package:core/core.dart' as core;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/modern_header_widget.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../../subscription/presentation/providers/subscription_notifier.dart';
import '../../subscription/presentation/widgets/subscription_progress_widget.dart';
import '../constants/settings_design_tokens.dart';
import '../presentation/providers/user_settings_notifier.dart';
import '../widgets/dialogs/clear_data_dialog.dart';
import '../widgets/dialogs/delete_account_dialog.dart';
import '../widgets/dialogs/device_management_dialog.dart';
import '../widgets/dialogs/logout_confirmation_dialog.dart';

/// Página de perfil do usuário
/// Funciona tanto para visitantes quanto usuários logados
/// VERSÃO ATUALIZADA: Reage automaticamente a mudanças de autenticação
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController _nameController;
  bool _settingsInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authAsync = ref.watch(authProvider);
    final settingsState = ref.watch(userSettingsProvider);

    // Handle AsyncValue states
    return authAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Erro: $error'))),
      data: (authState) {
        final authData = authState;
        final isAuthenticated = authData.isAuthenticated && !authData.isAnonymous;
        final user = authData.currentUser;
        if (!_settingsInitialized && isAuthenticated && user?.id != null) {
          _settingsInitialized = true;
          final userId = user?.id;
          if (userId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(userSettingsProvider.notifier).initialize(userId);
            });
          }
        }
        debugPrint(
          '🔍 ProfilePage: Auth state - isAuthenticated: $isAuthenticated, user: ${user?.email}',
        );

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ResponsiveContentWrapper(
                child: Column(
                  children: [
                    ModernHeaderWidget(
                      title: isAuthenticated
                          ? _getUserDisplayTitle(user)
                          : 'Perfil do Visitante',
                      subtitle: isAuthenticated
                          ? 'Gerencie sua conta e configurações'
                          : 'Entre em sua conta para recursos completos',
                      leftIcon: Icons.person,
                  showBackButton: true,
                  isDark: isDark,
                ),

                const SizedBox(height: 12),
                Expanded(
                  child: settingsState.when(
                    data: (settingsData) => SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildUserSection(context, authData),
                          const SizedBox(height: 8),
                          if (isAuthenticated) ...[
                            _buildSubscriptionSection(context),
                            const SizedBox(height: 8),
                          ],
                          if (isAuthenticated) ...[
                            _buildAccountInfoSection(context, authData),
                            const SizedBox(height: 8),
                          ],
                          if (isAuthenticated) ...[
                            _buildDevicesSection(context, settingsData),
                            const SizedBox(height: 8),
                          ],
                          if (isAuthenticated) ...[
                            _buildDataSyncSection(context, authData),
                            const SizedBox(height: 8),
                          ],
                          if (isAuthenticated) ...[
                            _buildUserActionsSection(context, authData),
                            const SizedBox(height: 8),
                          ],

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) =>
                        Center(child: Text('Erro: $error')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  /// Seção do usuário estilo Plantis
  Widget _buildUserSection(BuildContext context, dynamic authData) {
    final theme = Theme.of(context);
    final bool isAuthBool = authData?.isAuthenticated == true;
    final bool isAnonBool = authData?.isAnonymous == true;
    final isAuthenticated = isAuthBool && !isAnonBool;
    final user = authData?.currentUser;

    return Container(
      decoration: _getCardDecoration(context),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: !isAuthenticated ? () => _navigateToLoginPage(context) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isAuthenticated
                        ? SettingsDesignTokens.primaryColor
                        : Colors.grey.shade400,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isAuthenticated
                          ? SettingsDesignTokens.primaryColor.withValues(
                              alpha: 0.3,
                            )
                          : Colors.grey.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: isAuthenticated
                      ? SettingsDesignTokens.primaryColor
                      : Colors.grey.shade400,
                  child: Text(
                    _getInitials(_getUserDisplayTitle(user)),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isAuthenticated
                                ? _getUserDisplayTitle(user)
                                : 'Visitante',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAuthenticated
                          ? ((user?.email is String)
                                ? (user?.email as String)
                                : 'email@usuario.com')
                          : 'Faça login para acessar recursos completos',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isAuthenticated && user?.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getMemberSince(user?.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!isAuthenticated)
                Icon(Icons.login, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  /// Obter iniciais do nome
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.split(' ');
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'
        .toUpperCase();
  }

  /// Obter título para exibição do usuário
  String _getUserDisplayTitle(dynamic user) {
    final displayName = user?.displayName;
    if (displayName != null &&
        displayName is String &&
        displayName.isNotEmpty) {
      return displayName;
    }
    final email = user?.email;
    return (email is String ? email : null) ?? 'Usuário';
  }

  /// Mostrar gerenciamento de dispositivos
  void _showDeviceManagement(BuildContext context, dynamic settingsData) {
    showDialog<void>(
      context: context,
      builder: (context) => DeviceManagementDialog(settingsData: settingsData),
    );
  }

  /// Handler para logout
  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await LogoutConfirmationDialog.show(context);

    if (shouldLogout == true && context.mounted) {
      try {
        // Realizar logout
        await ref.read(authProvider.notifier).signOut();

        if (context.mounted) {
          // Mostrar mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logout realizado com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Aguardar um pouco para o snackbar ser visível
          await Future<void>.delayed(const Duration(milliseconds: 500));

          // Navegar de volta para Settings
          if (context.mounted) {
            Navigator.of(context).popUntil((route) {
              // Volta até encontrar a SettingsPage (ou sai da pilha)
              return route.isFirst;
            });
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao sair: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  /// Handler para limpeza de dados
  Future<void> _handleClearData(BuildContext context) async {
    final shouldClear = await ClearDataDialog.show(context);

    if (shouldClear == true && context.mounted) {
      final authState = ref.read(authProvider).value;
      final userId = authState?.currentUser?.id ?? 'unknown';

      try {
        // Obter o serviço de analytics
        final analytics = ref.read(analyticsServiceProvider);

        // Rastrear tentativa de limpeza
        analytics.trackEvent(
          'clear_data_attempt',
          parameters: {'user_id': userId, 'trigger_source': 'profile_page'},
        );

        // Mostrar loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Limpando dados locais...'),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 30),
          ),
        );

        // Obter o serviço de limpeza
        final dataCleaner = ref.read(dataCleanerServiceProvider);

        // Verificar se há dados para limpar
        final hasData = await dataCleaner.hasDataToClear();
        if (!hasData) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.info, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Não há dados locais para limpar'),
                  ],
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          analytics.trackEvent(
            'clear_data_no_data',
            parameters: {'user_id': userId},
          );
          return;
        }

        // Obter estatísticas antes da limpeza
        final stats = await dataCleaner.getDataStatsBeforeCleaning();
        debugPrint('📊 Dados a serem limpos: $stats');

        // Executar limpeza completa
        final result = await dataCleaner.clearAllAppData();

        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();

          final success = result['success'] as bool? ?? false;
          final errors = result['errors'] as List? ?? [];
          final totalCleared = result['totalRecordsCleared'] as int? ?? 0;
          final duration = result['duration'] as int? ?? 0;

          if (success && errors.isEmpty) {
            // Sucesso completo
            analytics.trackEvent(
              'clear_data_success',
              parameters: {
                'user_id': userId,
                'total_cleared': totalCleared.toString(),
                'duration_ms': duration.toString(),
              },
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dados limpos com sucesso! $totalCleared registros removidos',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (success && errors.isNotEmpty) {
            // Sucesso parcial com alguns erros
            analytics.trackEvent(
              'clear_data_partial',
              parameters: {
                'user_id': userId,
                'total_cleared': totalCleared.toString(),
                'errors_count': errors.length.toString(),
              },
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dados limpos com ${errors.length} avisos',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            // Erro na limpeza
            final mainError =
                result['mainError']?.toString() ?? 'Erro desconhecido';
            analytics.trackEvent(
              'clear_data_failed',
              parameters: {'user_id': userId, 'error': mainError},
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Erro ao limpar dados: $mainError',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } catch (e) {
        final analytics = ref.read(analyticsServiceProvider);
        analytics.trackError('clear_data_exception', e.toString());

        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Erro inesperado ao limpar dados: $e',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  /// Handler para exclusão de conta
  Future<void> _handleDeleteAccount(BuildContext context) async {
    if (!context.mounted) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DeleteAccountDialog(),
    );

    if (shouldDelete == true && context.mounted) {
      try {
        final result = await ref
            .read(authProvider.notifier)
            .deleteAccount();
        if (context.mounted) {
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Conta excluída com sucesso'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro: ${result.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir conta: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Navegar para a página de login elegante
  /// VERSÃO ATUALIZADA: Com logs e feedback aprimorado
  void _navigateToLoginPage(BuildContext context) async {
    debugPrint('🚀 ProfilePage: Navigating to LoginPage');

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (context) => const LoginPage()),
    );
    debugPrint('🔙 ProfilePage: Returned from LoginPage with result: $result');
    if (mounted) {
      debugPrint('📱 ProfilePage: State refresh triggered');
    }
  }

  /// Seção de Dispositivos Conectados
  Widget _buildDevicesSection(BuildContext context, dynamic settingsData) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
          child: Text(
            'Dispositivos Conectados',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        DecoratedBox(
          decoration: _getCardDecoration(context),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.smartphone,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
                title: const Text('Nenhum dispositivo registrado'),
                subtitle: const Text('Recursos em desenvolvimento'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showDeviceManagement(context, settingsData),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showDeviceManagement(context, settingsData),
                        icon: const Icon(Icons.devices, size: 18),
                        label: const Text('Gerenciar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Desconectar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper: Decoração de card
  BoxDecoration _getCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Helper: Obter tempo de membro
  String _getMemberSince(dynamic createdAt) {
    if (createdAt == null) return 'Membro desde 10 dias';
    final DateTime date = createdAt is DateTime ? createdAt : DateTime.now();

    final now = DateTime.now();
    final difference = now.difference(date);

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

  /// Seção de assinatura premium
  Widget _buildSubscriptionSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
          child: Text(
            'Assinatura Premium',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        DecoratedBox(
          decoration: _getCardDecoration(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer(
              builder: (context, ref, child) {
                final subscriptionAsync = ref.watch(
                  subscriptionManagementProvider,
                );

                return subscriptionAsync.when(
                  data: (subscriptionState) {
                    if (!subscriptionState.hasActiveSubscription ||
                        subscriptionState.currentSubscription == null) {
                      return _buildNoPremiumWidget(context);
                    }

                    final subscription = subscriptionState.currentSubscription;
                    if (subscription?.expirationDate == null) {
                      return _buildNoPremiumWidget(context);
                    }

                    return SubscriptionProgressWidget(
                      expirationDate: subscription!.expirationDate!,
                      purchaseDate: subscription.purchaseDate,
                      isSandbox: subscription.isSandbox,
                      isCompact: true,
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => _buildNoPremiumWidget(context),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Widget para quando não tem premium
  Widget _buildNoPremiumWidget(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              color: Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Assinatura Gratuita',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            // Navegar para página de planos
            Navigator.pushNamed(context, '/subscription');
          },
          icon: const Icon(Icons.upgrade, size: 18),
          label: const Text('Assinar Premium'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 40),
          ),
        ),
      ],
    );
  }

  /// Seção de informações da conta (estilo Plantis)
  Widget _buildAccountInfoSection(BuildContext context, dynamic authData) {
    final theme = Theme.of(context);
    final user = authData.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
          child: Text(
            'Informações da Conta',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        DecoratedBox(
          decoration: _getCardDecoration(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(context, 'Tipo de Conta', 'Gratuita'),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  'Criada em',
                  _formatDate(user?.createdAt),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  'Último acesso',
                  _formatDate(DateTime.now()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Seção de dados e sincronização (estilo Plantis)
  Widget _buildDataSyncSection(BuildContext context, dynamic authData) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
          child: Text(
            'Dados e Sincronização',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        DecoratedBox(
          decoration: _getCardDecoration(context),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.cloud_done,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                title: const Text('Dados Sincronizados'),
                subtitle: const Text('Todos os dados estão atualizados'),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _showSyncRefresh(context),
                ),
                onTap: () => _showSyncRefresh(context),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.data_object,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                title: const Text('Exportar como JSON'),
                subtitle: const Text(
                  'Baixar dados em formato estruturado JSON',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showExportDataJson(context),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.table_chart,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                title: const Text('Exportar como CSV'),
                subtitle: const Text('Baixar dados em formato planilha CSV'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showExportDataCsv(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Seção de Ações do Usuário (nova seção)
  Widget _buildUserActionsSection(BuildContext context, dynamic authData) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
          child: Text(
            'Ações da Conta',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        DecoratedBox(
          decoration: _getCardDecoration(context),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_sweep,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                title: const Text('Remover Dados Pessoais'),
                subtitle: const Text(
                  'Remove dados e sincroniza com outros dispositivos',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _handleClearData(context),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                title: const Text('Excluir Conta'),
                subtitle: const Text('Remove permanentemente sua conta'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _handleDeleteAccount(context),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout, color: Colors.red, size: 20),
                ),
                title: const Text('Sair da Conta'),
                subtitle: const Text('Fazer logout desta conta'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _handleLogout(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget para linha de informação (estilo Plantis)
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Formatar data para exibição
  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final DateTime dateTime = date is DateTime ? date : DateTime.now();
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  /// Mostrar diálogo de exportação de dados em JSON
  void _showExportDataJson(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.data_object,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Exportar como JSON',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Esta funcionalidade irá baixar todos os seus dados em formato JSON estruturado. Ideal para backup ou migração de dados.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.construction, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Exportação JSON em desenvolvimento'),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: const Text(
                            'Exportar JSON',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mostrar diálogo de exportação de dados em CSV
  void _showExportDataCsv(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.table_chart,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Exportar como CSV',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Esta funcionalidade irá baixar todos os seus dados em formato CSV (planilha). Ideal para análise em Excel ou Google Sheets.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.construction, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Exportação CSV em desenvolvimento'),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: const Text(
                            'Exportar CSV',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Executar sincronização real de dados
  /// ✅ FIXED: Agora usa ReceitaAgroSyncService ao invés de fake feedback
  Future<void> _showSyncRefresh(BuildContext context) async {
    // Mostrar loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Sincronizando dados...'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 30), // Longa duração durante sync
      ),
    );

    try {
      // Obter o serviço de sincronização
      final syncService = ref.read(receitaAgroSyncServiceProvider);

      // Verificar se pode sincronizar
      if (!syncService.canSync) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Serviço de sincronização não está pronto'),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Executar sincronização completa
      final result = await syncService.sync();

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        result.fold(
          // Erro na sincronização
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Erro ao sincronizar: ${failure.message}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          },
          // Sucesso
          (syncResult) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        syncResult.success
                            ? 'Sincronizado! ${syncResult.itemsSynced} itens em ${syncResult.duration.inSeconds}s'
                            : 'Sincronização parcial: ${syncResult.itemsSynced} OK, ${syncResult.itemsFailed} falhas',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                backgroundColor: syncResult.success
                    ? Colors.green
                    : Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Erro inesperado: $e',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
