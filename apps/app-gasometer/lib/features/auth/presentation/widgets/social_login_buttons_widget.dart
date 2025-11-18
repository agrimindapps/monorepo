import 'package:flutter/material.dart';

/// Widget para botões de login social
/// Segue o princípio da Responsabilidade Única
///
/// ⚠️ TEMPORARIAMENTE DESABILITADO
/// Login social requer configuração do Google Client ID no Firebase Console
/// Para reabilitar, siga as instruções em GOOGLE_SIGNIN_WEB_SETUP.md
class SocialLoginButtonsWidget extends StatefulWidget {
  const SocialLoginButtonsWidget({super.key, this.onLoginSuccess});

  final VoidCallback? onLoginSuccess;

  @override
  State<SocialLoginButtonsWidget> createState() =>
      _SocialLoginButtonsWidgetState();
}

class _SocialLoginButtonsWidgetState extends State<SocialLoginButtonsWidget> {
  @override
  Widget build(BuildContext context) {
    // 🚫 Login social temporariamente desabilitado
    // Retorna widget vazio para evitar erros de configuração
    return const SizedBox.shrink();
  }
}
