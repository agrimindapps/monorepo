import 'package:injectable/injectable.dart';

import '../../../../core/theme/gasometer_colors.dart';
import '../../presentation/widgets/base_legal_page.dart';

/// Service responsible for providing Account Deletion Policy content
/// Follows SRP by handling only account deletion policy content
@lazySingleton
class AccountDeletionPolicyContentProvider {
  static const String _lastUpdatedDate = '2025-11-05';

  /// Get the last updated date for account deletion policy
  String get lastUpdatedDate => _lastUpdatedDate;

  /// Get all sections for the account deletion policy
  List<LegalSection> getSections() {
    return [
      _buildIntroductionSection(),
      _buildDeletionProcessSection(),
      _buildDataRemovedSection(),
      _buildDataRetentionSection(),
      _buildTimeframeSection(),
      _buildIrreversibilitySection(),
      _buildContactSection(),
    ];
  }

  LegalSection _buildIntroductionSection() {
    return const LegalSection(
      title: 'Política de Exclusão de Conta',
      content:
          '''Esta política descreve como você pode solicitar a exclusão de sua conta no Gasometer e quais dados serão removidos.

Respeitamos seu direito à privacidade e à exclusão de dados conforme legislação aplicável (LGPD, GDPR).''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildDeletionProcessSection() {
    return const LegalSection(
      title: 'Como Solicitar a Exclusão',
      content: '''Para excluir sua conta, você pode:

**1. Pelo Aplicativo:**
• Acesse Configurações > Conta > Excluir Conta
• Confirme a exclusão seguindo as instruções

**2. Por E-mail:**
• Envie uma solicitação para: agrimindapps@gmail.com
• Assunto: "Solicitação de Exclusão de Conta - Gasometer"
• Inclua seu e-mail cadastrado no app''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildDataRemovedSection() {
    return const LegalSection(
      title: 'Dados que Serão Removidos',
      content: '''Após a confirmação da exclusão, os seguintes dados serão permanentemente removidos:

• Informações da conta (e-mail, perfil)
• Dados de veículos cadastrados
• Histórico de abastecimentos
• Registros de manutenções
• Registros de odômetro
• Despesas cadastradas
• Relatórios e estatísticas
• Configurações e preferências
• Backups na nuvem (se habilitados)''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildDataRetentionSection() {
    return const LegalSection(
      title: 'Dados Mantidos por Obrigação Legal',
      content: '''Alguns dados podem ser mantidos temporariamente por exigências legais ou contratuais:

• Logs de acesso e auditoria (90 dias)
• Informações fiscais e transações financeiras (5 anos)
• Dados necessários para defesa legal ou compliance

Estes dados são mantidos de forma segura e acessível apenas para fins legais.''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildTimeframeSection() {
    return const LegalSection(
      title: 'Prazo de Exclusão',
      content: '''**Exclusão Imediata:**
• Dados do aplicativo local removidos instantaneamente

**Exclusão Completa:**
• Dados na nuvem: até 30 dias
• Backups: até 90 dias (conforme ciclo de backup)

**Confirmação:**
• Você receberá um e-mail confirmando a conclusão do processo''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildIrreversibilitySection() {
    return const LegalSection(
      title: 'Atenção: Processo Irreversível',
      content: '''⚠️ **IMPORTANTE:**

A exclusão da conta é PERMANENTE e IRREVERSÍVEL.

Todos os seus dados serão perdidos e não poderão ser recuperados, incluindo:
• Histórico completo de abastecimentos
• Registros de manutenções
• Estatísticas e relatórios

**Recomendação:**
Antes de excluir, exporte seus dados através da funcionalidade de exportação disponível no app.''',
      titleColor: GasometerColors.error,
    );
  }

  LegalSection _buildContactSection() {
    return const LegalSection(
      title: 'Dúvidas ou Suporte',
      content: '''Para questões sobre exclusão de conta ou dados:

**E-mail:** agrimindapps@gmail.com

**Tempo de resposta:** até 5 dias úteis

Nossa equipe está disponível para esclarecer dúvidas sobre o processo de exclusão e seus direitos de privacidade.''',
      titleColor: GasometerColors.primary,
      isLast: true,
    );
  }
}
