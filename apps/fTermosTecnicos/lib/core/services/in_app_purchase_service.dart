import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../intermediate.dart';
import 'revenuecat_service.dart';

class InAppPurchaseService extends GetxController {
  static final InAppPurchaseService _singleton =
      InAppPurchaseService._internal();

  factory InAppPurchaseService() {
    return _singleton;
  }

  InAppPurchaseService._internal();

  Set<String> getProductsId() =>
      Set.from(GlobalEnvironment().inappProductIds.map((e) => e['productId']));
  Map<String, dynamic> getTermosUso() => GlobalEnvironment().inappTermosUso;
  List<Map<String, dynamic>> getVantagens() =>
      GlobalEnvironment().inappVantagens;

  RxBool isPremium = false.obs;
  RxBool interagindoLoja = false.obs;
  RxMap<String, dynamic> info = {
    'ativo': false,
    'percent': 0.0,
    'daysRemaning': '',
    'descAssinatura': '',
    'fimAssinatura': '',
    'inicioAssinatura': '',
  }.obs;

  Future<void> init() async {
    isPremium.value = await checkSignature();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  Future<void> launchPoliticaPrivacidade() async {
    await _launchUrl(GlobalEnvironment().linkPoliticaPrivacidade);
  }

  Future<void> launchTermoUso() async {
    await _launchUrl(GlobalEnvironment().linkTermoUso);
  }

  void setSignature(Map<String, dynamic> assinatura) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('signature', jsonEncode(assinatura));
  }

  Future<bool> deleteSignature() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('signature');
    return true;
  }

  Future<bool> deleteRevenuecatSignature() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('signature_revenuecat');
    return true;
  }

  Future<Map<String, dynamic>> detalhesSignature() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? assinatura = prefs.getString('signature');

    if (assinatura == null) {
      return {};
    }

    return jsonDecode(assinatura);
  }

  Future<bool> checkSignature() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? row = prefs.getString('signature');

    if (row == null) {
      if (await RevenuecatService.checkSignature()) {
        return true;
      } else {
        return false;
      }
    }

    final Map<String, dynamic> signature = jsonDecode(row);

    try {
      final plan = GlobalEnvironment()
          .inappProductIds
          .firstWhere((t) => t['productId'] == signature['productId']);
      final actualDate = DateTime.now().millisecondsSinceEpoch;
      final endDate =
          signature['purchaseTime'] + (plan['valueId'] * 1000) + 172800000;

      if (endDate > actualDate) {
        return true;
      } else {
        deleteSignature();
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> inAppLoadDataSignature() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('signature');
    String? dataRevenue = prefs.getString('signature_revenuecat');

    if (data != null) {
      try {
        Map<String, dynamic> signature = jsonDecode(data);

        final plan = GlobalEnvironment().inappProductIds.firstWhere(
              (t) => t['productId'] == signature['productId'],
              orElse: () => {},
            );

        final planDate = plan['valueId'] * 1000;
        final initDate = signature['purchaseTime'];
        final actualDate = DateTime.now().millisecondsSinceEpoch;
        final endDate = initDate + planDate;

        var percent = 1.0;
        var daysRemaning = 0;
        var daysRemaningDesc = '';
        var extendDate = false;

        if (actualDate < endDate) {
          final count1 = (actualDate - initDate) / 86400000;
          final count2 = (endDate - initDate) / 86400000;
          daysRemaning = (endDate - actualDate) ~/ 86400000;
          percent = 100 - ((count1 / count2) * 100);
        } else {
          if ((actualDate - 172800000) < endDate) {
            daysRemaning = (172800000 + (endDate - actualDate)) ~/ 86400000;
            extendDate = true;
          } else {
            deleteSignature();
          }
        }

        if (!extendDate) {
          daysRemaningDesc = '${1 + daysRemaning} Dias Restantes';
        } else {
          daysRemaningDesc =
              '${24 * daysRemaning} Horas Restantes (Tempo Extendido)';
        }

        final mostraDataAssinatura = DateFormat('dd/MM/yyyy')
            .format(DateTime.fromMillisecondsSinceEpoch(initDate));
        final mostraDataAssinaturaFinal = DateFormat('dd/MM/yyyy')
            .format(DateTime.fromMillisecondsSinceEpoch(endDate));

        info['inicioAssinatura'] = mostraDataAssinatura;
        info['fimAssinatura'] = mostraDataAssinaturaFinal;
        info['descAssinatura'] = '${plan['desc']}';
        info['daysRemaning'] = daysRemaningDesc;
        info['percent'] = percent;
        info['ativo'] = true;
      } catch (e) {
        debugPrint('Error checkSignature com assinatura antiga: $e');
        // deleteSignature();
      }

      info = info;
    } else if (dataRevenue != null) {
      Map<String, dynamic> signatureMap = jsonDecode(dataRevenue);
      CustomerInfo signature = CustomerInfo.fromJson(signatureMap);

      if (signature.entitlements.active.isNotEmpty) {
        String endDate = signature.entitlements
            .active[GlobalEnvironment().entitlementID]!.latestPurchaseDate;

        if (endDate.isNotEmpty) {
          // try {
          int dateNow = DateTime.now().millisecondsSinceEpoch;
          int dateEnd =
              DateTime.parse(endDate).millisecondsSinceEpoch + 172800000;
          if (dateNow < dateEnd) {
            final plan = GlobalEnvironment().inappProductIds.firstWhere(
                  (t) =>
                      t['productId'] ==
                      signature
                          .entitlements
                          .active[GlobalEnvironment().entitlementID]!
                          .productIdentifier,
                  orElse: () => {},
                );

            info['inicioAssinatura'] =
                DateFormat('dd/MM/yyyy').format(DateTime.parse(endDate));
            info['fimAssinatura'] = DateFormat('dd/MM/yyyy')
                .format(DateTime.fromMillisecondsSinceEpoch(dateEnd));
            info['descAssinatura'] = '${plan['desc']}';
            info['daysRemaning'] =
                '${(dateEnd - dateNow) ~/ 86400000} Dias Restantes';
            info['percent'] = 100.0;
            info['ativo'] = true;

            debugPrint('info: $info');
          }
          // } catch (e) {
          //   debugPrint('Error checkSignature com assinatura nova: $e');
          // }
        }
      }
    }
  }
}
