import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key, required this.admobId});

  final String admobId;

  @override
  State<AdBanner> createState() => AdBannerState();
}

class AdBannerState extends State<AdBanner> {
  late BannerAd _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  @override
  dispose() {
    super.dispose();
    _anchoredAdaptiveAd.dispose();
  }

  Future<void> _loadAd() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      // print('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: widget.admobId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          // print('$ad loaded: ${ad.responseInfo}');
          setState(() {
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // print('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        if (_isLoaded)
          Container(
            color: Colors.black,
            width: _anchoredAdaptiveAd.size.width.toDouble(),
            height: _anchoredAdaptiveAd.size.height.toDouble() * 1.3,
            child: AdWidget(ad: _anchoredAdaptiveAd),
          )
        else
          const SizedBox.shrink()
      ],
    );
  }
}
