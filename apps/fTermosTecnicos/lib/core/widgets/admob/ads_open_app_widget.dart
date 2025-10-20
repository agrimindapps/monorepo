import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../services/admob_service.dart';

class OpenAppAd extends ConsumerStatefulWidget {
  const OpenAppAd({super.key, required this.navigatorKey});
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  ConsumerState<OpenAppAd> createState() => _OpenAppAdState();
}

class _OpenAppAdState extends ConsumerState<OpenAppAd> {
  int _timeToClose = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final openAdsActive = ref.read(openAdsActiveProvider);
      if (_timeToClose == 0 || !openAdsActive) {
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();

    final openAdsActive = ref.watch(openAdsActiveProvider);
    final ad = ref.watch(onOpenAppAdProvider);
    final isLoaded = ref.watch(onOpenAppAdIsLoadedProvider);

    return openAdsActive
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
                                  ref.read(adMobServiceProvider.notifier).setOpenAdsActive(false);
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
                            top: (!kIsWeb && Platform.isAndroid)
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
                                                ref.read(adMobServiceProvider.notifier).setOpenAdsActive(false);
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
                                              child: isLoaded && ad != null
                                                  ? Center(child: AdWidget(ad: ad))
                                                  : const SizedBox.shrink(),
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
  }
}
