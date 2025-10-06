import 'package:core/core.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/interfaces/usecase.dart' as local;
import '../../domain/entities/promo_content.dart';
import '../../domain/usecases/get_promo_content.dart';
import '../../domain/usecases/submit_pre_registration.dart';
import '../../domain/usecases/track_analytics.dart';
import '../states/promo_state.dart';
final getPromoContentProvider = Provider<GetPromoContent>((ref) => di.getIt<GetPromoContent>());
final submitPreRegistrationProvider = Provider<SubmitPreRegistration>((ref) => di.getIt<SubmitPreRegistration>());
final trackAnalyticsProvider = Provider<TrackAnalytics>((ref) => di.getIt<TrackAnalytics>());
final promoProvider = StateNotifierProvider<PromoNotifier, PromoState>((ref) {
  return PromoNotifier(
    ref.read(getPromoContentProvider),
    ref.read(submitPreRegistrationProvider),
    ref.read(trackAnalyticsProvider),
  );
});

class PromoNotifier extends StateNotifier<PromoState> {
  final GetPromoContent _getPromoContent;
  final SubmitPreRegistration _submitPreRegistration;
  final TrackAnalytics _trackAnalytics;

  PromoNotifier(
    this._getPromoContent,
    this._submitPreRegistration,
    this._trackAnalytics,
  ) : super(const PromoState.initial());

  /// Carrega o conteúdo promocional
  Future<void> loadPromoContent() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getPromoContent(const local.NoParams());
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (promoContent) => state = state.copyWith(
        isLoading: false,
        promoContent: promoContent,
        error: null,
      ),
    );
  }

  /// Submete pré-cadastro
  Future<void> submitPreRegistration(String email) async {
    if (state.isSubmittingPreRegistration) return;

    state = state.copyWith(isSubmittingPreRegistration: true, preRegistrationError: null);

    final result = await _submitPreRegistration(email);
    
    result.fold(
      (failure) => state = state.copyWith(
        isSubmittingPreRegistration: false,
        preRegistrationError: failure.message,
      ),
      (_) => state = state.copyWith(
        isSubmittingPreRegistration: false,
        preRegistrationSuccess: true,
        preRegistrationError: null,
      ),
    );
  }

  /// Expande/colapsa uma FAQ
  void toggleFAQ(String faqId) {
    final currentContent = state.promoContent;
    if (currentContent == null) return;

    final updatedFaqs = currentContent.faqs.map((faq) {
      if (faq.id == faqId) {
        return faq.copyWith(isExpanded: !faq.isExpanded);
      }
      return faq;
    }).toList();

    final updatedContent = PromoContent(
      appName: currentContent.appName,
      appVersion: currentContent.appVersion,
      appDescription: currentContent.appDescription,
      appTagline: currentContent.appTagline,
      features: currentContent.features,
      testimonials: currentContent.testimonials,
      faqs: updatedFaqs,
      screenshots: currentContent.screenshots,
      launchInfo: currentContent.launchInfo,
      contactInfo: currentContent.contactInfo,
    );

    state = state.copyWith(promoContent: updatedContent);
  }

  /// Altera o screenshot atual
  void changeScreenshot(int index) {
    state = state.copyWith(currentScreenshotIndex: index);
  }

  /// Mostra/esconde o diálogo de pré-cadastro
  void togglePreRegistrationDialog() {
    state = state.copyWith(
      showPreRegistrationDialog: !state.showPreRegistrationDialog,
      preRegistrationSuccess: false,
      preRegistrationError: null,
    );
  }

  /// Registra evento de analytics
  Future<void> trackEvent(String event, {Map<String, dynamic>? parameters}) async {
    await _trackAnalytics(TrackAnalyticsParams(
      event: event,
      parameters: parameters ?? {},
    ));
  }

  /// Limpa mensagens de erro/sucesso
  void clearMessages() {
    state = state.copyWith(
      error: null,
      preRegistrationError: null,
      preRegistrationSuccess: false,
    );
  }
}
