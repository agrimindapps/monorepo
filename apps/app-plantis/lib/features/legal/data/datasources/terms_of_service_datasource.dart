import '../../domain/entities/document_type.dart';
import '../models/legal_document_model.dart';
import '../models/legal_section_model.dart';

/// Data source for Terms of Service content
class TermsOfServiceDataSource {
  /// Last update date for the terms of service document
  static const String _lastUpdatedDate = '2024-12-15';

  /// Terms of Service raw content
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

  /// Get Terms of Service document model
  LegalDocumentModel getTermsOfService() {
    final sections = (_termsOfServiceContent['sections'] as List)
        .map((e) => LegalSectionModel.fromMap(e as Map<String, dynamic>))
        .toList();

    return LegalDocumentModel(
      id: DocumentType.termsOfService.id,
      type: DocumentType.termsOfService,
      title: DocumentType.termsOfService.displayName,
      lastUpdated: DateTime.parse('$_lastUpdatedDate 00:00:00'),
      sections: sections,
      version: _getVersionString(sections.length),
    );
  }

  String _getVersionString(int sectionCount) {
    return '${_lastUpdatedDate}_v$sectionCount';
  }
}
