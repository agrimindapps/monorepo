import 'package:flutter/material.dart';

/// Terms of Service page
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos de Uso'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              theme,
              'Última atualização',
              'Estes termos foram atualizados em 19 de dezembro de 2024.',
            ),
            _buildSection(
              theme,
              '1. Aceitação dos Termos',
              '''Ao usar o NebulaList, você concorda com estes Termos de Uso. Se não concordar com qualquer parte, não use o aplicativo.

Podemos atualizar estes termos periodicamente. Seu uso continuado após alterações constitui aceitação dos novos termos.''',
            ),
            _buildSection(
              theme,
              '2. Descrição do Serviço',
              '''O NebulaList é um aplicativo de gerenciamento de listas e tarefas que oferece:

• Criação e organização de listas
• Sincronização entre dispositivos
• Lembretes e notificações
• Recursos premium (mediante assinatura)

Reservamo-nos o direito de modificar, suspender ou descontinuar recursos a qualquer momento.''',
            ),
            _buildSection(
              theme,
              '3. Conta do Usuário',
              '''Para usar o NebulaList, você deve:

• Ter pelo menos 13 anos de idade
• Fornecer informações precisas no cadastro
• Manter suas credenciais seguras
• Notificar-nos sobre uso não autorizado

Você é responsável por todas as atividades em sua conta.''',
            ),
            _buildSection(
              theme,
              '4. Uso Aceitável',
              '''Ao usar o NebulaList, você concorda em não:

• Violar leis ou regulamentos aplicáveis
• Infringir direitos de terceiros
• Usar o serviço para spam ou conteúdo malicioso
• Tentar acessar sistemas sem autorização
• Interferir no funcionamento do serviço
• Revender ou redistribuir o serviço''',
            ),
            _buildSection(
              theme,
              '5. Propriedade Intelectual',
              '''Todo o conteúdo do NebulaList (código, design, marcas) é protegido por direitos autorais e leis de propriedade intelectual.

Você mantém a propriedade dos dados que cria no aplicativo. Ao usar o serviço, você nos concede licença limitada para armazenar e processar seus dados conforme necessário para fornecer o serviço.''',
            ),
            _buildSection(
              theme,
              '6. Assinaturas Premium',
              '''Os recursos premium requerem assinatura paga:

• Preços são exibidos antes da compra
• Assinaturas renovam automaticamente
• Cancelamento pode ser feito a qualquer momento
• Reembolsos seguem políticas das lojas de apps
• Recursos premium podem ser alterados com aviso prévio''',
            ),
            _buildSection(
              theme,
              '7. Limitação de Responsabilidade',
              '''O NebulaList é fornecido "como está". Na extensão permitida por lei:

• Não garantimos disponibilidade ininterrupta
• Não somos responsáveis por perda de dados
• Nossa responsabilidade é limitada ao valor pago nos últimos 12 meses

Recomendamos manter backups de dados importantes.''',
            ),
            _buildSection(
              theme,
              '8. Rescisão',
              '''Podemos suspender ou encerrar sua conta se:

• Você violar estes termos
• Uso fraudulento for detectado
• For exigido por lei

Você pode encerrar sua conta a qualquer momento nas configurações do aplicativo.''',
            ),
            _buildSection(
              theme,
              '9. Contato',
              '''Para questões sobre estes termos:

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
