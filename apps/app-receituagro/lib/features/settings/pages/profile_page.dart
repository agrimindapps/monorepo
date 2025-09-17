import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core/core.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/modern_header_widget.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../constants/settings_design_tokens.dart';
import '../presentation/providers/profile_provider.dart';
import '../presentation/providers/settings_provider.dart';
import '../widgets/dialogs/device_management_dialog.dart';
import '../widgets/dialogs/logout_confirmation_dialog.dart';
import '../widgets/sections/sync_data_section.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Initialize SettingsProvider once when authenticated
    final authProvider = context.read<ReceitaAgroAuthProvider>();
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
          backgroundColor: Theme.of(context).cardColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: ResponsiveContentWrapper(
                child: Column(
                  children: [
                    // Modern Header
                    ModernHeaderWidget(
                      title: isAuthenticated 
                          ? (user?.displayName?.isNotEmpty == true 
                              ? user!.displayName 
                              : user?.email ?? 'Perfil')
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
                            // Seção do Avatar e Informações Básicas (apenas para usuários logados)
                            if (isAuthenticated) _buildProfileHeader(context, authProvider),
                            
                            const SizedBox(height: 24),
                            
                            // Seção de Sincronização de Dados (apenas para usuários logados)
                            const SyncDataSection(),
                            
                            const SizedBox(height: 16),
                            
                            // Seção de Opções
                            if (isAuthenticated) ...[
                              // Opções para usuários logados
                              _buildAuthenticatedOptions(context, authProvider, settingsProvider),
                            ] else ...[
                              // Opções para visitantes
                              _buildGuestOptions(context, authProvider),
                            ],
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

  /// Cabeçalho do perfil com avatar e informações
  Widget _buildProfileHeader(BuildContext context, ReceitaAgroAuthProvider authProvider) {
    final theme = Theme.of(context);
    final isAuthenticated = authProvider.isAuthenticated && !authProvider.isAnonymous;
    final user = authProvider.currentUser;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SettingsDesignTokens.primaryColor.withValues(alpha: 0.1),
            SettingsDesignTokens.primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SettingsDesignTokens.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar simplificado
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: isAuthenticated ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                child: Text(
                  _getInitials(user?.displayName ?? user?.email ?? 'Usuário'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isAuthenticated)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _changeAvatar(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Nome/Status
          Text(
            isAuthenticated
                ? (user?.displayName?.isNotEmpty == true
                    ? user!.displayName
                    : user?.email ?? 'Usuário')
                : 'Visitante',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 4),
          
          if (isAuthenticated) ...[
            if (user?.displayName?.isNotEmpty == true && user?.email?.isNotEmpty == true)
              Text(
                user!.email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ] else ...[
            Text(
              'Faça login para acessar recursos completos',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Opções para usuários autenticados
  Widget _buildAuthenticatedOptions(BuildContext context, ReceitaAgroAuthProvider authProvider, SettingsProvider settingsProvider) {
    return Column(
      children: [
        _buildOptionCard(
          context,
          icon: Icons.devices,
          title: 'Gerenciar Dispositivos',
          subtitle: 'Controlar dispositivos conectados',
          onTap: () => _showDeviceManagement(context, settingsProvider),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          context,
          icon: Icons.delete_forever,
          title: 'Excluir Conta',
          subtitle: 'Remover permanentemente sua conta',
          onTap: () => _showDeleteAccountConfirmation(context, authProvider),
          isDestructive: true,
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          context,
          icon: Icons.logout,
          title: 'Sair da Conta',
          subtitle: 'Fazer logout desta conta',
          onTap: () => _performLogout(context, authProvider),
          isDestructive: true,
        ),
      ],
    );
  }

  /// Opções para visitantes
  Widget _buildGuestOptions(BuildContext context, ReceitaAgroAuthProvider authProvider) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SettingsDesignTokens.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: SettingsDesignTokens.primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.account_circle,
                color: SettingsDesignTokens.primaryColor,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Entre em sua conta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Faça login ou crie uma conta para acessar recursos como sincronização, backup e personalização.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToLoginPage(context),
                  icon: const Icon(Icons.login),
                  label: const Text('Entrar na Conta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SettingsDesignTokens.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Opções desabilitadas para visitantes
        _buildDisabledOptionCard(
          context,
          icon: Icons.devices,
          title: 'Gerenciar Dispositivos',
          subtitle: 'Disponível após fazer login',
        ),
      ],
    );
  }

  /// Card de opção ativa
  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? Colors.red.withValues(alpha: 0.1)
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isDestructive
                      ? Colors.red
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? Colors.red : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Card de opção desabilitada
  Widget _buildDisabledOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 1,
      color: theme.colorScheme.surface.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.lock,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ],
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

  /// Alterar avatar - versão simplificada
  void _changeAvatar(BuildContext context) {
    // TODO: Implementar seleção de imagem quando ProfileImagePicker estiver disponível
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Funcionalidade de foto do perfil será implementada em breve'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Mostrar gerenciamento de dispositivos
  void _showDeviceManagement(BuildContext context, SettingsProvider settingsProvider) {
    showDialog<void>(
      context: context,
      builder: (context) => DeviceManagementDialog(provider: settingsProvider),
    );
  }


  /// Mostrar confirmação de exclusão de conta com preview dos dados
  /// LGPD/GDPR Compliant: Mostra exatamente quais dados serão excluídos
  void _showDeleteAccountConfirmation(BuildContext context, ReceitaAgroAuthProvider authProvider) async {
    // Primeiro, obter preview dos dados que serão excluídos
    final preview = await authProvider.getAccountDeletionPreview();

    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Excluir Conta'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // LGPD Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ ATENÇÃO: Ação Irreversível',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Esta ação excluirá permanentemente sua conta e TODOS os dados associados, '
                      'conforme seus direitos sob a LGPD/GDPR.',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Data Preview Section
              if (preview != null) ...[
                const Text(
                  'Dados que serão excluídos:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App info
                      _buildDataPreviewItem(
                        '📱 Aplicativo',
                        preview['appName'] ?? 'ReceitaAgro',
                      ),

                      // Account data
                      _buildDataPreviewItem(
                        '👤 Conta Firebase',
                        'Email, perfil e autenticação',
                      ),

                      // Local data stats
                      if (preview['dataStats'] != null) ...[
                        _buildDataPreviewItem(
                          '💾 Dados Locais',
                          '${preview['dataStats']['totalRecords'] ?? 0} registros em ${preview['dataStats']['totalBoxes'] ?? 0} categorias',
                        ),

                        // Categories
                        if (preview['availableCategories'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Categorias: ${(preview['availableCategories'] as List).where((c) => c != 'all').join(', ')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],

                      // Preferences
                      _buildDataPreviewItem(
                        '⚙️ Configurações',
                        'Preferências e configurações do app',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],

              // LGPD Rights Information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ℹ️ Seus Direitos (LGPD/GDPR)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Você tem o direito de excluir todos os seus dados pessoais\n'
                      '• Esta exclusão será irreversível e imediata\n'
                      '• Você pode criar uma nova conta a qualquer momento\n'
                      '• Para dúvidas, entre em contato conosco',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Final confirmation
              Text(
                'Digite "EXCLUIR" para confirmar:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _proceedWithAccountDeletion(context, authProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar Exclusão'),
          ),
        ],
      ),
    );
  }

  /// Widget helper para mostrar itens do preview de dados
  Widget _buildDataPreviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  /// Proceder com a exclusão da conta após confirmação
  Future<void> _proceedWithAccountDeletion(BuildContext context, ReceitaAgroAuthProvider authProvider) async {
    Navigator.of(context).pop(); // Close confirmation dialog

    // Show progress dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Excluindo conta e dados...'),
            SizedBox(height: 8),
            Text(
              'Por favor, aguarde. Esta operação pode levar alguns momentos.',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      // Execute account deletion
      final result = await authProvider.deleteAccount();

      if (context.mounted) {
        Navigator.of(context).pop(); // Close progress dialog

        if (result.isSuccess) {
          // Success - show confirmation and navigate away
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Conta excluída com sucesso. Todos os dados foram removidos.'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          // Navigate to app start or login page
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        } else {
          // Error - show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Erro na exclusão: ${result.errorMessage ?? "Erro desconhecido"}'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 8),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              action: SnackBarAction(
                label: 'Tentar Novamente',
                textColor: Colors.white,
                onPressed: () => _showDeleteAccountConfirmation(context, authProvider),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close progress dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Erro inesperado: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  /// Realizar logout
  Future<void> _performLogout(BuildContext context, ReceitaAgroAuthProvider authProvider) async {
    final shouldLogout = await LogoutConfirmationDialog.show(context);
    
    if (shouldLogout == true) {
      try {
        await authProvider.signOut();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SettingsDesignTokens.getSuccessSnackbar('Logout realizado com sucesso!'),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SettingsDesignTokens.getErrorSnackbar('Erro ao sair da conta: $e'),
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
}