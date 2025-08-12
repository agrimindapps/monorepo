/// Constantes específicas de assinatura para o Gasometer
class GasometerSubscriptionConstants {
  // IMPORTANTE: Estas chaves precisam ser substituídas pelas reais do RevenueCat Dashboard
  static const String revenueCatApiKeyApple = 'appl_REAL_GASOMETER_KEY_HERE';
  static const String revenueCatApiKeyGoogle = 'goog_REAL_GASOMETER_KEY_HERE';
  static const String entitlementId = 'gasometer_premium';

  // Produtos atualizados conforme o plano de ação
  static const List<Map<String, dynamic>> productIds = [
    {
      'productId': 'gasometer_anual',
      'type': 'assinatura',
      'desc': 'Contribuição Anual',
      'valueId': 31536000, // 1 ano em milissegundos
      'price': 119.90,
      'currency': 'BRL',
      'isRecommended': true,
      'savings': 'Economize 33%',
      'sharedApps': ['gasometer'], // Preparado para multi-app futuro
    },
    {
      'productId': 'gasometer_trimestral',
      'type': 'assinatura',
      'desc': 'Contribuição Trimestral',
      'valueId': 7884000, // 3 meses em milissegundos
      'price': 39.90,
      'currency': 'BRL',
      'savings': 'Economize 10%',
      'sharedApps': ['gasometer'],
    },
    {
      'productId': 'gasometer_mensal',
      'type': 'assinatura',
      'desc': 'Contribuição Mensal',
      'valueId': 2628000, // 1 mês em milissegundos
      'price': 14.90,
      'currency': 'BRL',
      'sharedApps': ['gasometer'],
    },
  ];

  // Benefícios premium específicos do Gasometer
  static const List<Map<String, dynamic>> premiumBenefits = [
    {
      'icon': 'fuel_calculator',
      'title': 'Sem limitações de uso',
      'description': 'Registre quantos abastecimentos e veículos precisar'
    },
    {
      'icon': 'advanced_stats',
      'title': 'Funcionalidades avançadas',
      'description': 'Estatísticas detalhadas, gráficos e relatórios completos'
    },
    {
      'icon': 'priority_support',
      'title': 'Suporte prioritário',
      'description': 'Atendimento exclusivo e suporte técnico especializado'
    },
    {
      'icon': 'cloud_sync',
      'title': 'Sincronização em nuvem',
      'description':
          'Seus dados seguros e sincronizados em todos os dispositivos'
    },
    {
      'icon': 'no_ads',
      'title': 'Sem anúncios',
      'description': 'Experiência completa sem interrupções ou anúncios'
    },
    {
      'icon': 'export_data',
      'title': 'Exportação de dados',
      'description': 'Exporte relatórios em PDF e planilhas para análise'
    },
  ];

  // Validação de configuração
  static bool get hasValidApiKeys {
    return revenueCatApiKeyApple.isNotEmpty &&
        revenueCatApiKeyGoogle.isNotEmpty &&
        !revenueCatApiKeyApple.contains('REAL_GASOMETER_KEY_HERE') &&
        !revenueCatApiKeyGoogle.contains('REAL_GASOMETER_KEY_HERE');
  }

  // Status de configuração
  static Map<String, dynamic> get configurationStatus {
    return {
      'isConfigured': hasValidApiKeys,
      'appleKeySet': revenueCatApiKeyApple.isNotEmpty &&
          !revenueCatApiKeyApple.contains('HERE'),
      'googleKeySet': revenueCatApiKeyGoogle.isNotEmpty &&
          !revenueCatApiKeyGoogle.contains('HERE'),
      'productsCount': productIds.length,
      'entitlementId': entitlementId,
    };
  }

  // Obter produto por ID
  static Map<String, dynamic>? getProductById(String productId) {
    try {
      return productIds
          .firstWhere((product) => product['productId'] == productId);
    } catch (e) {
      return null;
    }
  }

  // Obter preço formatado
  static String getFormattedPrice(String productId) {
    final product = getProductById(productId);
    if (product == null) return 'N/A';

    final price = product['price'] as double?;
    final currency = product['currency'] as String? ?? 'BRL';

    if (price == null) return 'N/A';

    if (currency == 'BRL') {
      return 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
    }

    return '$currency ${price.toStringAsFixed(2)}';
  }

  // Obter descrição do produto
  static String getProductDescription(String productId) {
    switch (productId) {
      case 'gasometer_anual':
        return 'Melhor valor! Economize 33% com o plano anual completo';
      case 'gasometer_trimestral':
        return 'Compromisso médio com bom desconto trimestral';
      case 'gasometer_mensal':
        return 'Experimente sem compromisso com renovação mensal';
      default:
        return 'Acesso premium completo ao Gasometer';
    }
  }

  // Configuração para debug/desenvolvimento
  static Map<String, dynamic> get debugInfo {
    return {
      'appId': 'gasometer',
      'entitlementId': entitlementId,
      'productsCount': productIds.length,
      'hasValidKeys': hasValidApiKeys,
      'configStatus': configurationStatus,
    };
  }
}
