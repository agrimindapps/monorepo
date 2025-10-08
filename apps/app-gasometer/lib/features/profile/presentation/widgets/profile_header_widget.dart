import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

/// Widget responsável por exibir o header da página de perfil
class ProfileHeader extends StatelessWidget {
  final bool isAnonymous;

  const ProfileHeader({super.key, required this.isAnonymous});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: GasometerDesignTokens.colorHeaderBackground,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: GasometerDesignTokens.colorHeaderBackground.withValues(
                alpha: 0.2,
              ),
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
                  const Text(
                    'Perfil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isAnonymous
                        ? 'Usuário Anônimo'
                        : 'Gerencie suas informações pessoais',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
