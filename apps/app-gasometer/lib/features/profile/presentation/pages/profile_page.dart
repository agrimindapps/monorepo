import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
// import '../../../../core/sync/presentation/providers/sync_status_provider.dart'; // TODO: Replace with UnifiedSync in Phase 2
// import '../../../../core/sync/services/sync_status_manager.dart'; // TODO: Replace with UnifiedSync in Phase 2
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../data_export/presentation/widgets/export_data_section.dart';
import '../widgets/devices_section_widget.dart';
import '../widgets/profile_image_picker_widget.dart';
import '../../domain/services/profile_image_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        final isAnonymous = authProvider.isAnonymous;
        
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isAnonymous),
                Expanded(
                  child: Semantics(
                    label: 'Página de perfil do usuário',
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const ClampingScrollPhysics(),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Padding(
                            padding: EdgeInsets.all(
                              GasometerDesignTokens.responsiveSpacing(context),
                            ),
                            child: _buildContent(context, authProvider, user, isAnonymous),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isAnonymous) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: GasometerDesignTokens.colorHeaderBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: GasometerDesignTokens.colorHeaderBackground.withValues(alpha: 0.2),
            blurRadius: 9,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Semantics(
              label: 'Seção de perfil do usuário',
              hint: 'Página principal para gerenciar perfil',
              child: Icon(
                isAnonymous ? Icons.person_outline : Icons.person,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Meu Perfil',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  isAnonymous 
                      ? 'Usuário Anônimo' 
                      : 'Gerencie suas informações',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuthProvider authProvider, dynamic user, bool isAnonymous) {
    return Column(
      children: [
        // Seção principal do perfil
        _buildProfileSection(context, authProvider, user, isAnonymous),
        
        // Seção de dispositivos conectados (apenas para usuários registrados)
        if (!isAnonymous) ...[
          SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          const DevicesSectionWidget(),
        ],
        
        // Informações da conta (apenas para usuários registrados)
        if (!isAnonymous) ...[
          SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          _buildAccountInfoSection(context, user, authProvider),
        ],
        
        // Sincronização (apenas para usuários registrados)
        if (!isAnonymous) ...[
          SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          _buildSyncSection(context),
        ],
        
        // Configurações e privacidade
        SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildSettingsSection(context, isAnonymous),
        
        // Exportação de dados (apenas para usuários registrados)
        if (!isAnonymous) ...[
          SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          const ExportDataSection(),
        ],
        
        // Ações da conta
        SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildActionsSection(context, authProvider, isAnonymous),
      ],
    );
  }

  Widget _buildProfileSection(BuildContext context, AuthProvider authProvider, dynamic user, bool isAnonymous) {
    return _buildSection(
      context,
      title: 'Informações Pessoais',
      icon: Icons.person,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
          ),
          child: Column(
            children: [
              // Avatar section with edit functionality
              _buildAvatarSection(context, authProvider, user, isAnonymous),
              const SizedBox(height: 20),
              
              if (isAnonymous) ...[
                // Anonymous user info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.info, color: Colors.orange.shade700),
                      const SizedBox(height: 8),
                      Text(
                        'Usuário Anônimo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Seus dados estão salvos localmente. Para sincronizar entre dispositivos e ter acesso a recursos avançados, crie uma conta.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Criar Conta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Registered user profile display
                Column(
                  children: [
                    _buildProfileInfoRow(
                      'Nome',
                      (user?.displayName as String?) ?? 'Não informado',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _buildProfileInfoRow(
                      'Email',
                      (user?.email as String?) ?? 'Não informado',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 24),
                    
                    // Premium status
                    if (authProvider.isPremium) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: GasometerDesignTokens.getPremiumBackgroundWithOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: GasometerDesignTokens.colorPremiumAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Conta Premium Ativa',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: GasometerDesignTokens.colorPremiumAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfoSection(BuildContext context, dynamic user, AuthProvider authProvider) {
    return _buildSection(
      context,
      title: 'Informações da Conta',
      icon: Icons.info,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Tipo', authProvider.isPremium ? 'Premium' : 'Gratuita'),
              if (user?.createdAt != null)
                _buildInfoRow('Criada em', _formatDate(user!.createdAt as DateTime)),
              if (user?.lastSignInAt != null)
                _buildInfoRow('Último acesso', _formatDate(user!.lastSignInAt as DateTime)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSyncSection(BuildContext context) {
    // TODO: Phase 2 - Replace with UnifiedSync
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(Icons.sync, color: Theme.of(context).colorScheme.primary),
        title: Text('Sincronização'),
        subtitle: Text('Aguardando Phase 2 - UnifiedSync'),
        trailing: Icon(Icons.info_outline),
      ),
    );
    // Original sync implementation commented out for Phase 2
    // return Consumer<SyncStatusProvider>(
    //   builder: (context, syncProvider, _) {
    //     return Container(
    //       decoration: BoxDecoration(
    //         color: Theme.of(context).colorScheme.surfaceContainerHigh,
    //         borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
    //         border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    //       ),
    //       child: _buildSyncListTile(context, syncProvider),
    //     );
    //   },
    // );
  }

  // TODO: Phase 2 - Replace with UnifiedSync helper functions
  /// Constrói ListTile único para sincronização com status e ação - COMMENTED OUT FOR PHASE 1
  /*
  Widget _buildSyncListTile(BuildContext context, SyncStatusProvider syncProvider) {
    final syncColor = _getSyncStatusColor(context, syncProvider);
    final syncIcon = _getSyncStatusIcon(syncProvider);
    final isLoading = syncProvider.isLoading;
    final lastSyncText = syncProvider.friendlyMessage;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : () => _handleForceSync(context, syncProvider),
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
        child: Semantics(
          label: 'Sincronização de dados',
          hint: isLoading ? 'Sincronização em andamento' : 'Toque para forçar sincronização',
          button: true,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícone de status
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: syncColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(syncColor),
                          ),
                        )
                      : Icon(
                          syncIcon,
                          color: syncColor,
                          size: 20,
                        ),
                ),
                
                const SizedBox(width: 16),
                
                // Texto principal e subtítulo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sincronismo de Dados',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lastSyncText,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Ícone de ação à direita
                if (!isLoading)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.refresh,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  */

  Widget _buildSettingsSection(BuildContext context, bool isAnonymous) {
    return _buildSection(
      context,
      title: 'Configurações e Privacidade',
      icon: Icons.settings,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                context,
                icon: Icons.privacy_tip,
                title: 'Política de Privacidade',
                subtitle: 'Como tratamos seus dados',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/privacy');
                },
                isFirst: true,
              ),
              _buildSettingsItem(
                context,
                icon: Icons.description,
                title: 'Termos de Uso',
                subtitle: 'Condições de uso do aplicativo',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/terms');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context, AuthProvider authProvider, bool isAnonymous) {
    return _buildSection(
      context,
      title: 'Ações da Conta',
      icon: Icons.security,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                context,
                icon: Icons.logout,
                title: 'Sair da Conta',
                subtitle: isAnonymous ? 'Sair do modo anônimo' : 'Fazer logout',
                onTap: () => _handleLogout(context, authProvider),
                isFirst: true,
              ),
              if (!isAnonymous)
                _buildSettingsItem(
                  context,
                  icon: Icons.delete_forever,
                  title: 'Excluir Conta',
                  subtitle: 'Remover permanentemente sua conta',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showAccountDeletionDialog(context);
                  },
                  isLast: true,
                  isDestructive: true,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusCard),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: GasometerDesignTokens.iconSizeButton,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(
    String label,
    String value, {
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(12) : Radius.zero,
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: !isLast ? Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ) : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive 
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                size: GasometerDesignTokens.iconSizeListItem,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDestructive 
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói a seção do avatar com funcionalidade de edição
  Widget _buildAvatarSection(BuildContext context, AuthProvider authProvider, dynamic user, bool isAnonymous) {
    final photoUrl = user?.photoUrl as String?;
    final hasAvatar = photoUrl != null && photoUrl.isNotEmpty;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Avatar principal
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isAnonymous 
                  ? Colors.orange.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: hasAvatar
                ? _buildAvatarImage(photoUrl!)
                : _buildDefaultAvatar(context, user, isAnonymous),
          ),
        ),
        
        // Botão de editar (apenas para usuários registrados)
        if (!isAnonymous)
          Positioned(
            bottom: 0,
            right: 0,
            child: _buildEditButton(context, authProvider, hasAvatar),
          ),
      ],
    );
  }

  /// Constrói imagem do avatar a partir do base64
  Widget _buildAvatarImage(String imageSource) {
    try {
      // Verifica se é base64 ou URL
      if (imageSource.startsWith('data:image') || imageSource.startsWith('/9j/') || imageSource.startsWith('iVBOR')) {
        // É base64
        final base64String = imageSource.contains(',') 
            ? imageSource.split(',').last 
            : imageSource;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            if (kDebugMode) {
              debugPrint('❌ Error loading avatar image: $error');
            }
            return _buildDefaultAvatarIcon(context, false);
          },
        );
      } else {
        // É URL
        return Image.network(
          imageSource,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            if (kDebugMode) {
              debugPrint('❌ Error loading avatar URL: $error');
            }
            return _buildDefaultAvatarIcon(context, false);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error processing avatar image: $e');
      }
      return _buildDefaultAvatarIcon(context, false);
    }
  }

  /// Constrói avatar padrão
  Widget _buildDefaultAvatar(BuildContext context, dynamic user, bool isAnonymous) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: isAnonymous 
            ? Colors.orange.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: _buildDefaultAvatarIcon(context, isAnonymous),
    );
  }

  /// Constrói ícone padrão do avatar
  Widget _buildDefaultAvatarIcon(BuildContext context, bool isAnonymous) {
    return Icon(
      isAnonymous ? Icons.person_outline : Icons.person,
      size: 48,
      color: isAnonymous 
          ? Colors.orange
          : Theme.of(context).colorScheme.primary,
    );
  }

  /// Constrói botão de editar avatar
  Widget _buildEditButton(BuildContext context, AuthProvider authProvider, bool hasAvatar) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: GasometerDesignTokens.colorPrimary,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _handleEditAvatar(context, authProvider, hasAvatar),
          child: const Icon(
            Icons.edit,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  /// Manipula edição do avatar
  Future<void> _handleEditAvatar(BuildContext context, AuthProvider authProvider, bool hasAvatar) async {
    if (kDebugMode) {
      debugPrint('📷 ProfilePage: Opening avatar editor');
    }

    HapticFeedback.lightImpact();

    await ProfileImagePickerWidget.show(
      context: context,
      hasCurrentImage: hasAvatar,
      onImageSelected: (File imageFile) => _processNewImage(context, authProvider, imageFile),
      onRemoveImage: hasAvatar ? () => _removeCurrentImage(context, authProvider) : null,
    );
  }

  /// Processa nova imagem selecionada
  Future<void> _processNewImage(BuildContext context, AuthProvider authProvider, File imageFile) async {
    try {
      if (kDebugMode) {
        debugPrint('📷 ProfilePage: Processing new image: ${imageFile.path}');
      }

      // Mostrar loading
      _showImageProcessingDialog(context);

      // Obter serviço de processamento de imagem
      final imageService = GetIt.instance<GasometerProfileImageService>();

      // Validar imagem
      final validationResult = imageService.validateImageFile(imageFile);
      if (validationResult.isFailure) {
        Navigator.of(context).pop(); // Remove loading dialog
        _showErrorSnackBar(context, validationResult.failure.message);
        return;
      }

      // Processar imagem
      final result = await imageService.processImageToBase64(imageFile);
      
      result.fold(
        (failure) {
          Navigator.of(context).pop(); // Remove loading dialog
          _showErrorSnackBar(context, failure.message);
        },
        (base64String) async {
          // Atualizar avatar no AuthProvider
          final success = await authProvider.updateAvatar(base64String);
          
          Navigator.of(context).pop(); // Remove loading dialog
          
          if (success) {
            _showSuccessSnackBar(context, 'Foto do perfil atualizada com sucesso!');
          } else {
            _showErrorSnackBar(context, authProvider.errorMessage ?? 'Erro ao atualizar foto');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ProfilePage: Error processing image: $e');
      }
      
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Remove loading dialog
      }
      
      _showErrorSnackBar(context, 'Erro inesperado ao processar imagem');
    }
  }

  /// Remove imagem atual
  Future<void> _removeCurrentImage(BuildContext context, AuthProvider authProvider) async {
    try {
      if (kDebugMode) {
        debugPrint('🗑️ ProfilePage: Removing current avatar');
      }

      // Mostrar confirmação
      final confirmed = await _showRemoveConfirmationDialog(context);
      if (!confirmed) return;

      // Mostrar loading
      _showImageProcessingDialog(context);

      // Remover avatar
      final success = await authProvider.removeAvatar();
      
      Navigator.of(context).pop(); // Remove loading dialog
      
      if (success) {
        _showSuccessSnackBar(context, 'Foto do perfil removida com sucesso!');
      } else {
        _showErrorSnackBar(context, authProvider.errorMessage ?? 'Erro ao remover foto');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ProfilePage: Error removing image: $e');
      }
      
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Remove loading dialog
      }
      
      _showErrorSnackBar(context, 'Erro inesperado ao remover imagem');
    }
  }

  /// Mostra dialog de processamento de imagem
  void _showImageProcessingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Processando imagem...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// Mostra dialog de confirmação para remoção
  Future<bool> _showRemoveConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Foto'),
        content: const Text('Deseja realmente remover sua foto do perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  /// Mostra SnackBar de sucesso
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: GasometerDesignTokens.colorSuccess,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusButton,
          ),
        ),
      ),
    );
  }

  /// Mostra SnackBar de erro
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusButton,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // TODO: Phase 2 - Replace with UnifiedSync color mapping
  // Color _getSyncStatusColor(BuildContext context, SyncStatusProvider syncProvider) {
  //   switch (syncProvider.status) {
  //     case SyncStatus.idle:
  //       return syncProvider.hasQueueItems
  //           ? GasometerDesignTokens.colorWarning
  //           : GasometerDesignTokens.colorSuccess;
  //     case SyncStatus.syncing:
  //       return Theme.of(context).colorScheme.primary;
  //     case SyncStatus.error:
  //       return Theme.of(context).colorScheme.error;
  //     case SyncStatus.success:
  //       return GasometerDesignTokens.colorSuccess;
  //     case SyncStatus.conflict:
  //       return Theme.of(context).colorScheme.error;
  //     case SyncStatus.offline:
  //       return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
  //   }
  // }

  // TODO: Phase 2 - Replace with UnifiedSync icon mapping
  // IconData _getSyncStatusIcon(SyncStatusProvider syncProvider) {
  //   switch (syncProvider.status) {
  //     case SyncStatus.idle:
  //       return syncProvider.hasQueueItems ? Icons.schedule : Icons.check_circle;
  //     case SyncStatus.syncing:
  //       return Icons.sync;
  //     case SyncStatus.error:
  //       return Icons.error;
  //     case SyncStatus.success:
  //       return Icons.check_circle;
  //     case SyncStatus.conflict:
  //       return Icons.warning;
  //     case SyncStatus.offline:
  //       return Icons.cloud_off;
  //   }
  // }

  // TODO: Phase 2 - Replace with UnifiedSync force sync
  // Future<void> _handleForceSync(BuildContext context, SyncStatusProvider syncProvider) async {
  //   HapticFeedback.lightImpact();
  //
  //   try {
  //     await syncProvider.forceSyncNow();
  //
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text('Sincronização iniciada'),
  //           backgroundColor: GasometerDesignTokens.colorSuccess,
  //           behavior: SnackBarBehavior.floating,
  //           duration: const Duration(seconds: 2),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Erro ao sincronizar: $e'),
  //           backgroundColor: Theme.of(context).colorScheme.error,
  //           behavior: SnackBarBehavior.floating,
  //           duration: const Duration(seconds: 3),
  //         ),
  //       );
  //     }
  //   }
  // }

  /// Mostra dialog de confirmação para exclusão de conta
  Future<void> _showAccountDeletionDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _AccountDeletionDialog();
      },
    );
  }

  // Auth handling methods
  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Sair da Conta',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
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
              'Ao sair da sua conta, as seguintes ações serão realizadas:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildLogoutItem(context, Icons.cleaning_services, 'Limpeza de dados locais armazenados'),
            _buildLogoutItem(context, Icons.sync_disabled, 'Interrupção da sincronização automática'),
            _buildLogoutItem(context, Icons.login, 'Necessário fazer login novamente para acessar'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Seus dados na nuvem permanecem seguros e serão restaurados no próximo login',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
              ),
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await authProvider.logoutWithLoadingDialog(context);
      if (context.mounted) {
        if (authProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Logout realizado com sucesso'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Navigate back to home after successful logout
          context.go('/');
        }
      }
    }
  }

  /// Constrói item de informação sobre logout
  Widget _buildLogoutItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog stateful para confirmação de exclusão de conta
class _AccountDeletionDialog extends StatefulWidget {
  @override
  State<_AccountDeletionDialog> createState() => __AccountDeletionDialogState();
}

class __AccountDeletionDialogState extends State<_AccountDeletionDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isConfirmationValid = false;
  
  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_validateConfirmation);
  }
  
  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }
  
  void _validateConfirmation() {
    setState(() {
      _isConfirmationValid = _confirmationController.text.trim().toUpperCase() == 'CONCORDO';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning,
            color: Theme.of(context).colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Excluir Conta',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
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
            'Esta ação é irreversível e resultará em:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildDeletionItem(context, Icons.delete_forever, 'Exclusão permanente de todos os seus dados'),
          _buildDeletionItem(context, Icons.history, 'Perda do histórico de atividades'),
          _buildDeletionItem(context, Icons.cloud_off, 'Impossibilidade de recuperar informações'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Para cancelar assinaturas, acesse a loja onde a comprou (App Store ou Google Play)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Para confirmar, digite CONCORDO abaixo:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmationController,
            decoration: InputDecoration(
              hintText: 'Digite CONCORDO para confirmar',
              border: OutlineInputBorder(
                borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              _UpperCaseTextFormatter(),
            ],
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isConfirmationValid ? () {
            Navigator.of(context).pop();
            context.go('/account-deletion');
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isConfirmationValid 
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
            foregroundColor: _isConfirmationValid 
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
            shape: RoundedRectangleBorder(
              borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
            ),
          ),
          child: const Text('Excluir Conta'),
        ),
      ],
    );
  }

  /// Constrói item de informação sobre exclusão
  Widget _buildDeletionItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Formatter que converte automaticamente o texto para uppercase
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
    );
  }
}