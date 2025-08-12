// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'pages/cadastros/abastecimento_page/index.dart';
import 'pages/cadastros/despesas_page/index.dart';
import 'pages/cadastros/manutencoes_page/index.dart';
import 'pages/cadastros/odometro_page/index.dart';
import 'pages/cadastros/veiculos_page/bindings/veiculos_page_modern_binding.dart';
import 'pages/cadastros/veiculos_page/index.dart';
import 'pages/login_page.dart';
import 'pages/settings/index.dart';
import 'pages/subscription/subscription_page.dart';

/// Rotas do módulo Gasometer
class GasometerRoutes {
  static const String veiculos = '/gasometer/veiculos';
  static const String abastecimentos = '/gasometer/abastecimentos';
  static const String manutencoes = '/gasometer/manutencoes';
  static const String despesas = '/gasometer/despesas';
  static const String odometro = '/gasometer/odometro';
  static const String relatorios = '/gasometer/relatorios';
  static const String login = '/gasometer/login';
  static const String settings = '/gasometer/settings';
  static const String subscription = '/gasometer/subscription';
}

/// Páginas do módulo Gasometer com GetPage
class GasometerPages {
  static final List<GetPage> routes = [
    GetPage(
      name: GasometerRoutes.veiculos,
      page: () => const VeiculosPage(),
      binding: VeiculosPageModernBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: GasometerRoutes.abastecimentos,
      page: () => const AbastecimentoPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: GasometerRoutes.manutencoes,
      page: () => const ManutencoesPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: GasometerRoutes.despesas,
      page: () => const DespesasPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: GasometerRoutes.odometro,
      page: () => const OdometroPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: GasometerRoutes.login,
      page: () => const LoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: GasometerRoutes.settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: GasometerRoutes.subscription,
      page: () => const GasometerSubscriptionPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}
