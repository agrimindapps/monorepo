// Flutter imports:
import 'package:flutter/material.dart';

class PromoConstants {
  PromoConstants._();

  // App Information
  static const String appName = 'PetiVeti';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'O aplicativo mais completo para tutores que se preocupam com a saúde e bem-estar de seus pets';
  static const String appTagline = 'Cuidados completos para seu melhor amigo';
  static const String appPackageId = 'com.petiveti';

  // URLs
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=$appPackageId';
  static const String appStoreUrl = 'https://apps.apple.com/app/petiveti/id123456789';
  static const String websiteUrl = 'https://petiveti.com';
  static const String helpUrl = 'https://petiveti.com/ajuda';
  static const String privacyPolicyUrl = 'https://petiveti.com/privacidade';
  static const String termsOfServiceUrl = 'https://petiveti.com/termos';
  static const String blogUrl = 'https://petiveti.com/blog';
  static const String contactUrl = 'https://petiveti.com/contato';

  // Social Media URLs
  static const String facebookUrl = 'https://facebook.com/petiveti';
  static const String instagramUrl = 'https://instagram.com/petiveti';
  static const String twitterUrl = 'https://twitter.com/petiveti';
  static const String youtubeUrl = 'https://youtube.com/petiveti';
  static const String linkedinUrl = 'https://linkedin.com/company/petiveti';

  // Contact Information
  static const String supportEmail = 'suporte@petiveti.com';
  static const String feedbackEmail = 'feedback@petiveti.com';
  static const String businessEmail = 'contato@petiveti.com';
  static const String supportPhone = '+55 11 99999-9999';

  // Launch Information
  static final DateTime launchDate = DateTime(2025, 10, 1);
  static const String launchDateFormatted = '1º de Outubro de 2025';
  static const String launchStatus = 'EM BREVE';
  static const String betaStatus = 'BETA';

  // Colors - Main Theme
  static const Color primaryColor = Color(0xFF6A1B9A); // Purple 800
  static const Color accentColor = Color(0xFF03A9F4); // Light Blue 500
  static const Color backgroundColor = Color(0xFFF5F5F5); // Grey 100
  static const Color textColor = Color(0xFF333333); // Dark Grey
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;

  // Colors - Feature Categories
  static const Color petProfilesColor = Color(0xFF6A1B9A); // Purple 700
  static const Color vaccinesColor = Color(0xFFD32F2F); // Red 600
  static const Color medicationsColor = Color(0xFF388E3C); // Green 700
  static const Color weightControlColor = Color(0xFFFF8F00); // Orange 700
  static const Color appointmentsColor = Color(0xFF1976D2); // Blue 600
  static const Color remindersColor = Color(0xFF00796B); // Teal 700

  // Colors - UI Elements
  static const Color successColor = Color(0xFF4CAF50); // Green 500
  static const Color errorColor = Color(0xFFF44336); // Red 500
  static const Color warningColor = Color(0xFFFF9800); // Orange 500
  static const Color infoColor = Color(0xFF2196F3); // Blue 500

  // Colors - Gradients
  static const List<Color> heroGradient = [
    Color(0xFF6A1B9A), // Purple 800
    Color(0xFF4A148C), // Purple 900
  ];
  
  static const List<Color> screenshotsGradient = [
    Color(0xCC6A1B9A), // Purple 800 with opacity
    Color(0xFF6A1B9A), // Purple 800
  ];

  // Typography - Font Sizes
  static const double heroTitleFontSize = 46.0;
  static const double heroSubtitleFontSize = 24.0;
  static const double sectionTitleFontSize = 36.0;
  static const double sectionSubtitleFontSize = 18.0;
  static const double cardTitleFontSize = 20.0;
  static const double cardDescriptionFontSize = 15.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;
  static const double smallFontSize = 12.0;

  // Typography - Font Weights
  static const FontWeight heroTitleWeight = FontWeight.bold;
  static const FontWeight heroSubtitleWeight = FontWeight.w500;
  static const FontWeight sectionTitleWeight = FontWeight.bold;
  static const FontWeight cardTitleWeight = FontWeight.bold;
  static const FontWeight bodyWeight = FontWeight.normal;
  static const FontWeight buttonWeight = FontWeight.bold;

  // Spacing and Layout
  static const double defaultPadding = 16.0;
  static const double sectionPadding = 80.0;
  static const double sectionPaddingMobile = 40.0;
  static const double cardPadding = 24.0;
  static const double itemSpacing = 20.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 40.0;

  // Border Radius
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 20.0;
  static const double buttonBorderRadius = 30.0;
  static const double imageBorderRadius = 30.0;
  static const double iconBorderRadius = 8.0;

  // Shadows and Elevation
  static const double defaultElevation = 2.0;
  static const double cardElevation = 5.0;
  static const double buttonElevation = 3.0;
  static const List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: Color(0x0D000000), // Black with 5% opacity
      spreadRadius: 1,
      blurRadius: 10,
      offset: Offset(0, 5),
    ),
  ];

  // Navigation
  static const double navBarHeight = 80.0;
  static const double navBarHeightMobile = 60.0;
  static const double navBarElevation = 10.0;
  static const double navBarBlurRadius = 10.0;
  static const Color navBarShadowColor = Color(0x0D000000);

  // Hero Section
  static const double heroVerticalPadding = 120.0;
  static const double heroVerticalPaddingMobile = 60.0;
  static const double heroImageHeight = 500.0;
  static const double heroAccentLineWidth = 80.0;
  static const double heroAccentLineHeight = 4.0;
  static const String heroImageUrl = 'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/vetipeti.png';

  // Features Section
  static const double featureIconSize = 40.0;
  static const double featureIconPadding = 16.0;
  static const double featureCardHeight = 260.0;
  static const int featuresGridDesktop = 3;
  static const int featuresGridTablet = 2;
  static const int featuresGridMobile = 1;
  static const double featuresGridSpacing = 30.0;

  // Screenshots Section
  static const double screenshotsHeight = 600.0;
  static const double screenshotWidth = 300.0;
  static const double screenshotHeight = 600.0;
  static const double screenshotMargin = 15.0;
  static const double screenshotBorderRadius = 20.0;

  // Testimonials Section
  static const double testimonialCardHeight = 300.0;
  static const double testimonialAvatarRadius = 25.0;
  static const double testimonialQuoteIconSize = 30.0;
  static const int testimonialsGridDesktop = 3;
  static const int testimonialsGridTablet = 2;
  static const int testimonialsGridMobile = 1;

  // Download/CTA Section
  static const double ctaSectionPadding = 80.0;
  static const double ctaCardPadding = 20.0;
  static const double ctaButtonPadding = 12.0;
  static const double ctaButtonHorizontalPadding = 20.0;

  // Countdown Section
  static const double countdownContainerPadding = 20.0;
  static const double countdownUnitPadding = 15.0;
  static const double countdownUnitVerticalPadding = 10.0;
  static const double countdownUnitBorderRadius = 8.0;
  static const double countdownDividerPadding = 10.0;
  static const double countdownValueFontSize = 24.0;
  static const double countdownLabelFontSize = 12.0;

  // FAQ Section
  static const double faqItemPadding = 16.0;
  static const double faqTileRadius = 10.0;
  static const double faqIconSize = 24.0;
  static const double faqTitleFontSize = 16.0;
  static const double faqAnswerFontSize = 14.0;

  // Footer Section
  static const double footerPadding = 40.0;
  static const double footerSocialIconPadding = 10.0;
  static const double footerSocialIconSize = 20.0;
  static const double footerDividerOpacity = 0.2;

  // Buttons
  static const double buttonHeight = 48.0;
  static const double buttonMinWidth = 120.0;
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 16);
  static const EdgeInsets buttonIconPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 12);

  // Form Elements
  static const double inputHeight = 56.0;
  static const double inputBorderRadius = 8.0;
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const double inputSpacing = 12.0;

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration defaultAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration scrollAnimation = Duration(milliseconds: 800);
  static const Duration countdownUpdate = Duration(seconds: 1);

  // Animation Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve fastCurve = Curves.easeOut;
  static const Curve scrollCurve = Curves.easeInOut;
  static const Curve bouncyCurve = Curves.bounceOut;

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  static const double ultrawideBreakpoint = 1600.0;

  // Content Constraints
  static const double maxContentWidth = 1600.0;
  static const double maxContentWidthDesktop = 1200.0;
  static const double maxContentWidthTablet = 800.0;

  // Icons
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double smallIconSize = 16.0;
  static const double featureIconContainerSize = 72.0;

  // Z-Index / Layers
  static const double backgroundLayer = 0.0;
  static const double contentLayer = 1.0;
  static const double overlayLayer = 2.0;
  static const double modalLayer = 3.0;
  static const double tooltipLayer = 4.0;

  // Opacity Values
  static const double disabledOpacity = 0.5;
  static const double hoverOpacity = 0.8;
  static const double pressedOpacity = 0.6;
  static const double backgroundOpacity = 0.1;
  static const double shadowOpacity = 0.05;

  // Performance
  static const int maxCacheSize = 100;
  static const Duration cacheExpiration = Duration(hours: 24);
  static const bool enableImageCaching = true;
  static const bool enableLazyLoading = true;

  // Debug and Development
  static const bool enableDebugMode = false;
  static const bool showPerformanceOverlay = false;
  static const bool enableLogging = true;
  static const String debugTag = 'PromoPage';

  // Feature Flags
  static const bool enableCountdown = true;
  static const bool enablePreRegistration = true;
  static const bool enableSocialShare = true;
  static const bool enableAnalytics = true;
  static const bool enableNotifications = true;
  static const bool enableAnimations = true;

  // Default Values
  static const String defaultErrorMessage = 'Ocorreu um erro inesperado';
  static const String defaultLoadingMessage = 'Carregando...';
  static const String defaultEmptyMessage = 'Nenhum conteúdo disponível';
  static const String defaultSuccessMessage = 'Operação realizada com sucesso';

  // Validation Rules
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minEmailLength = 5;
  static const int maxEmailLength = 100;
  static const int maxMessageLength = 1000;

  // Rate Limiting
  static const Duration minTimeBetweenRequests = Duration(seconds: 1);
  static const int maxRequestsPerMinute = 60;
  static const Duration requestTimeout = Duration(seconds: 30);

  // Accessibility
  static const double minTouchTargetSize = 44.0;
  static const double accessibilityFontScale = 1.2;
  static const Duration accessibilityTimeout = Duration(seconds: 10);

  // Localization Keys
  static const String titleKey = 'promo_page_title';
  static const String heroTitleKey = 'hero_title';
  static const String heroSubtitleKey = 'hero_subtitle';
  static const String featuresKey = 'features_section';
  static const String testimonialsKey = 'testimonials_section';
  static const String downloadKey = 'download_section';
  static const String faqKey = 'faq_section';

  // Test Values (for development/testing)
  static const String testEmail = 'test@petiveti.com';
  static const String testName = 'Usuário Teste';
  static const String testMessage = 'Esta é uma mensagem de teste';
  static const String testErrorMessage = 'Erro de teste simulado';

  // Platform Specific
  static const String androidPackageName = appPackageId;
  static const String iosAppId = '123456789';
  static const String webUrl = websiteUrl;

  // SEO and Meta
  static const String metaTitle = 'PetiVeti - Cuidados completos para seu pet';
  static const String metaDescription = 'O aplicativo mais completo para tutores que se preocupam com a saúde e bem-estar de seus pets. Controle vacinas, medicamentos, peso e muito mais.';
  static const List<String> metaKeywords = [
    'pet',
    'veterinario',
    'saude animal',
    'vacinas',
    'medicamentos',
    'aplicativo',
    'cuidados',
  ];

  // API Endpoints (if needed)
  static const String apiBaseUrl = 'https://api.petiveti.com';
  static const String preRegisterEndpoint = '/api/pre-register';
  static const String notificationEndpoint = '/api/notifications';
  static const String analyticsEndpoint = '/api/analytics';

  // Content Limits
  static const int maxFeaturesCount = 10;
  static const int maxTestimonialsCount = 20;
  static const int maxFAQCount = 15;
  static const int maxScreenshotsCount = 10;

  // Error Codes
  static const String errorNetworkUnavailable = 'NETWORK_UNAVAILABLE';
  static const String errorInvalidEmail = 'INVALID_EMAIL';
  static const String errorEmailAlreadyRegistered = 'EMAIL_ALREADY_REGISTERED';
  static const String errorRequestTimeout = 'REQUEST_TIMEOUT';
  static const String errorServerError = 'SERVER_ERROR';
  static const String errorUnknown = 'UNKNOWN_ERROR';

  // Success Messages
  static const String successPreRegistration = 'Obrigado! Você será notificado quando o app for lançado.';
  static const String successEmailSent = 'Email enviado com sucesso!';
  static const String successFormSubmitted = 'Formulário enviado com sucesso!';

  // Info Messages
  static const String infoLaunchingSoon = 'O PetiVeti será lançado em breve!';
  static const String infoEnterEmail = 'Digite seu email para ser notificado';
  static const String infoSelectPlatform = 'Escolha sua plataforma preferida';
  static const String infoPrivacyNotice = 'Respeitamos sua privacidade e não compartilhamos seus dados';
}
