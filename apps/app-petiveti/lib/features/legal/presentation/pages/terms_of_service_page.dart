import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Terms of Service page for PetiVeti
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos de Uso'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Aceitação dos Termos',
              'Ao acessar e usar o PetiVeti, você aceita e concorda em cumprir estes Termos de Uso. Se você não concordar com qualquer parte destes termos, não deve usar o aplicativo.',
            ),
            _buildSection(
              context,
              'Descrição do Serviço',
              'O PetiVeti é um aplicativo para gerenciamento de cuidados veterinários, permitindo:\n• Registro e acompanhamento de pets\n• Agendamento de consultas e vacinas\n• Controle de medicamentos\n• Calculadoras veterinárias\n• Lembretes e notificações',
            ),
            _buildSection(
              context,
              'Conta de Usuário',
              'Para usar alguns recursos, você deve criar uma conta fornecendo informações precisas e atualizadas. Você é responsável por manter a confidencialidade de sua senha e por todas as atividades em sua conta.',
            ),
            _buildSection(
              context,
              'Uso Aceitável',
              'Você concorda em usar o PetiVeti apenas para fins legais e de acordo com estes termos. É proibido:\n• Violar leis ou regulamentos\n• Interferir no funcionamento do serviço\n• Tentar acessar contas de outros usuários\n• Usar o serviço para spam ou fraude\n• Copiar ou reproduzir conteúdo sem autorização',
            ),
            _buildSection(
              context,
              'Conteúdo do Usuário',
              'Você mantém todos os direitos sobre o conteúdo que envia ao PetiVeti. Ao enviar conteúdo, você nos concede uma licença para usar, armazenar e processar esse conteúdo para fornecer e melhorar nossos serviços.',
            ),
            _buildSection(
              context,
              'Assinaturas e Pagamentos',
              'Alguns recursos podem exigir assinatura paga. Os termos de pagamento, preços e política de reembolso serão claramente apresentados antes da compra. Assinaturas são renovadas automaticamente, a menos que canceladas.',
            ),
            _buildSection(
              context,
              'Isenção de Responsabilidade Médica',
              'O PetiVeti é uma ferramenta de gerenciamento e não substitui consulta veterinária profissional. As calculadoras e informações são apenas orientativas. Sempre consulte um veterinário qualificado para diagnósticos e tratamentos.',
            ),
            _buildSection(
              context,
              'Propriedade Intelectual',
              'Todo o conteúdo do PetiVeti, incluindo design, código, logotipos e textos, é propriedade da empresa ou de seus licenciadores e está protegido por leis de propriedade intelectual.',
            ),
            _buildSection(
              context,
              'Limitação de Responsabilidade',
              'O PetiVeti é fornecido "como está". Não garantimos que o serviço será ininterrupto ou livre de erros. Não nos responsabilizamos por danos indiretos, incidentais ou consequentes.',
            ),
            _buildSection(
              context,
              'Modificações do Serviço',
              'Reservamo-nos o direito de modificar, suspender ou descontinuar o serviço a qualquer momento, com ou sem aviso prévio.',
            ),
            _buildSection(
              context,
              'Rescisão',
              'Você pode encerrar sua conta a qualquer momento. Podemos suspender ou encerrar sua conta se você violar estes termos.',
            ),
            _buildSection(
              context,
              'Lei Aplicável',
              'Estes termos são regidos pelas leis do Brasil. Quaisquer disputas serão resolvidas nos tribunais competentes.',
            ),
            _buildSection(
              context,
              'Alterações nos Termos',
              'Podemos atualizar estes termos periodicamente. Mudanças significativas serão notificadas através do aplicativo. O uso continuado após alterações constitui aceitação dos novos termos.',
            ),
            _buildSection(
              context,
              'Contato',
              'Para questões sobre estes termos:\nEmail: suporte@petiveti.com\nTelefone: (11) 99999-9999',
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.description, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            'Termos de Uso',
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ao usar o PetiVeti, você confirma que leu, compreendeu e aceita estes Termos de Uso.',
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
