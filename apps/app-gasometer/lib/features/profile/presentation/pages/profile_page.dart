import 'package:core/core.dart'
    hide
        isAnonymousProvider,
        isPremiumProvider,
        authStateProvider;
import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../auth/presentation/notifiers/notifiers.dart';
import '../../domain/services/account_service.dart';
import '../controllers/profile_controller.dart';
import '../widgets/devices_section_widget.dart';
import '../widgets/profile_actions_section.dart';
import '../widgets/profile_combined_info_section.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_premium_section.dart';
import '../widgets/profile_sync_section.dart';

// Providers for ProfileController dependencies
final accountServiceProvider = Provider<AccountService>((ref) {
  return AccountServiceImpl();
});

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _scrollController = ScrollController();
  ProfileController? _profileController;

  ProfileController get profileController {
    return _profileController ??= ProfileController(
      ref.read(accountServiceProvider),
      ref.read(localProfileImageServiceProvider),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    final user = ref.read(currentUserProvider);
    if (user == null || (user.email?.isEmpty ?? true)) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: Text(
          'Deseja enviar um email de redefinição de senha para ${user.email}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(authProvider.notifier).sendPasswordReset(user.email!);
      
      // Check for error in state after operation
      if (mounted) {
        final authState = ref.read(authProvider);
        if (authState.errorMessage != null) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao enviar email: ${authState.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email de redefinição enviado! Verifique sua caixa de entrada.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isAnonymous = ref.watch(isAnonymousProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ProfileHeader(isAnonymous: isAnonymous),
            Expanded(
              child: Semantics(
                label: 'Página de perfil do usuário',
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: _buildContent(
                          context,
                          user,
                          isAnonymous,
                          isPremium,
                        ),
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
  }

  Widget _buildContent(
    BuildContext context,
    dynamic user,
    bool isAnonymous,
    bool isPremium,
  ) {
    return Column(
      children: [
        ProfileCombinedInfoSection(
          user: user,
          isAnonymous: isAnonymous,
          profileController: profileController,
          onLoginTap: isAnonymous
              ? () {
                  context.go('/login');
                }
              : null,
          onChangePassword: !isAnonymous
              ? _handleChangePassword
              : null,
        ),
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        const ProfilePremiumSection(),
        if (!isAnonymous) ...[
          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          const DevicesSectionWidget(),
        ],
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        const ProfileSyncSection(),
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        ProfileActionsSection(isAnonymous: isAnonymous),
      ],
    );
  }
}
