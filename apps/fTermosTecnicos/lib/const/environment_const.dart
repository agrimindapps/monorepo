import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:core/core.dart';

class GlobalEnvironment {
  static bool _isProduction = false;

  static bool get isProduction => _isProduction;

  static Future<void> initialize() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final patchVersion = int.parse(packageInfo.version.split('.')[2]);
    _isProduction = patchVersion > 0;
  }
}

class Environment {
  static final Environment _singleton = Environment._internal();

  factory Environment() {
    return _singleton;
  }

  Environment._internal();

  static String admobBanner = '';
  static String onOpenApp = '';
  static String admobPremiado = '';
  static String altAdmobBanner = '';
  static List<String> keywordsAds = [
    'agricultura',
    'receituagro',
    'pragas',
    'plantas',
    'insetos',
    'doenças',
    'plantas invasoras',
  ];

  String linkLojaApple = 'https://apps.apple.com/br/app/nutrituti/id967092996';
  String linkLojaGoogle =
      'https://play.google.com/store/apps/details?id=br.com.agrimind.tabelanutricional&hl=pt_BR';

  String siteApp = 'https://agrimind.com.br';
  final String linkPoliticaPrivacidade =
      'https://agrimindapps.blogspot.com/2022/08/termos-tecnicos-politica-de-privacidade.html';
  final String linkTermoUso = Platform.isAndroid
      ? 'https://agrimindapps.blogspot.com/2022/08/termos-tecnicos-termos-e-condicoes.html'
      : 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

  void initialize() {
    if (!kIsWeb) {
      if (GlobalEnvironment.isProduction) {
        admobBanner = Platform.isAndroid
            ? prod['admobBanner-android']
            : prod['admobBanner-ios'];
        onOpenApp = Platform.isAndroid
            ? prod['onOpenApp-android']
            : prod['onOpenApp-ios'];
        admobPremiado = Platform.isAndroid
            ? prod['admobPremiado-android']
            : prod['admobPremiado-ios'];
        altAdmobBanner = Platform.isAndroid
            ? prod['altAdmobBanner-android']
            : prod['altAdmobBanner-ios'];
      } else {
        // Homologação
        admobBanner = Platform.isAndroid
            ? hml['admobBanner-android']
            : hml['admobBanner-ios'];
        onOpenApp = Platform.isAndroid
            ? hml['onOpenApp-android']
            : hml['onOpenApp-ios'];
        admobPremiado = Platform.isAndroid
            ? hml['admobPremiado-android']
            : hml['admobPremiado-ios'];
        altAdmobBanner = Platform.isAndroid
            ? hml['altAdmobBanner-android']
            : hml['altAdmobBanner-ios'];
      }
    }
  }

  Map<String, dynamic> hml = {
    'admobBanner-ios': 'ca-app-pub-3940256099942544/6300978111',
    'admobBanner-android': 'ca-app-pub-3940256099942544/2934735716',
    'onOpenApp-ios': 'ca-app-pub-3940256099942544/2521693316',
    'onOpenApp-android': 'ca-app-pub-3940256099942544/2247696110',
    'admobPremiado-ios': 'ca-app-pub-3940256099942544/5224354917',
    'admobPremiado-android': 'ca-app-pub-3940256099942544/5224354917',
    'altAdmobBanner-ios': 'ca-app-pub-3940256099942544/2521693316',
    'altAdmobBanner-android': 'ca-app-pub-3940256099942544/2247696110',
  };

  Map<String, dynamic> prod = {
    'admobBanner-ios': 'ca-app-pub-9652140799368794/9894253861',
    'admobBanner-android': 'ca-app-pub-9652140799368794/5464054264',
    'onOpenApp-ios': 'ca-app-pub-9652140799368794/9427201715',
    'onOpenApp-android': 'ca-app-pub-9652140799368794/3600159960',
    'admobPremiado-ios': 'ca-app-pub-9652140799368794/4406305710',
    'admobPremiado-android': 'ca-app-pub-9652140799368794/2749162000',
    'altAdmobBanner-android': 'ca-app-pub-9652140799368794/9472801697',
    'altAdmobBanner-ios': 'ca-app-pub-9652140799368794/5533556686',
  };

  String supabaseUrl = 'https://fkjakafxqciukoesqvkp.supabase.co';
  String supabaseAnnoKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZramFrYWZ4cWNpdWtvZXNxdmtwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc0OTE5ODYsImV4cCI6MjA0MzA2Nzk4Nn0.f8O9na_WhlwGJsX1EXu8E6yu0MKJHsS7dSa0HO8Ic3M';

  /// Whether external links are enabled in this environment
  static const bool hasExternalLinks = true;
}
