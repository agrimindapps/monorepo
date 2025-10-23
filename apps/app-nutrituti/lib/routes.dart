// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../core/pages/in_app_purchase_page.dart';
import 'app-page.dart';
import 'pages/agua/beber_agua_page.dart';
import 'pages/alimentos_page.dart';
import 'pages/calc/alcool_sangue/index.dart';
import 'pages/calc/calc_page.dart';
import 'pages/calc/calorias_diarias/index.dart';
import 'pages/calc/calorias_por_exercicio/index.dart';
import 'pages/calc/cintura_quadril/index.dart';
import 'pages/calc/deficit_superavit/index.dart';
import 'pages/calc/densidade_nutrientes/index.dart';
import 'pages/calc/densidade_ossea/index.dart';
import 'pages/calc/gasto_energetico/index.dart';
import 'pages/calc/macronutrientes/view/macronutrientes_page_new.dart';
import 'pages/calc/massa_corporea/index.dart';
import 'pages/calc/necessidade_hidrica/index.dart';
import 'pages/calc/peso_ideal/index.dart';
import 'pages/calc/proteinas_diarias/index.dart';
import 'pages/calc/taxa_metabolica_basal/index.dart';
import 'pages/calc/volume_sanguineo/index.dart';
import 'pages/config_page.dart';
import 'pages/exercicios/pages/exercicio_page.dart';
import 'pages/login_page.dart';
import 'pages/meditacao/index.dart';
import 'pages/peso/peso_page.dart';
import 'pages/pratos/pratos_page.dart';
import 'pages/promo/promo_page.dart';
import 'pages/receitas/receitas_page.dart';
import 'pages/settings_page.dart';

// Calculator imports

class AppRoutes {
  // Main Routes
  static String home = '/';
  static String login = '/login';
  static String categorias = '/categorias';
  static String alimentos = '/alimentos';
  static String favoritos = '/favoritos';

  // Calculation Routes
  static String calculos = '/calculos';
  static String calculosNew = '/calculos/new';
  static String calculoAlcoolSangue = '/calc/alcool_sangue';
  static String calculoCaloriasDiarias = '/calc/calorias_diarias';
  static String calculoCaloriasExercicio = '/calc/calorias_exercicio';
  static String calculoMassaCorporea = '/calc/massa_corporea';
  static String calculoPesoIdeal = '/calc/peso_ideal';
  static String calculoVolumeSanguineo = '/calc/volume_sanguineo';
  static String calculoTaxaMetabolicaBasal = '/calc/taxa_metabolica_basal';
  static String calculoNecessidadeHidrica = '/calc/necessidade_hidrica';
  static String calculoCinturaQuadril = '/calc/cintura_quadril';
  static String calculoMacronutrientes = '/calc/macronutrientes';
  static String calculoDensidadeOssea = '/calc/densidade_ossea';
  static String calculoGastoEnergetico = '/calc/gasto_energetico';
  static String calculoProteinaDiaria = '/calc/proteina_diaria';
  static String calculoDeficitSuperavit = '/calc/deficit_superavit';
  static String calculoIndiceAdiposidade = '/calc/indice_adiposidade';
  static String calculoIAC = '/calc/iac';
  static String calculoDensidadeNutrientes = '/calc/densidade_nutrientes';

  // Tool Routes
  static String ferramentas = '/ferramentas';
  static String nutritutiApp = '/app-nutrituti';
  static String peso = '/peso';
  static String beberAgua = '/beber_agua';
  static String exercicios = '/exercicios';
  static String meditacao = '/meditacao';
  static String pratos = '/pratos';
  static String receitas = '/receitas';
  static String asmr = '/asmr';
  static String anotacoes = '/anotacoes';
  static String games = '/games';

  // todo
  static String todoist = '/ferramentas/tarefas';

  // Settings Routes
  static String configuracoes = '/config';
  static String configuracoesAvancadas = '/config/avancadas';
  static String premium = '/premium';
  static String sobre = '/sobre';
  static String atualizacao = '/atualizacao';
}

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routes = <String, WidgetBuilder>{
      // Main Routes
      AppRoutes.home: (_) => const PromoPage(),
      AppRoutes.login: (_) => const LoginPage(),
      AppRoutes.categorias: (_) => const PromoPage(),
      AppRoutes.alimentos: (_) =>
          const AlimentosPage(categoria: '0', onlyFavorites: false),
      AppRoutes.favoritos: (_) =>
          const AlimentosPage(categoria: '0', onlyFavorites: true),

      // Calculation Routes
      AppRoutes.calculos: (_) => const CalcPage(),

      // Cálculos do Corpo
      AppRoutes.calculoMassaCorporea: (_) => const MassaCorporeaPage(),
      AppRoutes.calculoVolumeSanguineo: (_) => const VolumeSanguineoCalcPage(),
      AppRoutes.calculoAlcoolSangue: (_) => const AlcoolSangueCalcPage(),
      AppRoutes.calculoPesoIdeal: (_) => const PesoIdealCalcPage(),
      AppRoutes.calculoCinturaQuadril: (_) => const CinturaQuadrilPage(),
      AppRoutes.calculoDensidadeOssea: (_) => const DensidadeOsseaCalcPage(),
      // AppRoutes.calculoIndiceAdiposidade: (_) =>
      //     const IndiceAdiposidadeCalcPage(),

      // Cálculos de Nutrição
      AppRoutes.calculoMacronutrientes: (_) => const MacronutrientesPage(),
      AppRoutes.calculoProteinaDiaria: (_) => const ProteinasDiariasPage(),
      AppRoutes.calculoDensidadeNutrientes: (_) =>
          const ZNewDensidadeNutrientesPage(),
      AppRoutes.calculoNecessidadeHidrica: (_) =>
          const NecessidadeHidricaCalcPage(),

      // Cálculos de Calorias
      AppRoutes.calculoCaloriasDiarias: (_) => const CaloriasDiariasPage(),
      AppRoutes.calculoCaloriasExercicio: (_) =>
          const CaloriasPorExercicioCalcPage(),
      AppRoutes.calculoTaxaMetabolicaBasal: (_) =>
          const TaxaMetabolicaBasalCalcPage(),
      AppRoutes.calculoGastoEnergetico: (_) => const GastoEnergeticoPage(),
      AppRoutes.calculoDeficitSuperavit: (_) =>
          const DeficitSuperavitCalcPage(),

      // Tool Routes
      // TODO FASE 1: Re-enable after fixing NutriTutiAppPage
      // AppRoutes.nutritutiApp: (_) => const NutriTutiAppPage(),
      AppRoutes.peso: (_) => const PesoPage(),
      AppRoutes.beberAgua: (_) => const BeberAguaPage(),
      AppRoutes.exercicios: (_) => const ExercicioPage(),
      AppRoutes.meditacao: (_) => MeditacaoPage(),
      AppRoutes.pratos: (_) => const PratosPage(),
      AppRoutes.receitas: (_) => const ReceitasPage(),

      // Settings Routes
      AppRoutes.configuracoes: (_) => const ConfigPage(),
      AppRoutes.configuracoesAvancadas: (_) => const SettingsPage(),
      // TODO FASE 1: Re-enable after fixing SubscriptionScreen
      // AppRoutes.premium: (_) => const SubscriptionScreen(),

      // About Routes
      // AppRoutes.sobre: (_) => const SobrePage(),
      // AppRoutes.atualizacao: (_) => const AtualizacaoPage(),
    };

    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }

    // Default route if no match is found
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }
}
