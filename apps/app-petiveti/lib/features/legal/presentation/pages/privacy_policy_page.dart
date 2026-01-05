import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Privacy Policy page for PetiVeti
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Coleta de Informações',
              'O PetiVeti coleta informações fornecidas diretamente por você, como nome, email e dados sobre seus pets. Também coletamos dados de uso do aplicativo para melhorar nossos serviços.',
            ),
            _buildSection(
              context,
              'Uso de Dados',
              'Utilizamos suas informações para:\n• Fornecer e melhorar nossos serviços\n• Personalizar sua experiência\n• Enviar lembretes e notificações\n• Comunicar atualizações importantes\n• Analisar o uso do aplicativo',
            ),
            _buildSection(
              context,
              'Proteção de Dados',
              'Implementamos medidas de segurança técnicas e organizacionais para proteger suas informações contra acesso não autorizado, alteração, divulgação ou destruição.',
            ),
            _buildSection(
              context,
              'Compartilhamento de Dados',
              'Não vendemos, alugamos ou compartilhamos suas informações pessoais com terceiros para fins de marketing. Dados podem ser compartilhados apenas quando necessário para fornecer nossos serviços ou quando exigido por lei.',
            ),
            _buildSection(
              context,
              'Armazenamento de Dados',
              'Seus dados são armazenados em servidores seguros com criptografia. Mantemos suas informações pelo tempo necessário para fornecer nossos serviços ou conforme exigido por lei.',
            ),
            _buildSection(
              context,
              'Seus Direitos',
              'Você tem direito a:\n• Acessar seus dados pessoais\n• Corrigir informações incorretas\n• Solicitar a exclusão de sua conta\n• Exportar seus dados\n• Revogar consentimentos',
            ),
            _buildSection(
              context,
              'Cookies e Tecnologias Similares',
              'Utilizamos cookies e tecnologias similares para melhorar sua experiência, analisar o uso do aplicativo e personalizar conteúdo.',
            ),
            _buildSection(
              context,
              'Alterações nesta Política',
              'Podemos atualizar esta política periodicamente. Notificaremos sobre mudanças significativas através do aplicativo ou por email.',
            ),
            _buildSection(
              context,
              'Contato',
              'Para questões sobre privacidade, entre em contato:\nEmail: privacidade@petiveti.com\nTelefone: (11) 99999-9999',
            ),
            const SizedBox(height: 16),
            _buildFooter(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.privacy_tip, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            'Política de Privacidade',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Última atualização: 12 de dezembro de 2025',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user, color: AppColors.primary, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sua privacidade é nossa prioridade. Estamos comprometidos em proteger suas informações com os mais altos padrões de segurança.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
