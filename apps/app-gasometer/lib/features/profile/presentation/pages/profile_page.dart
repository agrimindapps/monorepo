import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../data_export/presentation/widgets/export_data_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _displayNameController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      _displayNameController.text = user?.displayName ?? '';
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    
    final newDisplayName = _displayNameController.text.trim();
    if (newDisplayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nome não pode estar vazio'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateUserProfile(displayName: newDisplayName);
      
      if (mounted) {
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
              content: const Text('Perfil atualizado com sucesso'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() => _isEditing = false);
          HapticFeedback.lightImpact();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingPagePadding),
                          child: _buildContent(context, authProvider, user, isAnonymous),
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
              label: 'Voltar',
              hint: 'Retorna para a página anterior',
              button: true,
              onTap: () => context.pop(),
              child: IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 19,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              isAnonymous ? Icons.person_outline : Icons.person,
              color: Colors.white,
              size: 19,
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
                  isAnonymous ? 'Usuário Anônimo' : 'Conta Registrada',
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
        _buildProfileSection(context, authProvider, user, isAnonymous),
        if (!isAnonymous) ...[
          SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          _buildAccountInfoSection(context, user, authProvider),
        ],
        SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildSettingsSection(context, isAnonymous),
        if (!isAnonymous) ...[
          SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          const ExportDataSection(),
        ],
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
              // Avatar section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isAnonymous 
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAnonymous ? Icons.person_outline : Icons.person,
                  size: 48,
                  color: isAnonymous 
                      ? Colors.orange
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
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
                // Registered user profile editing
                Column(
                  children: [
                    _buildProfileField(
                      'Nome',
                      _displayNameController,
                      enabled: _isEditing,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _buildProfileField(
                      'Email',
                      TextEditingController(text: (user?.email as String?) ?? ''),
                      enabled: false,
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 24),
                    
                    // Action buttons
                    Row(
                      children: [
                        if (_isEditing) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSaving ? null : () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _isEditing = false;
                                  _displayNameController.text = (user?.displayName as String?) ?? '';
                                });
                              },
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _saveProfile,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save, size: 16),
                              label: Text(_isSaving ? 'Salvando...' : 'Salvar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(() => _isEditing = true);
                              },
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Editar Perfil'),
                            ),
                          ),
                        ],
                      ],
                    ),
                    
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
              _buildInfoRow('ID da Conta', (user?.id as String?) ?? 'N/A'),
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
              if (!isAnonymous)
                _buildSettingsItem(
                  context,
                  icon: Icons.star,
                  title: 'Premium',
                  subtitle: 'Gerenciar assinatura Premium',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go('/premium');
                  },
                  isLast: true,
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
                    context.go('/account-deletion');
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

  Widget _buildProfileField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: enabled
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Auth handling methods
  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Deseja realmente sair da sua conta?'),
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
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await authProvider.logout();
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
}