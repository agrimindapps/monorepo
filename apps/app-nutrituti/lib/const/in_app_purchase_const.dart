// CONFIGURAÇÃO DE ASSINATURAS - app-nutrituti
// Implementação direta (substituindo SubscriptionFactoryService)

const String _appId = 'nutrituti';

// Produtos disponíveis
const List<Map<String, dynamic>> inappProductIds = [
  {
    'id': 'br.com.agrimind.nutrituti.monthly',
    'title': 'Nutrituti Premium - Mensal',
    'price': 'R\$ 9,90',
    'type': 'subscription',
  },
  {
    'id': 'br.com.agrimind.nutrituti.yearly',
    'title': 'Nutrituti Premium - Anual',
    'price': 'R\$ 99,90',
    'type': 'subscription',
  },
];

// Regex para identificar produtos de assinatura
const String regexAssinatura = r'^br\.com\.agrimind\.nutrituti\.(monthly|yearly)$';

// Vantagens do Premium
const List<Map<String, dynamic>> inappVantagens = [
  {'icon': '🧮', 'text': 'Calculadoras ilimitadas sem anúncios'},
  {'icon': '💧', 'text': 'Controle de hidratação avançado'},
  {'icon': '🏋️', 'text': 'Planos de exercícios personalizados'},
  {'icon': '🧘', 'text': 'Meditações exclusivas'},
  {'icon': '📊', 'text': 'Relatórios nutricionais detalhados'},
  {'icon': '🔔', 'text': 'Lembretes inteligentes'},
];

// Termos de uso e privacidade
const Map<String, String> inappTermosUso = {
  'terms': 'https://agrimindapps.blogspot.com/2022/08/nutrituti-termos-e-condicoes.html',
  'privacy': 'https://agrimindapps.blogspot.com/2022/08/nutrituti-politica-de-privacidade.html',
};

// Informações da assinatura
const Map<String, dynamic> infoAssinatura = {
  'name': 'Nutrituti Premium',
  'description': 'Acesso completo a todas as funcionalidades premium do app',
  'trial_days': 7,
  'benefits': [
    'Sem anúncios',
    'Todas as calculadoras desbloqueadas',
    'Estatísticas avançadas',
    'Suporte prioritário',
  ],
};

// RevenueCat Keys
// IMPORTANT: Em produção, estas keys devem vir de variáveis de ambiente
const String entitlementID = 'premium';

// Placeholder keys - SUBSTITUIR por valores reais em produção
const String appleApiKey = 'appl_nutrituti_placeholder';
const String googleApiKey = 'goog_nutrituti_placeholder';

// Validações
bool get isConfigurationValid =>
    inappProductIds.isNotEmpty &&
    entitlementID.isNotEmpty &&
    regexAssinatura.isNotEmpty;

List<String> get configurationErrors {
  final errors = <String>[];

  if (inappProductIds.isEmpty) {
    errors.add('Produtos de assinatura não configurados');
  }

  if (entitlementID.isEmpty) {
    errors.add('Entitlement ID não configurado');
  }

  if (regexAssinatura.isEmpty) {
    errors.add('Regex de validação não configurado');
  }

  if (!hasValidApiKeys) {
    errors.add('API Keys do RevenueCat não configuradas corretamente');
  }

  return errors;
}

bool get hasValidApiKeys =>
    appleApiKey.isNotEmpty &&
    googleApiKey.isNotEmpty &&
    !appleApiKey.contains('placeholder') &&
    !googleApiKey.contains('placeholder');

// Método para obter configuração completa como Map (útil para debugging)
Map<String, dynamic> get fullConfiguration => {
  'app_id': _appId,
  'products': inappProductIds,
  'regex': regexAssinatura,
  'advantages': inappVantagens,
  'terms': inappTermosUso,
  'info': infoAssinatura,
  'entitlement': entitlementID,
  'has_valid_keys': hasValidApiKeys,
};
