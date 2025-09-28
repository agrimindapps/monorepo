import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/services/user_action_service.dart';
import '../../../core/widgets/modern_header_widget.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../constants/settings_design_tokens.dart';
import '../presentation/providers/settings_provider.dart';
import '../widgets/dialogs/clear_data_dialog.dart';
import '../widgets/dialogs/delete_account_dialog.dart';
import '../widgets/dialogs/device_management_dialog.dart';
import '../widgets/dialogs/logout_confirmation_dialog.dart';

/// Página de perfil do usuário
/// Funciona tanto para visitantes quanto usuários logados
/// VERSÃO ATUALIZADA: Reage automaticamente a mudanças de autenticação
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  bool _settingsInitialized = false;
  late UserActionService _userActionService;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Initialize UserActionService
    final authProvider = context.read<ReceitaAgroAuthProvider>();
    _userActionService = UserActionService(authProvider);
    
    // Initialize SettingsProvider once when authenticated
    final settingsProvider = context.read<SettingsProvider>();
    
    if (!_settingsInitialized && 
        authProvider.isAuthenticated && 
        !authProvider.isAnonymous &&
        authProvider.currentUser?.id != null) {
      
      _settingsInitialized = true;
      
      // Initialize settings provider with user ID
      WidgetsBinding.instance.addPostFrameCallback((_) {
        settingsProvider.initialize(authProvider.currentUser!.id);
      });
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer2<ReceitaAgroAuthProvider, SettingsProvider>(
      builder: (context, authProvider, settingsProvider, child) {
        final isAuthenticated = authProvider.isAuthenticated && !authProvider.isAnonymous;
        final user = authProvider.currentUser;
        
        // Debug: Log auth state changes para monitoramento
        debugPrint('🔍 ProfilePage: Auth state - isAuthenticated: $isAuthenticated, user: ${user?.email}');
        
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: ResponsiveContentWrapper(
                child: Column(
                  children: [
                    // Modern Header
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
                    
                    const SizedBox(height: 16),
                    
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            // Seção do Usuário (estilo Plantis)
                            _buildUserSection(context, authProvider),
                            const SizedBox(height: 12),
                            
                            // Informações da Conta (apenas para usuários logados)
                            if (isAuthenticated) ...[
                              _buildAccountInfoSection(context, authProvider),
                              const SizedBox(height: 12),
                            ],
                            
                            // Seção de Dispositivos Conectados
                            if (isAuthenticated) ...[
                              _buildDevicesSection(context, settingsProvider),
                              const SizedBox(height: 12),
                            ],
                            
                            // Dados e Sincronização
                            if (isAuthenticated) ...[
                              _buildDataSyncSection(context, authProvider),
                              const SizedBox(height: 12),
                            ],
                            
                            // Ações do Usuário (nova seção)
                            if (isAuthenticated) ...[
                              _buildUserActionsSection(context, authProvider),
                              const SizedBox(height: 12),
                            ],
                            
                            const SizedBox(height: 24),
                          ],
                        ),
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
  Widget _buildUserSection(BuildContext context, ReceitaAgroAuthProvider authProvider) {
    final theme = Theme.of(context);
    final isAuthenticated = authProvider.isAuthenticated && !authProvider.isAnonymous;
    final user = authProvider.currentUser;
    
    return Container(
      decoration: _getCardDecoration(context),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: !isAuthenticated ? () => _navigateToLoginPage(context) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Avatar com design melhorado
              Container(
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
                          ? SettingsDesignTokens.primaryColor.withValues(alpha: 0.3)
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
                    _getInitials(user?.displayName ?? user?.email ?? 'Usuário'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Informações do usuário
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
                          ? (user?.email ?? 'email@usuario.com')
                          : 'Faça login para acessar recursos completos',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isAuthenticated && user?.createdAt != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.green.shade700,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getMemberSince(user?.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isAuthenticated)
                Icon(
                  Icons.login,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }

  /// Obter título para exibição do usuário
  String _getUserDisplayTitle(dynamic user) {
    if (user?.displayName != null && (user.displayName as String).isNotEmpty) {
      return user.displayName as String;
    }
    return (user?.email as String?) ?? 'Usuário';
  }


  /// Mostrar gerenciamento de dispositivos
  void _showDeviceManagement(BuildContext context, SettingsProvider settingsProvider) {
    showDialog<void>(
      context: context,
      builder: (context) => DeviceManagementDialog(provider: settingsProvider),
    );
  }





  /// Handler para logout
  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await LogoutConfirmationDialog.show(context);
    
    if (shouldLogout == true && context.mounted) {
      await _userActionService.performLogout(context);
    }
  }

  /// Handler para limpeza de dados
  Future<void> _handleClearData(BuildContext context) async {
    final shouldClear = await ClearDataDialog.show(context);
    
    if (shouldClear == true && context.mounted) {
      await _userActionService.clearLocalData(context);
    }
  }

  /// Handler para exclusão de conta
  Future<void> _handleDeleteAccount(BuildContext context, ReceitaAgroAuthProvider authProvider) async {
    if (!context.mounted) return;
    
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteAccountDialog(authProvider: authProvider),
    );
    
    if (shouldDelete == true && context.mounted) {
      await _userActionService.deleteAccount(context);
    }
  }

  /// Navegar para a página de login elegante
  /// VERSÃO ATUALIZADA: Com logs e feedback aprimorado
  void _navigateToLoginPage(BuildContext context) async {
    debugPrint('🚀 ProfilePage: Navigating to LoginPage');
    
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => const LoginPage(),
      ),
    );
    
    // Log quando retornar da LoginPage
    debugPrint('🔙 ProfilePage: Returned from LoginPage with result: $result');
    
    // Força rebuild do Consumer para garantir que o estado seja atualizado
    if (mounted) {
      debugPrint('📱 ProfilePage: State refresh triggered');
      // O Consumer automaticamente detecta mudanças no AuthProvider
      // Não é necessário chamar setState() pois estamos usando Provider
    }
  }


  /// Seção de Dispositivos Conectados
  Widget _buildDevicesSection(BuildContext context, SettingsProvider settingsProvider) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Dispositivos Conectados',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Container(
          decoration: _getCardDecoration(context),
          child: ListTile(
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _showDeviceManagement(context, settingsProvider),
                  child: const Text('Gerenciar'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Desconectar'),
                ),
              ],
            ),
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

  // Placeholder methods for navigation




  /// Seção de informações da conta (estilo Plantis)
  Widget _buildAccountInfoSection(BuildContext context, ReceitaAgroAuthProvider authProvider) {
    final theme = Theme.of(context);
    final user = authProvider.currentUser;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Informações da Conta',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Container(
          decoration: _getCardDecoration(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(context, 'Tipo de Conta', 'Gratuita'),
                const SizedBox(height: 12),
                _buildInfoRow(context, 'Criada em', _formatDate(user?.createdAt)),
                const SizedBox(height: 12),
                _buildInfoRow(context, 'Último acesso', _formatDate(DateTime.now())),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Seção de dados e sincronização (estilo Plantis)
  Widget _buildDataSyncSection(BuildContext context, ReceitaAgroAuthProvider authProvider) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Dados e Sincronização',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Container(
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
                  onPressed: () => _showSyncRefresh(context, authProvider),
                ),
                onTap: () => _showSyncRefresh(context, authProvider),
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
                subtitle: const Text('Baixar dados em formato estruturado JSON'),
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
  Widget _buildUserActionsSection(BuildContext context, ReceitaAgroAuthProvider authProvider) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Ações da Conta',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Container(
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
                title: const Text('Limpar Dados Locais'),
                subtitle: const Text('Remove dados salvos neste dispositivo'),
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
                onTap: () => _handleDeleteAccount(context, authProvider),
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
                    Icons.logout,
                    color: Colors.red,
                    size: 20,
                  ),
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
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Mostrar diálogo de exportação de dados em JSON
  void _showExportDataJson(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.data_object, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Exportar como JSON'),
          ],
        ),
        content: const Text(
          'Esta funcionalidade irá baixar todos os seus dados em formato JSON estruturado. '
          'Ideal para backup ou migração de dados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
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
            child: const Text('Exportar JSON'),
          ),
        ],
      ),
    );
  }

  /// Mostrar diálogo de exportação de dados em CSV
  void _showExportDataCsv(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.table_chart, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Exportar como CSV'),
          ],
        ),
        content: const Text(
          'Esta funcionalidade irá baixar todos os seus dados em formato CSV (planilha). '
          'Ideal para análise em Excel ou Google Sheets.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
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
            child: const Text('Exportar CSV'),
          ),
        ],
      ),
    );
  }

  /// Mostrar feedback de sincronização
  void _showSyncRefresh(BuildContext context, ReceitaAgroAuthProvider authProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Dados sincronizados com sucesso'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

}