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
          // Avatar com ProfileProvider
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              return ProfileAvatar(
                imageUrl: profileProvider.currentProfileImageUrl,
                displayName: user?.displayName ?? user?.email,
                size: 100,
                gradient: isAuthenticated
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4CAF50), // Green 500
                          Color(0xFF2E7D32), // Green 700
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey.shade400, Colors.grey.shade600],
                      ),
                showEditIcon: isAuthenticated,
                onEditTap: isAuthenticated ? () => _changeAvatar(context) : null,
              );
            },
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

  /// Alterar avatar usando ProfileImagePicker
  void _changeAvatar(BuildContext context) {
    final profileProvider = context.read<ProfileProvider>();
    
    ProfileImagePicker.show(
      context: context,
      profileImageService: ProfileImageServiceFactory.createDefault(),
      primaryColor: SettingsDesignTokens.primaryColor,
      onImageSelected: (imageFile) async {
        // Mostrar loading
        final success = await profileProvider.uploadProfileImage(imageFile);
        
        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Foto do perfil atualizada com sucesso!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(profileProvider.errorMessage ?? 'Erro ao atualizar foto'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        }
      },
      onCancel: () {
        if (kDebugMode) {
          print('📸 ProfilePage: Upload de imagem cancelado');
        }
      },
    );
  }

  /// Mostrar gerenciamento de dispositivos
  void _showDeviceManagement(BuildContext context, SettingsProvider settingsProvider) {
    showDialog<void>(
      context: context,
      builder: (context) => DeviceManagementDialog(provider: settingsProvider),
    );
  }


  /// Mostrar confirmação de exclusão de conta
  void _showDeleteAccountConfirmation(BuildContext context, ReceitaAgroAuthProvider authProvider) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text(
          'Esta ação é irreversível. Todos os seus dados serão permanentemente removidos.\n\n'
          'Tem certeza que deseja excluir sua conta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // TODO: Implementar exclusão de conta
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade de exclusão será implementada em breve'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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