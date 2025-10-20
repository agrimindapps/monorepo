import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../services/admob_service.dart';

class AltBannerAd extends StatefulWidget {
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
  State<AltBannerAd> createState() => _AltBannerAdState();
}

class _AltBannerAdState extends State<AltBannerAd> {
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.center,
        child: Card(
          elevation: 0,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.maxWidth,
              maxHeight: widget.maxHeight,
            ),
            child: Obx(() {
              if (AdmobRepository().altBannerAdIsLoaded.value) {
                return Center(child: AdWidget(ad: AdmobRepository().altBannerAd!));
              } else {
                return const SizedBox();
              }
            }),
          ),
        ),
      );
}
