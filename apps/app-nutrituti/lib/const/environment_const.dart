// Dart imports:
import 'dart:io' show Platform;

// Project imports:
import '../../core/services/info_device_service.dart';

class AppEnvironment {
  static final AppEnvironment _singleton = AppEnvironment._internal();

  factory AppEnvironment() {
    return _singleton;
  }

  AppEnvironment._internal();

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
    'plantas invasoras'
  ];

  String linkLojaApple = 'https://apps.apple.com/br/app/nutrituti/id967092996';
  String linkLojaGoogle =
      'https://play.google.com/store/apps/details?id=br.com.agrimind.tabelanutricional&hl=pt_BR';

  String siteApp = 'https://nutrituti.agrimind.com.br';
  final String linkPoliticaPrivacidade =
      'https://agrimindapps.blogspot.com/2022/08/nutrituti-politica-de-privacidade.html';
  final String linkTermoUso = Platform.isAndroid
      ? 'https://agrimindapps.blogspot.com/2022/08/nutrituti-termos-e-condicoes.html'
      : 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

  void initialize() {
    if (InfoDeviceService().isProduction.value) {
      admobBanner = Platform.isAndroid
          ? prod['admobBanner-android'] as String
          : prod['admobBanner-ios'] as String;
      onOpenApp = Platform.isAndroid
          ? prod['onOpenApp-android'] as String
          : prod['onOpenApp-ios'] as String;
      admobPremiado = Platform.isAndroid
          ? prod['admobPremiado-android'] as String
          : prod['admobPremiado-ios'] as String;
      altAdmobBanner = Platform.isAndroid
          ? prod['altAdmobBanner-android'] as String
          : prod['altAdmobBanner-ios'] as String;
    } else {
      // Homologação
      admobBanner = Platform.isAndroid
          ? hml['admobBanner-android'] as String
          : hml['admobBanner-ios'] as String;
      onOpenApp = Platform.isAndroid
          ? hml['onOpenApp-android'] as String
          : hml['onOpenApp-ios'] as String;
      admobPremiado = Platform.isAndroid
          ? hml['admobPremiado-android'] as String
          : hml['admobPremiado-ios'] as String;
      altAdmobBanner = Platform.isAndroid
          ? hml['altAdmobBanner-android'] as String
          : hml['altAdmobBanner-ios'] as String;
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
    'admobBanner-android': 'ca-app-pub-9652140799368794/3101505064',
    'admobBanner-ios': 'ca-app-pub-9652140799368794/9008437865',
    'onOpenApp-android': 'ca-app-pub-9652140799368794/2011229201',
    'onOpenApp-ios': 'ca-app-pub-9652140799368794/1432644706',
    'admobPremiado-android': 'ca-app-pub-9652140799368794/4406940178',
    'admobPremiado-ios': 'ca-app-pub-9652140799368794/9658632394',
    'altAdmobBanner-android': 'ca-app-pub-9652140799368794/7129423974',
    'altAdmobBanner-ios': 'ca-app-pub-9652140799368794/7458293700',
  };

  String supabaseUrl = 'https://fkjakafxqciukoesqvkp.supabase.co';
  String supabaseAnnoKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZramFrYWZ4cWNpdWtvZXNxdmtwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc0OTE5ODYsImV4cCI6MjA0MzA2Nzk4Nn0.f8O9na_WhlwGJsX1EXu8E6yu0MKJHsS7dSa0HO8Ic3M';
}
