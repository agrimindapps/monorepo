import 'package:flutter/material.dart';

/// Privacy Policy page
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              theme,
              'Última atualização',
              'Esta política foi atualizada em 19 de dezembro de 2024.',
            ),
            _buildSection(
              theme,
              '1. Informações que coletamos',
              '''Coletamos as seguintes informações quando você usa o NebulaList:

• Informações da conta: email, nome de exibição e foto de perfil (opcional)
• Dados de uso: listas, itens e preferências que você cria no app
• Informações técnicas: tipo de dispositivo, sistema operacional e identificadores únicos para análise
• Dados de sincronização: informações necessárias para sincronizar seus dados entre dispositivos''',
            ),
            _buildSection(
              theme,
              '2. Como usamos suas informações',
              '''Utilizamos suas informações para:

• Fornecer, manter e melhorar nossos serviços
• Sincronizar seus dados entre dispositivos
• Enviar notificações e lembretes configurados por você
• Personalizar sua experiência no app
• Detectar, prevenir e resolver problemas técnicos
• Cumprir obrigações legais''',
            ),
            _buildSection(
              theme,
              '3. Compartilhamento de dados',
              '''Não vendemos suas informações pessoais. Podemos compartilhar dados com:

• Provedores de serviço (Firebase, hospedagem de dados)
• Quando exigido por lei ou processo legal
• Para proteger direitos, privacidade, segurança ou propriedade''',
            ),
            _buildSection(
              theme,
              '4. Segurança dos dados',
              '''Implementamos medidas de segurança para proteger suas informações:

• Criptografia de dados em trânsito e em repouso
• Autenticação segura via Firebase Auth
• Controle de acesso rigoroso aos dados
• Monitoramento contínuo de segurança''',
            ),
            _buildSection(
              theme,
              '5. Seus direitos',
              '''Você tem direito a:

• Acessar seus dados pessoais
• Corrigir dados incorretos
• Solicitar exclusão de sua conta e dados
• Exportar seus dados
• Revogar consentimento a qualquer momento''',
            ),
            _buildSection(
              theme,
              '6. Retenção de dados',
              '''Mantemos seus dados enquanto sua conta estiver ativa. Após exclusão da conta:

• Dados pessoais são removidos em até 30 dias
• Backups são removidos em até 90 dias
• Dados anonimizados podem ser mantidos para análise''',
            ),
            _buildSection(
              theme,
              '7. Contato',
              '''Para questões sobre privacidade, entre em contato:

Email: suporte@nebulalist.app
Responderemos em até 72 horas úteis.''',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
