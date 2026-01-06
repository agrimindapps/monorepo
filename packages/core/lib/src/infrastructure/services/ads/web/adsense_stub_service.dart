import 'package:dartz/dartz.dart';

import '../../../../domain/entities/ads/ad_sense_config_entity.dart';
import '../../../../domain/repositories/i_web_ads_repository.dart';
import '../../../../shared/utils/failure.dart';

/// Stub do AdSense Service para plataformas não-web (iOS, Android)
/// 
/// Este stub é usado quando a aplicação roda em mobile.
/// Todos os métodos retornam erros indicando que AdSense não é suportado.
/// 
/// Use Google Mobile Ads (AdMob) em vez de AdSense para mobile.
class AdSenseStubService implements IWebAdsRepository {
  bool _isPremium = false;

  @override
  bool get isInitialized => false;

  @override
  bool get isPremium => _isPremium;

  @override
  Future<Either<Failure, void>> initialize({
    required AdSenseConfigEntity config,
  }) async {
    return const Left(
      CacheFailure(
        'AdSense não é suportado em plataformas mobile. '
        'Use Google Mobile Ads (AdMob) para iOS/Android.',
        code: 'ADSENSE_NOT_SUPPORTED',
      ),
    );
  }

  @override
  Future<Either<Failure, String>> registerAdSlot({
    required String slotName,
    required String adSlot,
    AdSenseFormat format = AdSenseFormat.auto,
    bool fullWidthResponsive = true,
    AdSenseSize? size,
  }) async {
    return const Left(
      CacheFailure(
        'AdSense não é suportado em plataformas mobile.',
        code: 'ADSENSE_NOT_SUPPORTED',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> unregisterAdSlot({
    required String slotName,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> refreshAd({required String slotName}) async {
    return const Left(
      CacheFailure(
        'AdSense não é suportado em plataformas mobile.',
        code: 'ADSENSE_NOT_SUPPORTED',
      ),
    );
  }

  @override
  Future<Either<Failure, bool>> shouldShowAd({
    required String placement,
  }) async {
    // Retorna false pois AdSense não funciona em mobile
    return const Right(false);
  }

  @override
  void setPremiumStatus(bool isPremium) {
    _isPremium = isPremium;
  }

  @override
  Future<Either<Failure, void>> recordAdShown({
    required String placement,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> recordAdClicked({
    required String placement,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    return const Right(null);
  }
}
