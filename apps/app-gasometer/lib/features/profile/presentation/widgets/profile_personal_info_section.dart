import 'package:core/core.dart' show GoRouterHelper;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_tokens.dart';
import '../controllers/profile_controller.dart';
import 'authenticated_user_section.dart';
import 'avatar_section.dart';
import 'profile_section_card.dart';

/// Widget para seção de informações pessoais do perfil
class ProfilePersonalInfoSection extends ConsumerWidget {

  const ProfilePersonalInfoSection({
    super.key,
    required this.user,
    required this.isAnonymous,
    required this.isPremium,
    required this.profileController,
  });
  final dynamic user;
  final bool isAnonymous;
  final bool isPremium;
  final ProfileController profileController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileSectionCard(
      title: 'Informações Pessoais',
      icon: Icons.person,
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusDialog,
            ),
          ),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                AvatarSection(
                  user: user,
                  isAnonymous: isAnonymous,
                  profileController: profileController,
                ),
                const SizedBox(height: 20),
                if (isAnonymous)
                  _buildAnonymousPrompt(context)
                else
                  AuthenticatedUserSection(
                    user: user,
                    isPremium: isPremium,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnonymousPrompt(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.3),
            ),
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
                borderRadius: GasometerDesignTokens.borderRadius(
                  GasometerDesignTokens.radiusButton,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
