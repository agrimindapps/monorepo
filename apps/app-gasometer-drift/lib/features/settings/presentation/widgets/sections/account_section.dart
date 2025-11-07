import 'package:core/core.dart' show GoRouterHelper;
import 'package:flutter/material.dart';

import '../shared/settings_card.dart';
import '../shared/settings_item.dart';

/// Seção de conta - permite acesso ao perfil e logout
///
/// Nota: Item de perfil é ocultado em telas maiores que 768px (tablet/desktop)
/// pois o perfil é acessível via menu lateral em dispositivos maiores.
class AccountSection extends StatelessWidget {
  const AccountSection({
    this.onProfileTap,
    this.onLogoutTap,
    super.key,
  });

  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768; // < 768px (tablet breakpoint)

    return SettingsCard(
      title: 'Conta',
      icon: Icons.person,
      children: [
        // Perfil - Ocultado em tablets/desktop (> 768px)
        // Justificativa: Em telas maiores, usuário acessa perfil pelo menu lateral
        if (isMobile)
          SettingsItem(
            icon: Icons.account_circle,
            title: 'Perfil',
            subtitle: 'Gerenciar informações da conta',
            onTap: onProfileTap ?? () => context.push('/profile'),
          ),

        // Sair - Sempre visível
        SettingsItem(
          icon: Icons.logout,
          title: 'Sair',
          subtitle: 'Fazer logout da conta',
          onTap: onLogoutTap,
        ),
      ],
    );
  }
}
