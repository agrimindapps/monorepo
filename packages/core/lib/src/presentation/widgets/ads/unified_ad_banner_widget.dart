import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../domain/entities/ads/ad_sense_config_entity.dart';
import '../../../riverpod/domain/ads/ads_providers.dart';

/// Widget unificado de anúncios que seleciona automaticamente entre:
/// - **Web**: AdSense (via HtmlElementView) - use [WebAdSenseBannerWidget]
/// - **Mobile**: Google Mobile Ads (AdMob) - usa este widget internamente
/// 
/// Este widget é focado em MOBILE. Para Web, importe diretamente os widgets
/// de AdSense do pacote web/adsense_banner_widget.dart.
/// 
/// Exemplo de uso em app multiplataforma:
/// ```dart
/// // No widget
/// if (kIsWeb) {
///   // Importe e use AdSenseBannerWidget do pacote web
///   return AdSenseBannerWidget(...);
/// } else {
///   return UnifiedAdBannerWidget(
///     mobileConfig: MobileAdConfig.banner(adUnitId: 'ca-app-pub-xxx/yyy'),
///   );
/// }
/// ```
class UnifiedAdBannerWidget extends ConsumerStatefulWidget {
  /// Configuração para Mobile (AdMob)
  final MobileAdConfig? mobileConfig;

  /// Altura do banner (usado em web ou placeholder)
  final double height;

  /// Largura do banner (default: infinito)
  final double? width;

  /// Callback quando o anúncio carrega
  final VoidCallback? onAdLoaded;

  /// Callback quando falha
  final void Function(String error)? onAdFailed;

  /// Widget placeholder durante carregamento
  final Widget? placeholder;

  /// Widget mostrado em caso de erro
  final Widget? errorWidget;

  const UnifiedAdBannerWidget({
    super.key,
    this.mobileConfig,
    this.height = 100,
    this.width,
    this.onAdLoaded,
    this.onAdFailed,
    this.placeholder,
    this.errorWidget,
  });

  @override
  ConsumerState<UnifiedAdBannerWidget> createState() =>
      _UnifiedAdBannerWidgetState();
}

class _UnifiedAdBannerWidgetState extends ConsumerState<UnifiedAdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Só carrega em mobile, web usa AdSense via widget separado
    if (!kIsWeb) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    final config = widget.mobileConfig;
    if (config == null) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    // Verifica se deve mostrar ads
    final shouldShow = await ref.read(shouldShowAdsProvider('banner').future);

    if (!mounted) return;

    if (!shouldShow) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    final repository = ref.read(adsRepositoryProvider);
    final result = await repository.loadBannerAd(
      adUnitId: config.adUnitId,
      size: config.size,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        widget.onAdFailed?.call(failure.message);
      },
      (ad) {
        setState(() {
          _bannerAd = ad;
          _isLoading = false;
        });
        widget.onAdLoaded?.call();
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Em web, retorna placeholder ou erro - use AdSenseBannerWidget
    if (kIsWeb) {
      return widget.errorWidget ??
          SizedBox(
            height: widget.height,
            width: widget.width ?? double.infinity,
            child: const Center(
              child: Text(
                'Use AdSenseBannerWidget para Web',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
    }

    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        width: widget.width ?? double.infinity,
        child: widget.placeholder ?? _buildDefaultPlaceholder(),
      );
    }

    if (_hasError || _bannerAd == null) {
      return widget.errorWidget ?? const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

/// Configuração para anúncios Web (AdSense)
/// Use com os widgets em web/adsense_banner_widget.dart
class WebAdConfig {
  /// Nome/identificador único do slot
  final String slotName;

  /// ID do ad slot no AdSense
  final String adSlot;

  /// Formato do anúncio
  final AdSenseFormat format;

  /// Se deve ser responsivo à largura total
  final bool fullWidthResponsive;

  /// Tamanho específico (opcional)
  final AdSenseSize? size;

  const WebAdConfig({
    required this.slotName,
    required this.adSlot,
    this.format = AdSenseFormat.auto,
    this.fullWidthResponsive = true,
    this.size,
  });
}

/// Configuração para anúncios Mobile (AdMob)
class MobileAdConfig {
  /// ID da unidade de anúncio no AdMob
  final String adUnitId;

  /// Tamanho do banner
  final AdSize size;

  const MobileAdConfig({
    required this.adUnitId,
    this.size = AdSize.banner,
  });

  /// Cria configuração para banner padrão
  factory MobileAdConfig.banner({required String adUnitId}) {
    return MobileAdConfig(adUnitId: adUnitId, size: AdSize.banner);
  }

  /// Cria configuração para banner largo
  factory MobileAdConfig.largeBanner({required String adUnitId}) {
    return MobileAdConfig(adUnitId: adUnitId, size: AdSize.largeBanner);
  }

  /// Cria configuração para retângulo médio
  factory MobileAdConfig.mediumRectangle({required String adUnitId}) {
    return MobileAdConfig(adUnitId: adUnitId, size: AdSize.mediumRectangle);
  }

  /// Cria configuração para full banner
  factory MobileAdConfig.fullBanner({required String adUnitId}) {
    return MobileAdConfig(adUnitId: adUnitId, size: AdSize.fullBanner);
  }

  /// Cria configuração para leaderboard
  factory MobileAdConfig.leaderboard({required String adUnitId}) {
    return MobileAdConfig(adUnitId: adUnitId, size: AdSize.leaderboard);
  }
}

/// Widget adaptivo para mobile que ajusta ao tamanho da tela
/// 
/// Usa AdSize.getAnchoredAdaptiveBannerAdSize para obter
/// o melhor tamanho de banner para a orientação atual.
class AdaptiveMobileBannerWidget extends ConsumerStatefulWidget {
  /// ID da unidade de anúncio no AdMob
  final String adUnitId;

  /// Callback quando o anúncio carrega
  final VoidCallback? onAdLoaded;

  /// Callback quando falha
  final void Function(String error)? onAdFailed;

  /// Widget placeholder durante carregamento
  final Widget? placeholder;

  const AdaptiveMobileBannerWidget({
    super.key,
    required this.adUnitId,
    this.onAdLoaded,
    this.onAdFailed,
    this.placeholder,
  });

  @override
  ConsumerState<AdaptiveMobileBannerWidget> createState() =>
      _AdaptiveMobileBannerWidgetState();
}

class _AdaptiveMobileBannerWidgetState
    extends ConsumerState<AdaptiveMobileBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAd();
      });
    }
  }

  Future<void> _loadAd() async {
    final shouldShow = await ref.read(shouldShowAdsProvider('banner').future);

    if (!mounted) return;

    if (!shouldShow) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    // Obtém tamanho adaptivo
    final width = MediaQuery.of(context).size.width.toInt();
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );

    if (!mounted) return;

    if (size == null) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    final repository = ref.read(adsRepositoryProvider);
    final result = await repository.loadBannerAd(
      adUnitId: widget.adUnitId,
      size: size,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        widget.onAdFailed?.call(failure.message);
      },
      (ad) {
        setState(() {
          _bannerAd = ad;
          _isLoading = false;
        });
        widget.onAdLoaded?.call();
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return widget.placeholder ?? _buildDefaultPlaceholder();
    }

    if (_hasError || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      height: 60,
      color: Colors.grey[200],
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
