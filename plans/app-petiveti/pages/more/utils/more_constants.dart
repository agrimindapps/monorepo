// Flutter imports:
import 'package:flutter/material.dart';

class MoreConstants {
  MoreConstants._();

  // App Information
  static const String appName = 'PetiVeti';
  static const String appVersion = '1.0.0';
  static const String appPackageId = 'com.petiveti';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=$appPackageId';
  static const String appStoreUrl = 'https://apps.apple.com/app/petiveti/id123456789';

  // URLs
  static const String websiteUrl = 'https://petiveti.com';
  static const String helpUrl = 'https://petiveti.com/ajuda';
  static const String privacyPolicyUrl = 'https://petiveti.com/privacidade';
  static const String termsOfServiceUrl = 'https://petiveti.com/termos';
  static const String aboutUrl = 'https://petiveti.com/sobre';
  static const String blogUrl = 'https://petiveti.com/blog';
  static const String faqUrl = 'https://petiveti.com/faq';

  // Contact Information
  static const String supportEmail = 'suporte@petiveti.com';
  static const String feedbackEmail = 'feedback@petiveti.com';
  static const String bugReportEmail = 'bugs@petiveti.com';
  static const String businessEmail = 'contato@petiveti.com';
  static const String supportPhone = '+55 11 99999-9999';

  // Social Media
  static const String facebookUrl = 'https://facebook.com/petiveti';
  static const String instagramUrl = 'https://instagram.com/petiveti';
  static const String twitterUrl = 'https://twitter.com/petiveti';
  static const String youtubeUrl = 'https://youtube.com/petiveti';
  static const String linkedinUrl = 'https://linkedin.com/company/petiveti';

  // Share Messages
  static const String defaultShareMessage = 'Experimente o PetiVeti, o aplicativo completo para cuidar da saúde e bem-estar do seu pet!';
  static const String premiumShareMessage = 'Conheça o PetiVeti Premium! Recursos exclusivos para o cuidado completo do seu pet.';
  static const String feedbackShareMessage = 'O PetiVeti está me ajudando muito a cuidar do meu pet! Recomendo a todos os tutores.';

  // Email Subjects
  static const String supportEmailSubject = 'Suporte PetiVeti App';
  static const String feedbackEmailSubject = 'Feedback PetiVeti App';
  static const String bugReportEmailSubject = 'Bug Report PetiVeti App';
  static const String businessEmailSubject = 'Contato Comercial PetiVeti';

  // Routes
  static const String promoRoute = '/promo';
  static const String aboutRoute = '/sobre';
  static const String subscriptionRoute = '/subscription';
  static const String updatesRoute = '/atualizacoes';
  static const String helpRoute = '/ajuda';
  static const String settingsRoute = '/opcoes';
  static const String databaseRoute = '/database';

  // Colors
  static const Color primaryColor = Color(0xFF6A1B9A); // Purple 800
  static const Color secondaryColor = Color(0xFF388E3C); // Green 700
  static const Color accentColor = Color(0xFFFFA000); // Amber 700
  static const Color errorColor = Color(0xFFD32F2F); // Red 700
  static const Color warningColor = Color(0xFFFF8F00); // Amber 800
  static const Color infoColor = Color(0xFF1976D2); // Blue 700
  static const Color successColor = Color(0xFF388E3C); // Green 700

  // Section Colors
  static const Color aboutSectionColor = Color(0xFF1976D2); // Blue 700
  static const Color accountSectionColor = Color(0xFF388E3C); // Green 700
  static const Color supportSectionColor = Color(0xFFFF8F00); // Amber 800

  // Icons
  static const IconData defaultIcon = Icons.help_outline;
  static const IconData navigationIcon = Icons.chevron_right;
  static const IconData externalIcon = Icons.open_in_new;
  static const IconData shareIcon = Icons.share;
  static const IconData emailIcon = Icons.mail_outline;
  static const IconData premiumIcon = Icons.workspace_premium;

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double sectionSpacing = 20.0;
  static const double itemSpacing = 8.0;
  static const double iconSize = 24.0;
  static const double iconContainerSize = 40.0;
  static const double borderRadius = 8.0;
  static const double elevation = 2.0;

  // Typography
  static const double titleFontSize = 18.0;
  static const double subtitleFontSize = 14.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 12.0;
  static const FontWeight titleFontWeight = FontWeight.bold;
  static const FontWeight subtitleFontWeight = FontWeight.w500;
  static const FontWeight bodyFontWeight = FontWeight.normal;

  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  static const Curve defaultAnimationCurve = Curves.easeInOut;

  // Limits
  static const int maxSectionItems = 10;
  static const int maxSearchResults = 50;
  static const int maxShareHistoryItems = 100;
  static const int maxRecentActions = 20;

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration shareTimeout = Duration(seconds: 10);
  static const Duration emailTimeout = Duration(seconds: 15);
  static const Duration urlTimeout = Duration(seconds: 20);

  // Debug
  static const bool enableDebugMode = false;
  static const bool enableAnalytics = true;
  static const bool enableLogging = false;
  static const String debugTag = 'MorePage';

  // Feature Flags
  static const bool enableSectionCollapse = true;
  static const bool enableSearch = true;
  static const bool enableShareHistory = true;
  static const bool enableCustomThemes = false;
  static const bool enableSocialSharing = true;

  // Default Values
  static const bool defaultSectionExpanded = true;
  static const bool defaultAnalyticsEnabled = true;
  static const int defaultMaxSectionItems = 5;
  static const String defaultErrorMessage = 'Ocorreu um erro inesperado';
  static const String defaultLoadingMessage = 'Carregando...';
  static const String defaultEmptyMessage = 'Nenhum item encontrado';

  // Validation
  static const int minTitleLength = 1;
  static const int maxTitleLength = 100;
  static const int minDescriptionLength = 0;
  static const int maxDescriptionLength = 500;
  static const int minUrlLength = 10;
  static const int maxUrlLength = 2000;
  static const int minEmailLength = 5;
  static const int maxEmailLength = 100;

  // Cache
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100;
  static const String cacheKeyPrefix = 'more_page_';

  // Analytics Events
  static const String analyticsPageView = 'more_page_view';
  static const String analyticsItemTap = 'more_item_tap';
  static const String analyticsSectionToggle = 'more_section_toggle';
  static const String analyticsShare = 'more_share';
  static const String analyticsEmail = 'more_email';
  static const String analyticsUrl = 'more_url_open';
  static const String analyticsError = 'more_error';

  // Platform-specific
  static const String androidPackageName = appPackageId;
  static const String iosAppId = '123456789';
  static const String windowsAppId = 'PetiVeti.App';
  static const String macosAppId = 'com.petiveti.macos';
  static const String linuxAppId = 'com.petiveti.linux';

  // Localization Keys
  static const String titleKey = 'more_page_title';
  static const String aboutSectionKey = 'about_section_title';
  static const String accountSectionKey = 'account_section_title';
  static const String supportSectionKey = 'support_section_title';
  static const String shareAppKey = 'share_app_title';
  static const String rateAppKey = 'rate_app_title';
  static const String contactKey = 'contact_title';
  static const String helpKey = 'help_title';

  // Error Messages
  static const String errorNetworkUnavailable = 'Conexão com internet não disponível';
  static const String errorUrlInvalid = 'URL inválida';
  static const String errorEmailInvalid = 'Email inválido';
  static const String errorShareFailed = 'Falha ao compartilhar';
  static const String errorEmailFailed = 'Falha ao abrir cliente de email';
  static const String errorUrlFailed = 'Falha ao abrir URL';
  static const String errorUnknown = 'Erro desconhecido';

  // Success Messages
  static const String successShare = 'Compartilhado com sucesso';
  static const String successEmail = 'Email aberto com sucesso';
  static const String successUrl = 'Link aberto com sucesso';
  static const String successAction = 'Ação executada com sucesso';

  // Info Messages
  static const String infoLoading = 'Carregando informações...';
  static const String infoProcessing = 'Processando solicitação...';
  static const String infoNoItems = 'Nenhum item disponível';
  static const String infoNoHistory = 'Nenhum histórico disponível';
  static const String infoSearchEmpty = 'Nenhum resultado encontrado';

  // Accessibility
  static const String accessibilitySection = 'Seção';
  static const String accessibilityMenuItem = 'Item de menu';
  static const String accessibilityExpandButton = 'Botão expandir seção';
  static const String accessibilityCollapseButton = 'Botão contrair seção';
  static const String accessibilityShareButton = 'Botão compartilhar';
  static const String accessibilityEmailButton = 'Botão email';
  static const String accessibilityUrlButton = 'Botão abrir link';

  // Test Values
  static const String testEmail = 'test@petiveti.com';
  static const String testUrl = 'https://test.petiveti.com';
  static const String testShareText = 'Texto de teste para compartilhamento';
  static const String testErrorMessage = 'Erro de teste';
  static const String testSuccessMessage = 'Sucesso de teste';
}
