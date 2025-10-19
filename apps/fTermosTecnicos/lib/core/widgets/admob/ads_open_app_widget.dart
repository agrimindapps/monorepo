import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../services/admob_service.dart';

class OpenAppAd extends StatefulWidget {
  const OpenAppAd({super.key, required this.navigatorKey});
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<OpenAppAd> createState() => _OpenAppAdState();
}

class _OpenAppAdState extends State<OpenAppAd> {
  int _timeToClose = 5;
  Timer? _timer;

  @override
  initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeToClose == 0 || !AdmobRepository().openAdsActive.value) {
        setState(() {
          _timer?.cancel();
        });
      } else {
        setState(() {
          _timeToClose--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (GetPlatform.isWeb) return const SizedBox.shrink();

    return Obx(
      () {
        return AdmobRepository().openAdsActive.value
            ? Container(
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 50, 10, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (_timeToClose == 0) {
                                  AdmobRepository().setOpenAdsActive(false);
                                }
                              },
                              child: _timeToClose == 0
                                  ? const Text('Ir para o app >> ')
                                  : Text('Fechar em $_timeToClose'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: GetPlatform.isAndroid
                                ? MediaQuery.of(context).size.height * 0.125
                                : MediaQuery.of(context).size.height * 0.05),
                        child: Center(
                          child: Card(
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 390,
                                width: 340,
                                color: Theme.of(context).cardColor,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 0, 10, 5),
                                            child: Container(
                                              width: 120,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade500,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Center(
                                                child: Text('Publicidade',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 0, 0, 5),
                                            child: GestureDetector(
                                              onTap: () async {
                                                AdmobRepository()
                                                    .setOpenAdsActive(false);
                                                widget
                                                    .navigatorKey.currentState!
                                                    .pushNamed('/config');
                                              },
                                              child: Container(
                                                width: 120,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade500,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Center(
                                                  child: Text('x Remover',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Center(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Card(
                                            elevation: 0,
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 380,
                                                maxHeight:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.7,
                                              ),
                                              child: Obx(() {
                                                if (AdmobRepository()
                                                    .onOpenAppAdIsLoaded
                                                    .value) {
                                                  return Center(
                                                      child: AdWidget(
                                                          ad: AdmobRepository()
                                                              .onOpenAppAd!));
                                                } else {
                                                  return const SizedBox
                                                      .shrink();
                                                }
                                              }),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}
