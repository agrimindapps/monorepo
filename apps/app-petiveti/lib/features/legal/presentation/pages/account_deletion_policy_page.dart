import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// Account Deletion Policy page for PetiVeti
/// Required by Google Play Store and Apple App Store
class AccountDeletionPolicyPage extends StatelessWidget {
  const AccountDeletionPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exclusão de Conta'),
        backgroundColor: Colors.red.shade700,
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
              'Como Solicitar Exclusão',
              'Você pode solicitar a exclusão de sua conta de duas formas:\n\n1. Pelo Aplicativo:\n   • Acesse Configurações > Perfil da Conta\n   • Toque em "Excluir Conta"\n   • Confirme sua decisão\n\n2. Por Email:\n   • Envie uma solicitação para: exclusao@petiveti.com\n   • Inclua o email cadastrado na conta\n   • Aguarde confirmação em até 48 horas',
            ),
            _buildSection(
              context,
              'Dados que Serão Excluídos',
              'Após a exclusão da conta, os seguintes dados serão permanentemente removidos:\n\n• Informações de perfil (nome, email, foto)\n• Dados de pets cadastrados\n• Histórico de consultas e medicamentos\n• Registros de peso e vacinas\n• Lembretes e notificações\n• Configurações personalizadas\n• Dados de assinatura',
            ),
            _buildSection(
              context,
              'Dados que Podem Ser Retidos',
              'Por obrigações legais ou de segurança, alguns dados podem ser mantidos temporariamente:\n\n• Logs de acesso (até 90 dias)\n• Informações de transações (até 5 anos, conforme lei)\n• Dados anonimizados para análises estatísticas\n• Correspondências de suporte (até 1 ano)',
            ),
            _buildSection(
              context,
              'Prazo de Conclusão',
              'O processo de exclusão será concluído em:\n\n• Dados do aplicativo: imediatamente após confirmação\n• Dados de backup: até 30 dias\n• Caches e logs: até 90 dias\n\nVocê receberá confirmação por email quando a exclusão for concluída.',
            ),
            _buildSection(
              context,
              'Consequências da Exclusão',
              '⚠️ ATENÇÃO: Este processo é IRREVERSÍVEL!\n\n• Você perderá acesso à sua conta permanentemente\n• Todos os dados de seus pets serão apagados\n• Históricos médicos não poderão ser recuperados\n• Assinaturas ativas serão canceladas (sem reembolso)\n• Você não poderá criar nova conta com o mesmo email por 30 dias',
            ),
            _buildSection(
              context,
              'Alternativas à Exclusão',
              'Considere estas opções antes de excluir sua conta:\n\n• Desativar temporariamente: mantenha seus dados mas desative notificações\n• Exportar dados: baixe todas as informações antes de excluir\n• Trocar de email: altere o email da conta se desejar\n• Limpar dados: apague apenas pets e históricos, mantendo a conta',
            ),
            _buildSection(
              context,
              'Exportação de Dados (LGPD)',
              'Antes de excluir, você tem o direito de exportar seus dados:\n\n1. Acesse Configurações > Dados e Sincronização\n2. Toque em "Exportar Meus Dados"\n3. Receba um arquivo JSON com todas as informações\n4. Guarde o arquivo para seus registros',
            ),
            _buildSection(
              context,
              'Cancelamento de Assinaturas',
              'Se você possui assinatura ativa:\n\n• Assinaturas serão canceladas imediatamente\n• Não haverá reembolso proporcional\n• Benefícios Premium cessam instantaneamente\n• Faturas futuras serão canceladas\n\nRecomendamos cancelar a assinatura antes de excluir a conta.',
            ),
            _buildSection(
              context,
              'Suporte e Dúvidas',
              'Precisa de ajuda ou tem dúvidas?\n\nEmail: exclusao@petiveti.com\nSuporte: suporte@petiveti.com\nTelefone: (11) 99999-9999\n\nHorário: Segunda a Sexta, 9h às 18h',
            ),
            const SizedBox(height: 16),
            _buildWarningBox(context),
            const SizedBox(height: 24),
            _buildActionButtons(context),
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
          colors: [Colors.red.shade700, Colors.red.shade900],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.delete_forever, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            'Política de Exclusão de Conta',
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
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildWarningBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade700, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber, color: Colors.red.shade700, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Processo Irreversível',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Uma vez confirmada, a exclusão não pode ser desfeita. Todos os dados serão permanentemente removidos e não poderão ser recuperados.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.red.shade900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/account-profile'),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Excluir Minha Conta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Voltar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
