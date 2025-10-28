// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_adjacent_string_concatenation

final List<Map<String, dynamic>> inappProductIds = [
  // {'productId': 'receituagro_ass_anual', 'type': 'assinatura', 'desc': 'Assinatura Anual', 'valueId': 31536000},
  {
    'productId': 'termus_trimestral',
    'type': 'assinatura',
    'desc': 'Contribuição Trimestral',
    'valueId': 7884000
  },
  {
    'productId': 'termus_mensal',
    'type': 'assinatura',
    'desc': 'Contribuição Mensal',
    'valueId': 2628000
  }
];

String regexAssinatura = 'termus_(mensal|trimestral)';

final List<Map<String, dynamic>> inappVantagens = [
  {
    'img': 'manutencao_billing.png',
    'desc': 'Ajuda com a manutenção e melhorias no aplicativo!'
  },
  {
    'img': 'newfeatures.png',
    'desc': 'Contribui com o desenvolvimento de novas funcionalidades!'
  },
  {
    'img': 'sem_anuncio.png',
    'desc': 'Não exibimos anúncios durante a utilização'
  },
  {
    'img': 'premium_billing.png',
    'desc': 'Tenha acesso a funcionalidades exclusivas e sem limites!'
  },
];

final Map<String, String> inappTermosUso = {
  'link':
      'https://agrimindapps.blogspot.com/2022/08/receituagro-termos-e-condicoes.html',
  'google':
      'O Termus será renovado automaticamente dentro de 24 horas anes do término do periodo da contribuição e ' +
          'você será cobrado por meio da sua conta Google Play. Você pode gerenciarsua contribuição pelo Google Play na opção de contribuições.',
  'apple': 'A contribuição do Termus renovara automaticamente 24 horas antes do término do período e você será cobrado ' +
      'através de sua conta do iTunes. O valor da contribuição atual não  pode ser devolvida e o serviço não pode ser ' +
      'interrompido em caso de desistencia durante o período  de vigencia. \n\n Sua contribuição pode ser gerenciada através das Configurações de conta do Itunes.'
};

final Map<String, dynamic> infoAssinatura = {
  'inicioAssinatura': '',
  'fimAssinatura': '',
  'descAssinatura': 'Não há assinatura ativa',
  'daysRemaning': '0 Dias Restantes',
  'percent': 0
};
