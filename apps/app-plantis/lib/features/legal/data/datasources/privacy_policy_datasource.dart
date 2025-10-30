import '../../domain/entities/document_type.dart';
import '../models/legal_document_model.dart';
import '../models/legal_section_model.dart';

/// Data source for Privacy Policy content
class PrivacyPolicyDataSource {
  /// Last update date for the privacy policy document
  static const String _lastUpdatedDate = '2024-12-15';

  /// Privacy Policy raw content
  static const Map<String, dynamic> _privacyPolicyContent = {
    'lastUpdated': _lastUpdatedDate,
    'sections': [
      {
        'title': 'Nossa Política de Privacidade',
        'content':
            '''O Plantis está comprometido em proteger e respeitar sua privacidade. Esta política explica como coletamos, usamos, armazenamos e protegemos suas informações pessoais.

Ao usar nosso aplicativo, você concorda com a coleta e uso de informações de acordo com esta política.''',
      },
      {
        'title': 'Informações que Coletamos',
        'content': '''**Informações fornecidas diretamente por você:**
• Dados de registro (nome, email, senha)
• Informações sobre suas plantas (nome, espécie, fotos, notas)
• Configurações de lembretes e cuidados
• Comentários e feedback enviados

**Informações coletadas automaticamente:**
• Dados de uso do aplicativo (funcionalidades utilizadas, tempo de uso)
• Informações técnicas (versão do app, modelo do dispositivo, sistema operacional)
• Dados de desempenho e crashes (para melhorar o app)
• Localização aproximada (apenas se autorizada, para recursos climáticos)''',
      },
      {
        'title': 'Como Usamos suas Informações',
        'content': '''Utilizamos suas informações para:
• Fornecer e manter o serviço do aplicativo
• Personalizar sua experiência com plantas
• Enviar lembretes e notificações solicitadas
• Melhorar nossos recursos e funcionalidades
• Fornecer suporte técnico quando necessário
• Comunicar sobre atualizações importantes
• Processar assinaturas premium (quando aplicável)

**Nunca usamos seus dados para:**
• Vender para terceiros
• Publicidade externa não autorizada
• Fins não relacionados ao aplicativo''',
      },
      {
        'title': 'Armazenamento de Dados',
        'content': '''**Armazenamento Local:**
• Por padrão, todos os dados são armazenados localmente no seu dispositivo
• Você tem controle total sobre essas informações
• Dados locais incluem: plantas, fotos, notas, lembretes

**Sincronização na Nuvem (Premium):**
• Opcional e requer sua autorização explícita
• Dados criptografados com padrões de segurança avançados
• Sincronização entre seus dispositivos autorizados
• Backup automático para recuperação de dados''',
      },
      {
        'title': 'Compartilhamento de Dados',
        'content': '''**Não compartilhamos seus dados pessoais, exceto:**

**Provedores de Serviço:**
• Serviços de armazenamento em nuvem (criptografados)
• Processamento de pagamentos (dados mínimos necessários)
• Analytics (dados anonimizados para melhorar o app)

**Requisitos Legais:**
• Quando obrigatório por lei ou ordem judicial
• Para proteger nossos direitos e segurança dos usuários
• Em casos de investigação de atividades fraudulentas

**Todos os terceiros são rigorosamente selecionados e seguem padrões de segurança equivalentes aos nossos.**''',
      },
      {
        'title': 'Segurança dos Dados',
        'content': '''Implementamos medidas de segurança robustas:

**Segurança Técnica:**
• Criptografia de dados em trânsito e em repouso
• Protocolos de comunicação seguros (HTTPS/TLS)
• Autenticação multifator disponível
• Monitoramento contínuo de segurança

**Segurança Organizacional:**
• Acesso restrito aos dados dos usuários
• Treinamento regular da equipe sobre privacidade
• Auditorias regulares de segurança
• Políticas internas rigorosas de proteção de dados''',
      },
      {
        'title': 'Seus Direitos sobre os Dados',
        'content': '''Você tem os seguintes direitos sobre seus dados pessoais:

**Direito de Acesso:**
• Visualizar todos os dados que mantemos sobre você
• Exportar seus dados em formato legível

**Direito de Correção:**
• Corrigir informações incorretas ou desatualizadas
• Atualizar suas preferências a qualquer momento

**Direito de Exclusão:**
• Solicitar a exclusão completa de sua conta e dados
• Exclusão imediata de dados locais pelo próprio app

**Direito de Portabilidade:**
• Exportar seus dados para usar em outros serviços
• Transferir dados entre dispositivos facilmente

**Para exercer seus direitos, entre em contato através do app ou email.**''',
      },
      {
        'title': 'Cookies e Tecnologias Similares',
        'content': '''O Plantis utiliza tecnologias locais limitadas:

**Dados de Preferências:**
• Configurações do app (tema, idioma, notificações)
• Estado de funcionalidades (tutorial completado, etc.)
• Cache de imagens para melhor performance

**Analytics Limitado:**
• Dados anonimizados sobre uso do app
• Informações de crashes para correções
• Não coletamos dados pessoais identificáveis

**Você pode limpar esses dados através das configurações do app.**''',
      },
      {
        'title': 'Retenção de Dados',
        'content': '''**Dados da Conta:**
• Mantidos enquanto sua conta estiver ativa
• Excluídos 30 dias após cancelamento da conta
• Backup de segurança por até 90 dias (criptografado)

**Dados Técnicos:**
• Logs de erro: 12 meses máximo
• Analytics: dados agregados por até 24 meses
• Dados de suporte: até resolução + 12 meses

**Dados Legais:**
• Mantidos apenas quando exigido por lei
• Excluídos assim que não mais necessários''',
      },
      {
        'title': 'Transferências Internacionais',
        'content':
            '''Seus dados podem ser processados em diferentes localidades:

**Armazenamento Principal:**
• Servidores localizados no Brasil quando possível
• Provedores certificados com padrões internacionais

**Transferências Seguras:**
• Sempre com criptografia end-to-end
• Apenas para provedores com certificações adequadas
• Contratos rigorosos de proteção de dados
• Conformidade com leis locais e internacionais''',
      },
      {
        'title': 'Menores de Idade',
        'content': '''**Proteção de Crianças e Adolescentes:**
• Não coletamos intencionalmente dados de menores de 13 anos
• Para usuários entre 13-18 anos, requeremos consentimento dos pais
• Recursos especiais de proteção para contas de menores
• Exclusão imediata de dados se identificarmos uso não autorizado

**Pais e Responsáveis:**
• Podem solicitar informações sobre dados de menores
• Direito de exclusão de contas de menores
• Controle sobre funcionalidades disponíveis''',
      },
      {
        'title': 'Alterações nesta Política',
        'content': '''**Como mantemos você informado:**
• Notificação no app sobre mudanças importantes
• Email para alterações significativas (se cadastrado)
• Histórico de versões disponível no app
• Período de adaptação antes de mudanças entrarem em vigor

**Sua escolha:**
• Você pode aceitar as novas condições ou encerrar sua conta
• Sempre transparente sobre o que mudou
• Oportunidade de fazer perguntas sobre mudanças''',
      },
      {
        'title': 'Contato e Suporte',
        'content': '''**Para questões sobre privacidade:**
• Email: privacy@plantis.app
• Dentro do app: Menu > Configurações > Privacidade
• Central de ajuda: https://help.plantis.app

**Nosso compromisso:**
• Respondemos em até 48 horas úteis
• Suporte completo em português
• Assistência para exercer seus direitos
• Esclarecimento de dúvidas sem burocracia

**Autoridade de Proteção de Dados:**
• ANPD (Autoridade Nacional de Proteção de Dados)
• Direito de recorrer em caso de insatisfação
• Canais oficiais disponibilizados quando necessário''',
      },
    ],
  };

  /// Get Privacy Policy document model
  LegalDocumentModel getPrivacyPolicy() {
    final sections = (_privacyPolicyContent['sections'] as List)
        .map((e) => LegalSectionModel.fromMap(e as Map<String, dynamic>))
        .toList();

    return LegalDocumentModel(
      id: DocumentType.privacyPolicy.id,
      type: DocumentType.privacyPolicy,
      title: DocumentType.privacyPolicy.displayName,
      lastUpdated: DateTime.parse('$_lastUpdatedDate 00:00:00'),
      sections: sections,
      version: _getVersionString(sections.length),
    );
  }

  String _getVersionString(int sectionCount) {
    return '${_lastUpdatedDate}_v$sectionCount';
  }
}
