import '../../../core/constants/app_config.dart';
import '../../../core/theme/plantis_colors.dart';
import '../presentation/widgets/base_legal_page.dart';

/// Service for managing legal content in structured data format
/// Makes legal content easily updatable without code changes
class LegalContentService {
  /// Last update date for legal content
  static const String _lastUpdatedDate = '2024-12-15';

  /// Privacy Policy content structured data
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

  /// Terms of Service content structured data
  static const Map<String, dynamic> _termsOfServiceContent = {
    'lastUpdated': _lastUpdatedDate,
    'sections': [
      {
        'title': 'Introdução',
        'content':
            '''Bem-vindo ao Plantis! Estes Termos de Uso governam seu relacionamento com o aplicativo Plantis, operado pela nossa equipe.

Ao acessar ou usar nosso serviço, você concorda em estar vinculado por estes termos. Se você discordar de qualquer parte destes termos, não deverá usar nosso aplicativo.''',
      },
      {
        'title': 'Definições',
        'content':
            '''• **Aplicativo**: refere-se ao Plantis, aplicativo de gerenciamento de plantas
• **Serviço**: refere-se ao aplicativo e todos os recursos relacionados
• **Usuário**: refere-se a qualquer indivíduo que acessa ou usa o aplicativo
• **Conteúdo**: inclui todas as informações sobre plantas, fotos, notas e dados inseridos''',
      },
      {
        'title': 'Aceitação dos Termos',
        'content': '''Ao utilizar o Plantis, você declara que:
• Tem pelo menos 13 anos de idade
• Possui capacidade legal para aceitar estes termos
• Utilizará o aplicativo de acordo com as leis aplicáveis
• Fornecerá informações verdadeiras e precisas''',
      },
      {
        'title': 'Uso do Aplicativo',
        'content': '''O Plantis permite que você:
• Cadastre e gerencie informações sobre suas plantas
• Configure lembretes para cuidados com plantas
• Armazene fotos e notas sobre suas plantas
• Sincronize dados entre dispositivos (recursos premium)

Você se compromete a usar o aplicativo apenas para fins pessoais e não comerciais.''',
      },
      {
        'title': 'Conta do Usuário',
        'content':
            '''Para acessar certas funcionalidades, você pode precisar criar uma conta. Você é responsável por:
• Manter a confidencialidade de suas credenciais
• Todas as atividades que ocorrem em sua conta
• Notificar-nos imediatamente sobre uso não autorizado
• Manter suas informações de contato atualizadas''',
      },
      {
        'title': 'Privacidade e Dados',
        'content':
            '''Respeitamos sua privacidade e estamos comprometidos em proteger seus dados pessoais:
• Coletamos apenas dados necessários para fornecer o serviço
• Suas informações de plantas são armazenadas localmente por padrão
• Dados sincronizados na nuvem são criptografados
• Nunca vendemos ou compartilhamos seus dados pessoais

Para mais detalhes, consulte nossa Política de Privacidade.''',
      },
      {
        'title': 'Recursos Premium',
        'content': '''O Plantis oferece recursos premium mediante assinatura:
• Sincronização automática na nuvem
• Backup ilimitado de dados
• Relatórios avançados de cuidados
• Lembretes personalizados avançados

As assinaturas são cobradas conforme o plano escolhido e podem ser canceladas a qualquer momento.''',
      },
      {
        'title': 'Responsabilidades',
        'content': '''**Suas responsabilidades:**
• Usar o aplicativo de forma legal e ética
• Não interferir no funcionamento do serviço
• Não tentar acessar dados de outros usuários
• Respeitar direitos de propriedade intelectual

**Nossas responsabilidades:**
• Fornecer o serviço conforme descrito
• Proteger seus dados pessoais
• Manter a disponibilidade do serviço
• Oferecer suporte técnico adequado''',
      },
      {
        'title': 'Limitações de Responsabilidade',
        'content': '''O Plantis é fornecido "como está". Não garantimos:
• Disponibilidade ininterrupta do serviço
• Ausência de erros ou falhas
• Compatibilidade com todos os dispositivos
• Resultados específicos no cuidado com plantas

Nossa responsabilidade é limitada ao valor pago pelos serviços premium, se aplicável.''',
      },
      {
        'title': 'Propriedade Intelectual',
        'content':
            '''• O aplicativo e seu conteúdo são protegidos por direitos autorais
• Você mantém a propriedade dos dados que insere no aplicativo
• Concede-nos licença para processar seus dados conforme necessário para fornecer o serviço
• Não é permitido reproduzir, distribuir ou criar obras derivadas sem autorização''',
      },
      {
        'title': 'Cancelamento',
        'content':
            '''Você pode cancelar sua conta a qualquer momento. Nós podemos cancelar contas que:
• Violem estes termos de uso
• Sejam usadas para atividades ilegais
• Permaneçam inativas por período prolongado
• Representem risco de segurança

Após o cancelamento, seus dados podem ser mantidos conforme nossa política de retenção.''',
      },
      {
        'title': 'Modificações dos Termos',
        'content':
            '''Reservamo-nos o direito de modificar estes termos a qualquer momento. Mudanças significativas serão comunicadas através do aplicativo ou por email.

O uso continuado do aplicativo após as modificações constitui aceitação dos novos termos.''',
      },
      {
        'title': 'Lei Aplicável',
        'content':
            '''Estes termos são governados pelas leis brasileiras. Disputas serão resolvidas nos tribunais competentes do Brasil.

Para questões relacionadas a direitos do consumidor, aplicam-se as disposições do Código de Defesa do Consumidor.''',
      },
      {
        'title': 'Contato',
        'content': '''Para dúvidas sobre estes Termos de Uso:
• Email: privacy@plantis.app
• Central de ajuda: https://help.plantis.app
• Dentro do aplicativo: Menu > Ajuda > Contato

Responderemos suas questões em até 48 horas úteis.''',
      },
    ],
  };

  /// Get Privacy Policy sections from structured data
  static List<LegalSection> getPrivacyPolicySections() {
    final data = _privacyPolicyContent['sections'] as List;
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final section = entry.value as Map<String, dynamic>;
      return LegalSection(
        title: section['title'] as String,
        content: section['content'] as String,
        titleColor: PlantisColors.secondary,
        isLast: index == data.length - 1,
      );
    }).toList();
  }

  /// Get Terms of Service sections from structured data
  static List<LegalSection> getTermsOfServiceSections() {
    final data = _termsOfServiceContent['sections'] as List;
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final section = entry.value as Map<String, dynamic>;
      return LegalSection(
        title: section['title'] as String,
        content: section['content'] as String,
        titleColor: PlantisColors.primary,
        isLast: index == data.length - 1,
      );
    }).toList();
  }

  /// Get the last updated date for legal content
  static String getLastUpdatedDate() {
    return _lastUpdatedDate;
  }

  /// Get formatted last updated date in Portuguese
  static String getFormattedLastUpdatedDate() {
    final date = DateTime.parse('$_lastUpdatedDate 00:00:00');
    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  /// Check if content has been updated recently
  static bool hasRecentUpdates() {
    final lastUpdate = DateTime.parse('$_lastUpdatedDate 00:00:00');
    final now = DateTime.now();
    final difference = now.difference(lastUpdate).inDays;
    return difference <= 30; // Consider recent if updated within 30 days
  }

  /// Get content version for tracking changes
  static String getContentVersion() {
    final privacySections = _privacyPolicyContent['sections'] as List;
    final termsSections = _termsOfServiceContent['sections'] as List;
    final totalSections = privacySections.length + termsSections.length;

    // Simple version based on date and content count
    return '${_lastUpdatedDate}_v$totalSections';
  }

  /// Get contact information for legal support
  static Map<String, String> getContactInfo() {
    return {
      'support_email': AppConfig.supportEmailUrl,
      'help_center_url': AppConfig.helpCenterUrl,
      'contact_form_url': AppConfig.contactFormUrl,
      'privacy_policy_url': AppConfig.privacyPolicyUrl,
      'terms_of_service_url': AppConfig.termsOfServiceUrl,
    };
  }

  /// Get support actions for legal pages
  static List<Map<String, dynamic>> getSupportActions() {
    return [
      {
        'id': 'email_support',
        'title': 'Enviar Email',
        'description': 'Entre em contato via email',
        'icon': 'email',
        'action': 'email',
        'url': AppConfig.supportEmailUrl,
      },
      {
        'id': 'help_center',
        'title': 'Central de Ajuda',
        'description': 'Acesse nossa central de ajuda online',
        'icon': 'help',
        'action': 'open_url',
        'url': AppConfig.helpCenterUrl,
      },
      {
        'id': 'contact_form',
        'title': 'Formulário de Contato',
        'description': 'Preencha nosso formulário online',
        'icon': 'contact_form',
        'action': 'open_url',
        'url': AppConfig.contactFormUrl,
      },
    ];
  }

  /// Validate if all configured URLs are properly formatted
  static Map<String, bool> validateUrls() {
    final contactInfo = getContactInfo();
    final validationResults = <String, bool>{};

    for (final entry in contactInfo.entries) {
      validationResults[entry.key] = AppConfig.isValidUrl(entry.value);
    }

    return validationResults;
  }

  /// Get environment-specific legal content metadata
  static Map<String, dynamic> getContentMetadata() {
    return {
      'last_updated': _lastUpdatedDate,
      'formatted_date': getFormattedLastUpdatedDate(),
      'has_recent_updates': hasRecentUpdates(),
      'content_version': getContentVersion(),
      'environment': AppConfig.isProduction ? 'production' : 'development',
      'privacy_sections_count':
          (_privacyPolicyContent['sections'] as List).length,
      'terms_sections_count':
          (_termsOfServiceContent['sections'] as List).length,
      'contact_info': getContactInfo(),
      'url_validations': validateUrls(),
    };
  }

  /// Retorna as seções da política de exclusão de contas
  /// Conforme requisitos das lojas de aplicativos e legislações de privacidade
  static List<LegalSection> getAccountDeletionSections() {
    return [
      const LegalSection(
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
        titleColor: PlantisColors.error,
      ),
      const LegalSection(
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
        titleColor: PlantisColors.error,
      ),
      const LegalSection(
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
        titleColor: PlantisColors.error,
      ),
      const LegalSection(
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
        titleColor: PlantisColors.error,
      ),
      const LegalSection(
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
        titleColor: PlantisColors.primary,
      ),
      const LegalSection(
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
        titleColor: PlantisColors.primary,
        isLast: true,
      ),
    ];
  }
}
