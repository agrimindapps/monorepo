// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/navigation_model.dart';
import '../models/promo_content_model.dart';
import '../services/launch_service.dart';
import '../services/responsive_service.dart';
import 'countdown_controller.dart';
import 'navigation_controller.dart';
import 'pre_register_controller.dart';

class PromoController extends ChangeNotifier {
  // Services and Controllers
  late final ResponsiveService _responsiveService;
  late final NavigationController _navigationController;
  late final CountdownController _countdownController;
  late final PreRegisterController _preRegisterController;
  late final LaunchService _launchService;

  // State
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  PromoContent? _promoContent;
  
  // UI State
  String? _hoveredFeature;
  String? _hoveredTestimonial;
  String? _hoveredFAQ;
  String? _expandedFAQ;
  int _currentScreenshotIndex = 0;
  bool _showPreRegisterDialog = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  PromoContent? get promoContent => _promoContent;
  
  // UI State getters
  String? get hoveredFeature => _hoveredFeature;
  String? get hoveredTestimonial => _hoveredTestimonial;
  String? get hoveredFAQ => _hoveredFAQ;
  String? get expandedFAQ => _expandedFAQ;
  int get currentScreenshotIndex => _currentScreenshotIndex;
  bool get isPreRegisterDialogVisible => _showPreRegisterDialog;

  // Delegated getters
  ResponsiveBreakpoint get currentBreakpoint => _responsiveService.currentBreakpoint;
  bool get isDesktop => _responsiveService.isDesktop;
  bool get isTablet => _responsiveService.isTablet;
  bool get isMobile => _responsiveService.isMobile;
  
  NavigationController get navigationController => _navigationController;
  CountdownController get countdownController => _countdownController;
  PreRegisterController get preRegisterController => _preRegisterController;
  LaunchService get launchService => _launchService;
  
  // Navigation delegates
  ScrollController? get scrollController => _navigationController.scrollController;
  NavigationSection? get currentSection => _navigationController.currentSection;
  bool get isNavBarScrolled => _navigationController.isScrolling;

  PromoController() {
    _initializeServices();
  }

  void _initializeServices() {
    _responsiveService = ResponsiveService();
    _navigationController = NavigationController();
    _countdownController = CountdownController();
    _preRegisterController = PreRegisterController();
    _launchService = LaunchService();

    // Listen to child controllers
    _navigationController.addListener(_notifyListeners);
    _countdownController.addListener(_notifyListeners);
    _preRegisterController.addListener(_notifyListeners);
  }

  void _notifyListeners() {
    notifyListeners();
  }

  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      await _loadContent();
      await _initializeChildControllers();
      _isInitialized = true;
      _clearError();
    } catch (e) {
      _setError('Erro ao inicializar página promocional: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadContent() async {
    try {
      // Create sample content for now
      _promoContent = _createSampleContent();
    } catch (e) {
      throw Exception('Erro ao carregar conteúdo: $e');
    }
  }

  PromoContent _createSampleContent() {
    return PromoContent(
      heroContent: const HeroContent(
        title: 'Bem-vindo ao PetiVeti',
        subtitle: 'O app mais completo para cuidar do seu pet',
        description: 'Controle vacinas, medicamentos, peso e muito mais!',
        imageUrl: '',
        highlights: ['Grátis', 'Simples', 'Completo'],
      ),
      featuresContent: FeaturesContent(
        title: 'Recursos',
        subtitle: 'Tudo que seu pet precisa em um só app',
        features: PromoContentRepository.getFeatures(),
      ),
      screenshotsContent: ScreenshotsContent(
        title: 'Screenshots',
        subtitle: 'Veja como é fácil usar',
        screenshots: PromoContentRepository.getScreenshots(),
      ),
      testimonialsContent: TestimonialsContent(
        title: 'Depoimentos',
        subtitle: 'O que nossos usuários dizem',
        testimonials: PromoContentRepository.getTestimonials(),
      ),
      downloadContent: const DownloadContent(
        prelaunchTitle: 'Em breve!',
        prelaunchSubtitle: 'Cadastre-se para ser notificado',
        launchedTitle: 'Disponível agora!',
        launchedSubtitle: 'Baixe o app',
        highlights: [],
        storeFeatures: [],
      ),
      faqContent: FAQContent(
        title: 'FAQ',
        subtitle: 'Perguntas frequentes',
        faqs: PromoContentRepository.getFAQItems(),
      ),
      footerContent: const FooterContent(
        appName: 'PetiVeti',
        tagline: 'Cuidando do seu melhor amigo',
        description: 'O app mais completo para pets',
        appVersion: '1.0.0',
        copyright: '© 2025 PetiVeti. Todos os direitos reservados.',
        contactEmail: 'contato@petiveti.com',
        contactPhone: '+55 11 99999-9999',
        address: 'São Paulo, SP',
        quickLinks: [],
        socialLinks: [],
        legalLinks: [],
      ),
    );
  }

  Future<void> _initializeChildControllers() async {
    await Future.wait([
      _navigationController.initialize(),
      _countdownController.initialize(),
      _preRegisterController.initialize(),
    ]);
  }

  void updateScreenSize(double width, double height) {
    _responsiveService.updateScreenSize(width, height);
    notifyListeners();
  }

  // UI State management
  void setHoveredFeature(String? featureId) {
    if (_hoveredFeature != featureId) {
      _hoveredFeature = featureId;
      notifyListeners();
    }
  }

  void setHoveredTestimonial(String? testimonialId) {
    if (_hoveredTestimonial != testimonialId) {
      _hoveredTestimonial = testimonialId;
      notifyListeners();
    }
  }

  void setHoveredFAQ(String? faqId) {
    if (_hoveredFAQ != faqId) {
      _hoveredFAQ = faqId;
      notifyListeners();
    }
  }

  void setExpandedFAQ(String? faqId) {
    if (_expandedFAQ != faqId) {
      _expandedFAQ = faqId;
      notifyListeners();
    }
  }

  void setCurrentScreenshot(int index) {
    if (_currentScreenshotIndex != index) {
      _currentScreenshotIndex = index;
      notifyListeners();
    }
  }

  void nextScreenshot() {
    final maxIndex = promoContent?.screenshotsContent.screenshots.length ?? 0;
    if (_currentScreenshotIndex < maxIndex - 1) {
      _currentScreenshotIndex++;
      notifyListeners();
    }
  }

  void previousScreenshot() {
    if (_currentScreenshotIndex > 0) {
      _currentScreenshotIndex--;
      notifyListeners();
    }
  }

  void showPreRegisterDialog() {
    _showPreRegisterDialog = true;
    notifyListeners();
  }

  void hidePreRegisterDialog() {
    _showPreRegisterDialog = false;
    notifyListeners();
  }

  // Navigation delegates
  void scrollToSection(NavigationSection section) {
    _navigationController.scrollToSection(section);
  }

  // Service access
  ResponsiveService get responsiveService => _responsiveService;
  
  // Helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _navigationController.removeListener(_notifyListeners);
    _countdownController.removeListener(_notifyListeners);
    _preRegisterController.removeListener(_notifyListeners);
    
    _navigationController.dispose();
    _countdownController.dispose();
    _preRegisterController.dispose();
    
    super.dispose();
  }
}
