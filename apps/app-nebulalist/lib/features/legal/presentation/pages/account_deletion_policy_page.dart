import 'package:flutter/material.dart';

/// Account Deletion Policy page
class AccountDeletionPolicyPage extends StatelessWidget {
  const AccountDeletionPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exclusão de Conta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withAlpha(77)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.red, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'A exclusão de conta é permanente e não pode ser desfeita.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              theme,
              'O que acontece quando você exclui sua conta',
              '''Ao solicitar a exclusão da sua conta no NebulaList, os seguintes dados serão permanentemente removidos:

• Sua conta de usuário e perfil
• Todas as listas criadas
• Todos os itens e tarefas
• Configurações e preferências personalizadas
• Histórico de atividades
• Dados de sincronização''',
            ),
            _buildSection(
              theme,
              'Cronograma de exclusão',
              '''Após a solicitação de exclusão:

• Sua conta será desativada imediatamente
• Você não poderá mais fazer login
• Seus dados serão marcados para exclusão
• Dados principais serão removidos em até 30 dias
• Backups serão removidos em até 90 dias
• Logs de sistema podem ser mantidos por até 180 dias para fins de segurança''',
            ),
            _buildSection(
              theme,
              'Dados que podem ser retidos',
              '''Por razões legais ou de segurança, podemos reter:

• Registros de transações financeiras (se aplicável)
• Dados necessários para investigações de fraude
• Informações exigidas por lei ou processo legal
• Dados anonimizados para fins estatísticos''',
            ),
            _buildSection(
              theme,
              'Como excluir sua conta',
              '''Para excluir sua conta do NebulaList:

1. Abra o aplicativo e vá em Configurações
2. Toque em seu perfil
3. Role até "Zona de Perigo"
4. Selecione "Excluir Conta"
5. Digite "EXCLUIR" para confirmar
6. Confirme a exclusão

Alternativamente, envie um email para suporte@nebulalist.app solicitando a exclusão.''',
            ),
            _buildSection(
              theme,
              'Antes de excluir',
              '''Recomendamos que você:

• Exporte seus dados importantes (se disponível)
• Cancele assinaturas ativas na loja de apps
• Anote informações que deseja manter
• Certifique-se de que realmente deseja excluir''',
            ),
            _buildSection(
              theme,
              'Cancelamento de assinatura',
              '''A exclusão da conta NÃO cancela automaticamente assinaturas:

• Assinaturas do iOS devem ser canceladas na App Store
• Assinaturas Android devem ser canceladas na Play Store
• Cancele antes de excluir para evitar cobranças futuras''',
            ),
            _buildSection(
              theme,
              'Contato',
              '''Se tiver dúvidas sobre exclusão de conta:

Email: suporte@nebulalist.app

Responderemos solicitações de exclusão em até 72 horas úteis.''',
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
