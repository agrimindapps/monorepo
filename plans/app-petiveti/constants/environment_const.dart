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
  static String altAdmobBanner = '';
  static String onOpenApp = '';
  static String admobPremiado = '';
  static List<String> keywordsAds = [
    'agricultura',
    'receituagro',
    'pragas',
    'plantas',
    'insetos',
    'doenças',
    'plantas invasoras'
  ];

  String siteApp = 'https://receituagro.agrimind.com.br';
  final String linkPoliticaPrivacidade =
      'https://agrimindapps.blogspot.com/2022/08/a-agrimind-apps-construiu-o-aplicativo.html';
  final String linkTermoUso = GetPlatform.isAndroid
      ? 'https://agrimindapps.blogspot.com/2022/08/receituagro-termos-e-condicoes.html'
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
      // Android Test
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
    'admobBanner-ios': 'ca-app-pub-9652140799368794/6084705043',
    'admobBanner-android': 'ca-app-pub-9652140799368794/6823071646',
    'onOpenApp-ios': 'ca-app-pub-9652140799368794/3499632393',
    'onOpenApp-android': 'ca-app-pub-9652140799368794/1517265642',
    'admobPremiado-ios': 'ca-app-pub-9652140799368794/3622108596',
    'admobPremiado-android': 'ca-app-pub-9652140799368794/3443613801',
    'altAdmobBanner-ios': 'ca-app-pub-9652140799368794/7399811311',
    'altAdmobBanner-android': 'ca-app-pub-9652140799368794/8840885493',
  };

  String supabaseUrl = 'https://fkjakafxqciukoesqvkp.supabase.co';
  String supabaseAnnoKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZramFrYWZ4cWNpdWtvZXNxdmtwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc0OTE5ODYsImV4cCI6MjA0MzA2Nzk4Nn0.f8O9na_WhlwGJsX1EXu8E6yu0MKJHsS7dSa0HO8Ic3M';
}
