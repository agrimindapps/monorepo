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

final List<Map<String, dynamic>> inappVantagens = [
  {
    'img': 'sem_anuncio.png',
    'title': 'Sem Anuncios',
    'desc':
        'Remova a publicidade e tenha um experiencia de uso aprimorada sem interrupções.'
  },
  {
    'img': 'novidades.png',
    'title': 'Conteúdo Exclusivo',
    'desc':
        'Acesso a informações de aplicação e instruções de uso dos defensivos agrícolas'
  },
  {
    'img': 'compartilhe.png',
    'title': 'Compartilhe',
    'desc':
        'Compartilhe as informações de pragas, produtos e diagnostico com seus contatos'
  },
  {
    'img': 'colaborar.png',
    'title': 'Colaboração',
    'desc':
        'Ajude na manutenção de info. de defenvisos e desenvolvimento do aplicativo.'
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
