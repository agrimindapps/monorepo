import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../services/admob_service.dart';

class AltBannerAd extends ConsumerWidget {
  const AltBannerAd({
    super.key,
    required this.admobId,
    required this.keywords,
    this.maxWidth = double.infinity,
    this.maxHeight = 90,
  });

  final String admobId;
  final List<String> keywords;
  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ad = ref.watch(altBannerAdProvider);
    final isLoaded = ref.watch(altBannerAdIsLoadedProvider);

    return Align(
      alignment: Alignment.center,
      child: Card(
        elevation: 0,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ),
          child: isLoaded && ad != null
              ? Center(child: AdWidget(ad: ad))
              : const SizedBox(),
        ),
      ),
    );
  }
}
