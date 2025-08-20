// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/services/info_device_service.dart';

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
    'plantas invasoras'
  ];

  String linkLojaApple = 'https://apps.apple.com/br/app/nutrituti/id967092996';
  String linkLojaGoogle =
      'https://play.google.com/store/apps/details?id=br.com.agrimind.tabelanutricional&hl=pt_BR';

  String siteApp = 'https://nutrituti.agrimind.com.br';
  final String linkPoliticaPrivacidade =
      'https://agrimindapps.blogspot.com/2022/08/nutrituti-politica-de-privacidade.html';
  final String linkTermoUso = GetPlatform.isAndroid
      ? 'https://agrimindapps.blogspot.com/2022/08/nutrituti-termos-e-condicoes.html'
      : 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

  void initialize() {
    if (InfoDeviceService().isProduction.value) {
      admobBanner = GetPlatform.isAndroid
          ? prod['admobBanner-android']
          : prod['admobBanner-ios'];
      onOpenApp = GetPlatform.isAndroid
          ? prod['onOpenApp-android']
          : prod['onOpenApp-ios'];
      admobPremiado = GetPlatform.isAndroid
          ? prod['admobPremiado-android']
          : prod['admobPremiado-ios'];
      altAdmobBanner = GetPlatform.isAndroid
          ? prod['altAdmobBanner-android']
          : prod['altAdmobBanner-ios'];
    } else {
      // Homologação
      admobBanner = GetPlatform.isAndroid
          ? hml['admobBanner-android']
          : hml['admobBanner-ios'];
      onOpenApp = GetPlatform.isAndroid
          ? hml['onOpenApp-android']
          : hml['onOpenApp-ios'];
      admobPremiado = GetPlatform.isAndroid
          ? hml['admobPremiado-android']
          : hml['admobPremiado-ios'];
      altAdmobBanner = GetPlatform.isAndroid
          ? hml['altAdmobBanner-android']
          : hml['altAdmobBanner-ios'];
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
