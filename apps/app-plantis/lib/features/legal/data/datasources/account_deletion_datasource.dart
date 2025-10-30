import '../../domain/entities/document_type.dart';
import '../models/legal_document_model.dart';
import '../models/legal_section_model.dart';

/// Data source for Account Deletion Policy content
class AccountDeletionDataSource {
  /// Last update date for the account deletion policy document
  static const String _lastUpdatedDate = '2024-12-15';

  /// Get Account Deletion Policy document model
  LegalDocumentModel getAccountDeletionPolicy() {
    final sections = [
      LegalSectionModel(
        title: 'Como Excluir Sua Conta',
        content: '''**Exclusão via Aplicativo:**
1. Abra o aplicativo Plantis
2. Vá em Configurações → Minha Conta → Privacidade
3. Toque em "Excluir Conta"
4. Digite sua senha atual para confirmar identidade
5. Confirme a exclusão digitando "EXCLUIR"

**Exclusão via Web:**
• Acesse nossa página de exclusão: plantis.app/delete-account
• Faça login com sua conta
• Preencha o formulário de solicitação
• Receba confirmação por email

**Prazo de Processamento:**
• Exclusões via app: Imediata
• Exclusões via web: Até 7 dias úteis

**Requisitos Obrigatórios:**
• Re-autenticação com senha atual
• Confirmação em duas etapas
• Cancelamento de assinaturas ativas''',
      ),
      const LegalSectionModel(
        title: 'Dados Que Serão Excluídos',
        content: '''**Dados Pessoais:**
• Informações de perfil (nome, email, foto)
• Preferências e configurações do app
• Dados de uso e analytics pessoais

**Conteúdo do Usuário:**
• Todas as plantas cadastradas
• Fotos e imagens enviadas
• Tarefas e lembretes criados
• Histórico de cuidados e anotações
• Configurações de notificações

**Dados de Conta:**
• Credenciais de login
• Tokens de autenticação
• Vinculações com redes sociais
• Dados de sincronização

**Dados Financeiros:**
• Histórico de assinaturas (dados transacionais preservados)
• Informações de pagamento (removidas do RevenueCat)
• Preferências de cobrança''',
      ),
      const LegalSectionModel(
        title: 'Dados Retidos por Motivos Legais',
        content: '''**Obrigações Fiscais (5 anos):**
• Registros de transações para declaração de renda
• Comprovantes de compra para auditoria fiscal
• Dados necessários para emissão de notas fiscais

**Segurança e Fraude (2 anos):**
• Logs de segurança e tentativas de acesso
• Registros de atividades suspeitas
• Endereços IP para investigação de fraudes
• Dados para prevenção de múltiplas contas

**Dados Agregados (Indefinido):**
• Estatísticas anônimas de uso do app
• Dados de performance técnica (sem identificação)
• Métricas de mercado e tendências
• Dados para pesquisa e desenvolvimento

**Base Legal:**
• LGPD (Brasil) - Art. 16, 18
• GDPR (União Europeia) - Art. 17
• Código Civil Brasileiro - Art. 189
• Legislação de defesa do consumidor''',
      ),
      const LegalSectionModel(
        title: 'Consequências da Exclusão',
        content: '''**Irreversibilidade:**
• A exclusão é PERMANENTE e IRREVERSÍVEL
• Não é possível recuperar dados após confirmação
• Novo cadastro criará conta totalmente nova
• Histórico e progresso serão perdidos

**Assinaturas e Pagamentos:**
• Assinaturas ativas serão canceladas imediatamente
• Reembolsos seguem política do Google/Apple
• Benefícios premium cessam na data da exclusão
• Faturas pendentes podem ser cobradas

**Acesso a Funcionalidades:**
• Perda imediata de acesso ao app
• Sincronização de dados interrompida
• Notificações e lembretes desativados
• Integração com outros apps removida

**Dados de Terceiros:**
• Vinculações com Google/Apple removidas
• Permissões de acesso revogadas
• Dados em serviços externos mantidos conforme suas políticas''',
      ),
      const LegalSectionModel(
        title: 'Alternativas à Exclusão',
        content: '''**Desativação Temporária:**
• Pause sua conta sem perder dados
• Mantenha plantas e histórico salvos
• Reative quando quiser voltar
• Notificações desligadas temporariamente

**Configurações de Privacidade:**
• Limite coleta de dados analytics
• Desative sincronização com nuvem
• Configure privacidade das informações
• Controle permissões individuais

**Cancelamento de Assinatura:**
• Mantenha conta com funcionalidades básicas
• Continue usando recursos gratuitos
• Histórico de plantas preservado
• Sem cobrança de mensalidades

**Suporte Personalizado:**
• Entre em contato para dúvidas específicas
• Solicite ajustes de privacidade personalizados
• Receba orientação sobre uso seguro
• Tire dúvidas sobre políticas''',
      ),
      const LegalSectionModel(
        title: 'Suporte e Contato',
        content: '''**Central de Ajuda:**
• Email: privacy@plantis.app
• WhatsApp: +55 11 99999-9999
• Horário: Segunda a Sexta, 9h às 18h

**Formulário Web:**
• Acesse: plantis.app/support
• Categoria: "Exclusão de Conta"
• Resposta em até 24 horas úteis

**Direitos do Usuário:**
• Solicitar cópia dos dados antes da exclusão
• Questionar motivos de retenção de dados
• Receber confirmação do processo de exclusão
• Reportar problemas no processo

**Legislação Aplicável:**
• Lei Geral de Proteção de Dados (LGPD)
• Código de Defesa do Consumidor
• Marco Civil da Internet
• Regulamento Geral de Proteção de Dados (GDPR)

**Em caso de problemas com o processo de exclusão, você pode:**
• Contactar nossa equipe de privacidade
• Registrar reclamação na ANPD (Autoridade Nacional)
• Buscar orientação no Procon de sua região
• Consultar advogado especializado em dados''',
      ),
    ];

    return LegalDocumentModel(
      id: DocumentType.accountDeletion.id,
      type: DocumentType.accountDeletion,
      title: DocumentType.accountDeletion.displayName,
      lastUpdated: DateTime.parse('$_lastUpdatedDate 00:00:00'),
      sections: sections,
      version: _getVersionString(sections.length),
    );
  }

  String _getVersionString(int sectionCount) {
    return '${_lastUpdatedDate}_v$sectionCount';
  }
}
