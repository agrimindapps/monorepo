import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../intermediate.dart';
import '../services/admob_service.dart';
import '../services/in_app_purchase_service.dart';
import 'admob/ads_altbanner_widget.dart';
import 'admob/ads_banner_widget.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({super.key, required this.navigatorKey});
  final GlobalKey<NavigatorState> navigatorKey;
  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void marcaItemSelecionado(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _altBanner(),
        BottomNavigationBar(
          elevation: 0,
          items: <BottomNavigationBarItem>[
            for (var item in GlobalEnvironment().itensMenuBottom)
              BottomNavigationBarItem(
                icon: Icon(item['icon']),
                label: item['label'],
              ),
          ],
          currentIndex: _selectedIndex,
          enableFeedback: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          onTap: (index) {
            marcaItemSelecionado(index);
            widget.navigatorKey.currentState!.pushReplacementNamed(
                GlobalEnvironment().itensMenuBottom[index]['page']);
          },
        ),
      ],
    );
  }

  Widget _altBanner() {
    if (GetPlatform.isWeb) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      if (AdmobRepository().isPremiumAd.value ||
          InAppPurchaseService().isPremium.value) {
        return const SizedBox.shrink();
      }

      if (MediaQuery.of(context).size.height < 750) {
        return AdBanner(admobId: GlobalEnvironment().admobBanner);
      } else {
        return AltBannerAd(
          admobId: GlobalEnvironment().altAdmobBanner,
          keywords: GlobalEnvironment().keywordsAds,
          maxHeight: 95,
        );
      }
    });
  }
}
