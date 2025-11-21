/// Constantes do RevenueCat para o app ReceituAgro
class RevenueCatConstants {
  static const String entitlementId = 'Premium';
  static const String appleApiKey = 'appl_QXSaVxUhpIkHBdHyBHAGvjxTxTR';
  static const String googleApiKey = 'goog_JYcfxEUeRnReVEdsLkShLQnzCmf';
  static const String monthlyProductId = 'receituagro_ass_mensal2';
  static const String semiannualProductId = 'receituagro_ass_semestral';
  static const String annualProductId = 'receituagro_ass_anual';
  static const List<String> allProductIds = [
    monthlyProductId,
    semiannualProductId,
    annualProductId,
  ];
  static const String subscriptionRegex = 'receituagro_ass_(mensal2|anual|semestral)';
  static const Map<String, Map<String, dynamic>> productDetails = {
    monthlyProductId: {
      'type': 'assinatura',
      'desc': 'Assinatura Mensal',
      'valueId': 2628000, // 1 mês em segundos
      'period': 'monthly',
    },
    semiannualProductId: {
      'type': 'assinatura',
      'desc': 'Assinatura Semestral',
      'valueId': 15768000, // 6 meses em segundos
      'period': 'semiannual',
    },
    annualProductId: {
      'type': 'assinatura',
      'desc': 'Assinatura Anual',
      'valueId': 31536000, // 12 meses em segundos
      'period': 'annual',
    },
  };
  static const Map<String, String> termsOfUse = {
    'link': 'https://agrimindapps.blogspot.com/2022/08/receituagro-termos-e-condicoes.html',
    'google': 'O Receituagro será renovado automaticamente dentro de 24 horas antes do término do período da assinatura e você será cobrado por meio da sua conta Google Play. Você pode gerenciar sua assinatura pelo Google Play na opção de Assinaturas.',
    'apple': 'A assinatura do Receituagro renovará automaticamente 24 horas antes do término do período e você será cobrado através de sua conta do iTunes. O valor da assinatura atual não pode ser devolvida e o serviço não pode ser interrompido em caso de desistência durante o período de vigência.\n\nSua assinatura pode ser gerenciada através das Configurações de conta do iTunes.',
  };
  static const List<Map<String, String>> premiumBenefits = [
    {
      'img': 'novidades.png',
      'title': 'Dosagem e Aplicações',
      'desc': 'Acesso completo a informações detalhadas sobre dosagem e aplicações dos defensivos',
    },
    {
      'img': 'sem_anuncio.png',
      'title': 'Informações Técnicas',
      'desc': 'Dados técnicos completos e especializados sobre defensivos agrícolas',
    },
    {
      'img': 'colaborar.png',
      'title': 'Registro de Comentários',
      'desc': 'Adicione e gerencie comentários personalizados em diagnósticos e produtos',
    },
    {
      'img': 'compartilhe.png',
      'title': 'Página de Diagnóstico',
      'desc': 'Acesso completo às ferramentas avançadas de diagnóstico de pragas e doenças',
    },
    {
      'img': 'compartilhe.png',
      'title': 'Compartilhamento de Dados',
      'desc': 'Compartilhe dados de diagnósticos e informações técnicas com colegas e parceiros',
    },
    {
      'img': 'colaborar.png',
      'title': 'Colaboração no Desenvolvimento',
      'desc': 'Contribua ativamente para o desenvolvimento e melhoria contínua do aplicativo',
    },
  ];
  static const Map<String, dynamic> defaultSubscriptionInfo = {
    'inicioAssinatura': '',
    'fimAssinatura': '',
    'descAssinatura': 'Não há assinatura ativa',
    'daysRemaning': '0 Dias Restantes',
    'percent': 0,
  };
}
