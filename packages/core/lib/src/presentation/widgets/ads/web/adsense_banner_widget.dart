import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/ads/ad_sense_config_entity.dart';
import '../../../../riverpod/domain/ads/web_ads_providers.dart';

/// Widget de banner AdSense para Flutter Web
/// 
/// Automaticamente carrega e gerencia o ciclo de vida do banner AdSense.
/// Usa HtmlElementView internamente para renderizar o anúncio HTML.
/// 
/// IMPORTANTE: Este widget só funciona em Flutter Web!
/// Para mobile, use [AdBannerWidget] com Google Mobile Ads.
/// 
/// Exemplo de uso:
/// ```dart
/// AdSenseBannerWidget(
///   slotName: 'banner_top',
///   adSlot: '1234567890',
///   height: 100,
///   onAdLoaded: () => print('Ad loaded'),
/// )
/// ```
class AdSenseBannerWidget extends ConsumerStatefulWidget {
  /// Nome/identificador único do slot
  final String slotName;

  /// ID do ad slot no AdSense
  final String adSlot;

  /// Altura do container do anúncio
  final double height;

  /// Largura do container (default: infinito)
  final double? width;

  /// Formato do anúncio
  final AdSenseFormat format;

  /// Se deve ser responsivo à largura total
  final bool fullWidthResponsive;

  /// Tamanho específico (opcional)
  final AdSenseSize? size;

  /// Callback quando o anúncio é carregado
  final VoidCallback? onAdLoaded;

  /// Callback quando falha o carregamento
  final void Function(String error)? onAdFailed;

  /// Widget placeholder enquanto carrega
  final Widget? placeholder;

  /// Widget mostrado quando há erro ou ad bloqueado
  final Widget? errorWidget;

  const AdSenseBannerWidget({
    super.key,
    required this.slotName,
    required this.adSlot,
    this.height = 100,
    this.width,
    this.format = AdSenseFormat.auto,
    this.fullWidthResponsive = true,
    this.size,
    this.onAdLoaded,
    this.onAdFailed,
    this.placeholder,
    this.errorWidget,
  });

  @override
  ConsumerState<AdSenseBannerWidget> createState() =>
      _AdSenseBannerWidgetState();
}

class _AdSenseBannerWidgetState extends ConsumerState<AdSenseBannerWidget> {
  String? _viewId;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerAdSlot();
    });
  }

  Future<void> _registerAdSlot() async {
    // Verifica se deve mostrar ads
    final shouldShow = await ref.read(
      shouldShowWebAdsProvider(widget.slotName).future,
    );

    if (!mounted) return;

    if (!shouldShow) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    // Registra o slot
    final repository = ref.read(webAdsRepositoryProvider);
    final result = await repository.registerAdSlot(
      slotName: widget.slotName,
      adSlot: widget.adSlot,
      format: widget.format,
      fullWidthResponsive: widget.fullWidthResponsive,
      size: widget.size,
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
      (viewId) {
        setState(() {
          _viewId = viewId;
          _isLoading = false;
        });
        widget.onAdLoaded?.call();
        // Registra impressão
        repository.recordAdShown(placement: widget.slotName);
      },
    );
  }

  @override
  void dispose() {
    // Remove o slot quando o widget é destruído
    if (_viewId != null) {
      ref.read(webAdsRepositoryProvider).unregisterAdSlot(
            slotName: widget.slotName,
          );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        width: widget.width ?? double.infinity,
        child: widget.placeholder ?? _buildDefaultPlaceholder(),
      );
    }

    if (_hasError || _viewId == null) {
      return widget.errorWidget ?? const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.height,
      width: widget.width ?? double.infinity,
      child: HtmlElementView(viewType: _viewId!),
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

/// Widget de banner AdSense responsivo
/// 
/// Adapta automaticamente o tamanho baseado na largura da tela.
/// Recomendado para a maioria dos casos de uso.
class ResponsiveAdSenseBannerWidget extends ConsumerStatefulWidget {
  /// Nome/identificador único do slot
  final String slotName;

  /// ID do ad slot no AdSense
  final String adSlot;

  /// Callback quando o anúncio é carregado
  final VoidCallback? onAdLoaded;

  /// Callback quando falha o carregamento
  final void Function(String error)? onAdFailed;

  /// Widget placeholder enquanto carrega
  final Widget? placeholder;

  const ResponsiveAdSenseBannerWidget({
    super.key,
    required this.slotName,
    required this.adSlot,
    this.onAdLoaded,
    this.onAdFailed,
    this.placeholder,
  });

  @override
  ConsumerState<ResponsiveAdSenseBannerWidget> createState() =>
      _ResponsiveAdSenseBannerWidgetState();
}

class _ResponsiveAdSenseBannerWidgetState
    extends ConsumerState<ResponsiveAdSenseBannerWidget> {
  String? _viewId;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerAdSlot();
    });
  }

  Future<void> _registerAdSlot() async {
    final shouldShow = await ref.read(
      shouldShowWebAdsProvider(widget.slotName).future,
    );

    if (!mounted) return;

    if (!shouldShow) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    final repository = ref.read(webAdsRepositoryProvider);
    final result = await repository.registerAdSlot(
      slotName: widget.slotName,
      adSlot: widget.adSlot,
      format: AdSenseFormat.auto,
      fullWidthResponsive: true,
      size: AdSenseSize.responsive,
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
      (viewId) {
        setState(() {
          _viewId = viewId;
          _isLoading = false;
        });
        widget.onAdLoaded?.call();
        repository.recordAdShown(placement: widget.slotName);
      },
    );
  }

  @override
  void dispose() {
    if (_viewId != null) {
      ref.read(webAdsRepositoryProvider).unregisterAdSlot(
            slotName: widget.slotName,
          );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ?? _buildDefaultPlaceholder();
    }

    if (_hasError || _viewId == null) {
      return const SizedBox.shrink();
    }

    // Calcula altura baseado na largura da tela
    final screenWidth = MediaQuery.of(context).size.width;
    final height = _calculateResponsiveHeight(screenWidth);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: HtmlElementView(viewType: _viewId!),
    );
  }

  double _calculateResponsiveHeight(double screenWidth) {
    // Ajusta altura baseado em breakpoints comuns
    if (screenWidth >= 728) {
      return 90; // Leaderboard
    } else if (screenWidth >= 468) {
      return 60; // Full Banner
    } else if (screenWidth >= 320) {
      return 100; // Large Banner
    } else {
      return 50; // Standard Banner
    }
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      height: 90,
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

/// Widget In-Article para AdSense
/// 
/// Otimizado para ser inserido entre parágrafos de conteúdo.
class InArticleAdSenseWidget extends AdSenseBannerWidget {
  const InArticleAdSenseWidget({
    super.key,
    required super.slotName,
    required super.adSlot,
    super.onAdLoaded,
    super.onAdFailed,
  }) : super(
          height: 250,
          format: AdSenseFormat.inArticle,
          fullWidthResponsive: true,
        );
}

/// Widget In-Feed para AdSense
/// 
/// Otimizado para ser inserido em listagens/feeds.
class InFeedAdSenseWidget extends AdSenseBannerWidget {
  const InFeedAdSenseWidget({
    super.key,
    required super.slotName,
    required super.adSlot,
    super.height = 200,
    super.onAdLoaded,
    super.onAdFailed,
  }) : super(
          format: AdSenseFormat.inFeed,
          fullWidthResponsive: true,
        );
}
