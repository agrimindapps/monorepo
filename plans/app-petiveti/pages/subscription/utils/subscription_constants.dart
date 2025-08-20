// Flutter imports:
import 'package:flutter/material.dart';

class SubscriptionConstants {
  // Colors
  static const Color primaryColor = Color(0xFF4A90E2);
  static const Color secondaryColor = Color(0xFF7B68EE);
  static const Color accentColor = Color(0xFF9370DB);
  static const Color successColor = Color(0xFF50C878);
  static const Color warningColor = Color(0xFFFF6B35);
  static const Color errorColor = Color(0xFFFF4444);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor, accentColor],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.white, Color(0xFFF8F9FA)],
  );
  
  // Text Styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );
  
  static const TextStyle priceStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  // Dimensions
  static const double cardElevation = 4.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 8.0;
  static const double iconSize = 24.0;
  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 32.0;
  
  // Padding
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(20.0);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 12.0);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: 24.0);
  
  // Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration loadingTimeout = Duration(seconds: 30);
  static const Duration purchaseTimeout = Duration(minutes: 2);
  static const Duration autoResetDuration = Duration(seconds: 3);
  
  // Icons
  static const IconData premiumIcon = Icons.pets;
  static const IconData checkIcon = Icons.check_circle;
  static const IconData loadingIcon = Icons.hourglass_empty;
  static const IconData errorIcon = Icons.error_outline;
  static const IconData restoreIcon = Icons.restore;
  static const IconData termsIcon = Icons.gavel;
  
  // Strings
  static const String appTitle = 'PetiVeti Premium';
  static const String subscriptionTitle = 'Assinatura Premium';
  static const String benefitsTitle = 'Recursos Premium';
  static const String packagesTitle = 'Planos Disponíveis';
  static const String restoreTitle = 'Já é Premium?';
  static const String termsTitle = 'Termos e Condições';
  
  // Messages
  static const String loadingMessage = 'Carregando informações...';
  static const String purchasingMessage = 'Processando compra...';
  static const String restoringMessage = 'Restaurando compras...';
  static const String successMessage = 'Operação realizada com sucesso!';
  static const String errorMessage = 'Ocorreu um erro. Tente novamente.';
  static const String noOffersMessage = 'Nenhuma oferta disponível no momento.';
  static const String restoreSuccessMessage = 'Compras restauradas com sucesso!';
  static const String restoreNoProductsMessage = 'Nenhuma compra encontrada para restaurar.';
  
  // Button Labels
  static const String purchaseButtonLabel = 'Assinar Premium';
  static const String restoreButtonLabel = 'Restaurar Compras';
  static const String termsButtonLabel = 'Termos de Uso';
  static const String privacyButtonLabel = 'Privacidade';
  static const String retryButtonLabel = 'Tentar Novamente';
  static const String cancelButtonLabel = 'Cancelar';
  
  // Package Labels
  static const Map<String, String> packageLabels = {
    'weekly': 'Semanal',
    'monthly': 'Mensal',
    'threeMonth': 'Trimestral',
    'sixMonth': 'Semestral',
    'annual': 'Anual',
    'lifetime': 'Vitalício',
  };
  
  // Package Descriptions
  static const Map<String, String> packageDescriptions = {
    'weekly': 'Renovação semanal',
    'monthly': 'Renovação mensal',
    'threeMonth': 'Renovação a cada 3 meses',
    'sixMonth': 'Renovação a cada 6 meses',
    'annual': 'Renovação anual',
    'lifetime': 'Pagamento único',
  };
  
  // Badge Labels
  static const String recommendedBadge = 'Recomendado';
  static const String bestValueBadge = 'Melhor Valor';
  static const String popularBadge = 'Mais Popular';
  static const String discountBadge = 'OFF';
  
  // Legal Text
  static const String defaultTermsText = 
      'A assinatura será renovada automaticamente ao final de cada período. '
      'Cancele a qualquer momento nas configurações da sua conta na loja de aplicativos. '
      'Oferecemos suporte técnico especializado para veterinários.';
  
  // Feature Categories
  static const Map<String, String> featureCategories = {
    'professional': 'Recursos Profissionais',
    'feature': 'Funcionalidades',
    'convenience': 'Conveniências',
    'support': 'Suporte',
  };
  
  // Error Messages
  static const Map<String, String> errorMessages = {
    'network': 'Erro de conexão. Verifique sua internet.',
    'purchase_not_allowed': 'Compras não permitidas neste dispositivo.',
    'purchase_invalid': 'Produto não disponível para compra.',
    'purchase_cancelled': 'Compra cancelada pelo usuário.',
    'store_problem': 'Problema com a loja. Tente novamente.',
    'payment_pending': 'Pagamento pendente. Aguarde confirmação.',
    'configuration': 'Erro de configuração da aplicação.',
    'unknown': 'Erro desconhecido. Tente novamente.',
  };
  
  // Analytics Events
  static const Map<String, String> analyticsEvents = {
    'page_view': 'subscription_page_view',
    'purchase_started': 'subscription_purchase_started',
    'purchase_completed': 'subscription_purchase_completed',
    'purchase_failed': 'subscription_purchase_failed',
    'restore_started': 'subscription_restore_started',
    'restore_completed': 'subscription_restore_completed',
    'restore_failed': 'subscription_restore_failed',
    'terms_viewed': 'subscription_terms_viewed',
    'privacy_viewed': 'subscription_privacy_viewed',
  };
  
  // Device Support
  static const List<String> supportedPlatforms = ['ios', 'android'];
  static const double minSupportedVersion = 12.0; // iOS 12+ / Android API 21+
  
  // Cache Settings
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100; // Maximum number of cached items
  
  // Retry Settings
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Validation Rules
  static const double minPrice = 0.99;
  static const double maxPrice = 999.99;
  static const int minTitleLength = 3;
  static const int maxTitleLength = 100;
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 500;
}
