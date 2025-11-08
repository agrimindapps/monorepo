import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../riverpod/domain/ads/ads_providers.dart';

/// Widget to display banner ads
/// Automatically loads and manages banner ad lifecycle
class AdBannerWidget extends ConsumerStatefulWidget {
  final String adUnitId;
  final AdSize size;
  final VoidCallback? onAdLoaded;
  final void Function(Ad, LoadAdError)? onAdFailedToLoad;

  const AdBannerWidget({
    super.key,
    required this.adUnitId,
    this.size = AdSize.banner,
    this.onAdLoaded,
    this.onAdFailedToLoad,
  });

  @override
  ConsumerState<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends ConsumerState<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    // Check if should show ads (premium status)
    final shouldShow = await ref.read(shouldShowAdsProvider('banner').future);

    if (!shouldShow) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    final repository = ref.read(adsRepositoryProvider);
    final result = await repository.loadBannerAd(
      adUnitId: widget.adUnitId,
      size: widget.size,
    );

    result.fold(
      (failure) {
        setState(() {
          _hasError = true;
        });
        widget.onAdFailedToLoad?.call(
          _bannerAd ??
              BannerAd(
                adUnitId: widget.adUnitId,
                size: widget.size,
                request: const AdRequest(),
                listener: BannerAdListener(),
              ),
          LoadAdError(0, 'domain', failure.message, null),
        );
      },
      (ad) {
        if (mounted) {
          setState(() {
            _bannerAd = ad;
            _isLoaded = true;
          });
          widget.onAdLoaded?.call();
        }
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
    if (_hasError || !_isLoaded) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

/// Adaptive banner widget that adjusts to screen width
class AdaptiveBannerWidget extends ConsumerStatefulWidget {
  final String adUnitId;
  final VoidCallback? onAdLoaded;
  final void Function(Ad, LoadAdError)? onAdFailedToLoad;

  const AdaptiveBannerWidget({
    super.key,
    required this.adUnitId,
    this.onAdLoaded,
    this.onAdFailedToLoad,
  });

  @override
  ConsumerState<AdaptiveBannerWidget> createState() =>
      _AdaptiveBannerWidgetState();
}

class _AdaptiveBannerWidgetState extends ConsumerState<AdaptiveBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAd();
    });
  }

  Future<void> _loadAd() async {
    // Check if should show ads
    final shouldShow = await ref.read(shouldShowAdsProvider('banner').future);

    if (!shouldShow) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    // Get screen width
    final width = MediaQuery.of(context).size.width.toInt();

    // Get adaptive banner size
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );

    if (size == null) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    final repository = ref.read(adsRepositoryProvider);
    final result = await repository.loadBannerAd(
      adUnitId: widget.adUnitId,
      size: size,
    );

    result.fold(
      (failure) {
        setState(() {
          _hasError = true;
        });
      },
      (ad) {
        if (mounted) {
          setState(() {
            _bannerAd = ad;
            _isLoaded = true;
          });
          widget.onAdLoaded?.call();
        }
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
    if (_hasError || !_isLoaded) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
