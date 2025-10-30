import 'package:flutter/material.dart';

/// Manager for auth-related dialogs
/// Centralizes all dialog construction and management for auth pages
class AuthDialogManager {
  /// Shows dialog about social login being in development
  Future<void> showSocialLoginDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Em Desenvolvimento'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction, size: 48, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'O login social está em desenvolvimento e estará disponível em breve!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Shows dialog explaining anonymous login
  /// Returns true if user confirms, false if cancels
  Future<bool?> showAnonymousLoginDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Anônimo'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Como funciona o login anônimo:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Você pode usar o app sem criar conta'),
            Text('• Seus dados ficam apenas no dispositivo'),
            Text(
              '• Limitação: dados podem ser perdidos se o app for desinstalado',
            ),
            Text('• Sem backup na nuvem'),
            Text('• Sem sincronização entre dispositivos'),
            SizedBox(height: 16),
            Text(
              'Deseja prosseguir?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Prosseguir'),
          ),
        ],
      ),
    );
  }

  /// Shows Terms of Service dialog
  Future<void> showTermsOfService(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Termos de Serviço'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Última atualização: Janeiro 2025\n\n'
                '1. ACEITAÇÃO DOS TERMOS\n'
                'Ao usar o Inside Garden, você concorda com estes termos.\n\n'
                '2. DESCRIÇÃO DO SERVIÇO\n'
                'O Inside Garden é um aplicativo para cuidado e gerenciamento de plantas.\n\n'
                '3. RESPONSABILIDADES DO USUÁRIO\n'
                '• Fornecer informações precisas\n'
                '• Usar o serviço de forma apropriada\n'
                '• Manter a segurança da sua conta\n\n'
                '4. PRIVACIDADE\n'
                'Seus dados são protegidos conforme nossa Política de Privacidade.\n\n'
                '5. MODIFICAÇÕES\n'
                'Podemos atualizar estes termos. Você será notificado sobre mudanças importantes.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Shows Privacy Policy dialog
  Future<void> showPrivacyPolicy(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Política de Privacidade'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Última atualização: Janeiro 2025\n\n'
                '1. INFORMAÇÕES QUE COLETAMOS\n'
                '• Dados de conta (email, nome)\n'
                '• Informações sobre suas plantas\n'
                '• Dados de uso do aplicativo\n\n'
                '2. COMO USAMOS SUAS INFORMAÇÕES\n'
                '• Para fornecer e melhorar nossos serviços\n'
                '• Para personalizar sua experiência\n'
                '• Para enviar notificações de cuidados\n\n'
                '3. COMPARTILHAMENTO DE DADOS\n'
                'Não vendemos ou compartilhamos seus dados pessoais com terceiros.\n\n'
                '4. SEGURANÇA\n'
                'Utilizamos medidas de segurança para proteger suas informações.\n\n'
                '5. SEUS DIREITOS\n'
                'Você pode acessar, corrigir ou excluir seus dados a qualquer momento.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
