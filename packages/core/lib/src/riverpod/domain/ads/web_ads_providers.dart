import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/ads/ad_sense_config_entity.dart';
import '../../../domain/repositories/i_web_ads_repository.dart';
import '../../../infrastructure/services/ads/web/adsense_stub_service.dart';

// ===== Web Ads Service Provider =====

/// Provider para o serviço de AdSense Web
/// 
/// Usa importação condicional para carregar a implementação correta:
/// - Web: AdSenseWebService (implementação real)
/// - Mobile: AdSenseStubService (stub que retorna erros)
/// 
/// Exemplo de uso:
/// ```dart
/// final webAdsRepo = ref.watch(webAdsRepositoryProvider);
/// await webAdsRepo.initialize(config: myConfig);
/// ```
final webAdsRepositoryProvider = Provider<IWebAdsRepository>((ref) {
  final service = AdSenseStubService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ===== Configuration Provider =====

/// Provider para configuração do AdSense
/// 
/// Deve ser sobrescrito no app com a configuração específica:
/// ```dart
/// ProviderScope(
///   overrides: [
///     adSenseConfigProvider.overrideWithValue(
///       AdSenseConfigEntity.production(
///         clientId: 'ca-pub-XXXXXXX',
///         adSlots: {'banner_top': '123456'},
///       ),
///     ),
///   ],
///   child: MyApp(),
/// )
/// ```
final adSenseConfigProvider = Provider<AdSenseConfigEntity?>((ref) {
  return null; // Deve ser sobrescrito pelo app
});

// ===== Initialization Provider =====

/// Provider que inicializa o AdSense com a configuração fornecida
/// 
/// Chama automaticamente initialize() quando há configuração disponível.
final webAdsInitializerProvider = FutureProvider<bool>((ref) async {
  final config = ref.watch(adSenseConfigProvider);
  if (config == null) {
    return false;
  }

  final repository = ref.read(webAdsRepositoryProvider);
  final result = await repository.initialize(config: config);

  return result.fold(
    (failure) => false,
    (_) => true,
  );
});

// ===== State Providers =====

/// Provider para verificar se deve mostrar anúncios web
/// 
/// Integra com status premium e outras verificações.
/// 
/// [placement] - Identificador do local do anúncio
final shouldShowWebAdsProvider = FutureProvider.family<bool, String>((
  ref,
  placement,
) async {
  // Aguarda inicialização
  final isInitialized = await ref.watch(webAdsInitializerProvider.future);
  if (!isInitialized) {
    return false;
  }

  final repository = ref.watch(webAdsRepositoryProvider);
  final result = await repository.shouldShowAd(placement: placement);

  return result.fold(
    (failure) => false,
    (canShow) => canShow,
  );
});

/// Notifier para gerenciar status premium
class WebAdsPremiumNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setPremium(bool value) {
    state = value;
    // Sincroniza com o repositório
    ref.read(webAdsRepositoryProvider).setPremiumStatus(value);
  }
}

/// Provider para definir status premium do usuário
/// 
/// Quando o usuário é premium, anúncios não são exibidos.
/// 
/// Exemplo:
/// ```dart
/// ref.read(webAdsPremiumStatusProvider.notifier).setPremium(true);
/// ```
final webAdsPremiumStatusProvider =
    NotifierProvider<WebAdsPremiumNotifier, bool>(() {
  return WebAdsPremiumNotifier();
});

// ===== Ad Slot Providers =====

/// Provider para registrar um slot de anúncio
/// 
/// Retorna o viewId do elemento registrado para uso com HtmlElementView.
/// 
/// Exemplo:
/// ```dart
/// final result = await ref.read(registerAdSlotProvider({
///   'slotName': 'banner_top',
///   'adSlot': '1234567890',
/// }).future);
/// ```
final registerAdSlotProvider =
    FutureProvider.family<String?, Map<String, dynamic>>((
  ref,
  params,
) async {
  final isInitialized = await ref.watch(webAdsInitializerProvider.future);
  if (!isInitialized) {
    return null;
  }

  final repository = ref.read(webAdsRepositoryProvider);

  final slotName = params['slotName'] as String;
  final adSlot = params['adSlot'] as String;
  final format = params['format'] as AdSenseFormat? ?? AdSenseFormat.auto;
  final fullWidthResponsive = params['fullWidthResponsive'] as bool? ?? true;
  final size = params['size'] as AdSenseSize?;

  final result = await repository.registerAdSlot(
    slotName: slotName,
    adSlot: adSlot,
    format: format,
    fullWidthResponsive: fullWidthResponsive,
    size: size,
  );

  return result.fold(
    (failure) => null,
    (viewId) => viewId,
  );
});

// ===== Analytics Providers =====

/// Provider para rastrear impressões de anúncios
final recordWebAdImpressionProvider =
    FutureProvider.family<void, String>((ref, placement) async {
  final repository = ref.read(webAdsRepositoryProvider);
  await repository.recordAdShown(placement: placement);
});

/// Provider para rastrear cliques em anúncios
final recordWebAdClickProvider =
    FutureProvider.family<void, String>((ref, placement) async {
  final repository = ref.read(webAdsRepositoryProvider);
  await repository.recordAdClicked(placement: placement);
});
