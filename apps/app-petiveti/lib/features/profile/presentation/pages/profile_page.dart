import 'package:core/core.dart' hide User, AuthState, AuthStatus, Column;
import 'package:flutter/material.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/account_actions_section.dart';
import '../widgets/account_info_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_subscription_section.dart';
import '../widgets/profile_state_handlers.dart';

/// Profile page widget for displaying user information and settings
///
/// Padronizado com app-plantis para consistência visual
/// 
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles UI rendering
/// - **Dependency Inversion**: Depends on ProfileActionsService abstraction
/// - **Open/Closed**: Business logic extracted to service
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAnonymous = authState.status != AuthStatus.authenticated;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header com gradiente
            ProfileHeader(isAnonymous: isAnonymous),
            
            // Conteúdo scrollável
            Expanded(
              child: _buildBody(context, authState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AuthState authState) {
    if (authState.status == AuthStatus.loading) {
      return ProfileStateHandlers.buildLoadingState(context);
    }
    if (authState.status == AuthStatus.error && authState.error != null) {
      return ProfileStateHandlers.buildErrorState(
        context: context,
        error: authState.error,
        onRetry: () => ref.invalidate(authProvider),
      );
    }
    if (authState.status == AuthStatus.unauthenticated ||
        authState.user == null) {
      return ProfileStateHandlers.buildUnauthenticatedState(
        context: context,
        onSignIn: () => context.push('/login'),
      );
    }

    final isAnonymous = authState.status != AuthStatus.authenticated;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seção de informações da conta
          const AccountInfoSection(),

          const SizedBox(height: 24),

          // Seção de assinatura (apenas para usuários logados)
          if (!isAnonymous) ...[
            const ProfileSubscriptionSection(),
            const SizedBox(height: 24),
          ],

          // Seção de ações da conta
          const AccountActionsSection(),

          const SizedBox(height: 24),

          // Versão do app
          Center(
            child: Semantics(
              label: 'Informações da versão do aplicativo',
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.hasData
                      ? 'Versão ${snapshot.data!.version}'
                      : 'Versão 1.0.0';
                  return Text(
                    version,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
