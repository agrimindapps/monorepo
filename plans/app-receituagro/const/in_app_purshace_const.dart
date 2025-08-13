// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_adjacent_string_concatenation

final List<Map<String, dynamic>> inappProductIds = [
  {
    'productId': 'receituagro_ass_anual',
    'type': 'assinatura',
    'desc': 'Assinatura Anual',
    'valueId': 31536000
  },
  {
    'productId': 'receituagro_ass_semestral',
    'type': 'assinatura',
    'desc': 'Assinatura Semestral',
    'valueId': 15768000
  },
  {
    'productId': 'receituagro_ass_mensal2',
    'type': 'assinatura',
    'desc': 'Assinatura Mensal',
    'valueId': 2628000
  }
];

String regexAssinatura = 'receituagro_ass_(mensal2|anual|semestral)';

final List<Map<String, dynamic>> inappVantagens = [
  {
    'img': 'novidades.png',
    'title': 'Dosagem e Aplicações',
    'desc':
        'Acesso completo a informações detalhadas sobre dosagem e aplicações dos defensivos'
  },
  {
    'img': 'sem_anuncio.png',
    'title': 'Informações Técnicas',
    'desc':
        'Dados técnicos completos e especializados sobre defensivos agrícolas'
  },
  {
    'img': 'colaborar.png',
    'title': 'Registro de Comentários',
    'desc':
        'Adicione e gerencie comentários personalizados em diagnósticos e produtos'
  },
  {
    'img': 'compartilhe.png',
    'title': 'Página de Diagnóstico',
    'desc':
        'Acesso completo às ferramentas avançadas de diagnóstico de pragas e doenças'
  },
  {
    'img': 'compartilhe.png',
    'title': 'Compartilhamento de Dados',
    'desc':
        'Compartilhe dados de diagnósticos e informações técnicas com colegas e parceiros'
  },
  {
    'img': 'colaborar.png',
    'title': 'Colaboração no Desenvolvimento',
    'desc':
        'Contribua ativamente para o desenvolvimento e melhoria contínua do aplicativo'
  }
];

final Map<String, String> inappTermosUso = {
  'link':
      'https://agrimindapps.blogspot.com/2022/08/receituagro-termos-e-condicoes.html',
  'google':
      'O Receituagro será renovado automaticamente dentro de 24 horas anes do término do periodo da assinatura e ' +
          'você será cobrado por meio da sua conta Google Play. Você pode gerenciarsua assinatura pelo Google Play na opção de Assinaturas.',
  'apple': 'A assinatura do Receituagro renovara automaticamente 24 horas antes do término do período e você será cobrado ' +
      'através de sua conta do iTunes. O valor da assinatura atual não  pode ser devolvida e o serviço não pode ser ' +
      'interrompido em caso de desistencia durante o período  de vigencia. \n\n Sua assinatura pode ser gerenciada através das Configurações de conta do Itunes.'
};

final Map<String, dynamic> infoAssinatura = {
  'inicioAssinatura': '',
  'fimAssinatura': '',
  'descAssinatura': 'Não há assinatura ativa',
  'daysRemaning': '0 Dias Restantes',
  'percent': 0
};
