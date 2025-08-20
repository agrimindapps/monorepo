// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'pages/bovinos/cadastro/index.dart';
import 'pages/bovinos/detalhes/index.dart';
import 'pages/bovinos/lista/index.dart';
import 'pages/bulas/lista/index.dart';
import 'pages/calc/aplicacao/index.dart';
import 'pages/calc/balanco_nutricional/index.dart';
import 'pages/calc/calculos_page.dart';
import 'pages/calc/fertilizantes/index.dart';
import 'pages/calc/fruticultura/index.dart';
import 'pages/calc/manejo_integracao/index.dart';
import 'pages/calc/maquinario/index.dart';
import 'pages/calc/pecuaria/aproveitamento_carcaca/index.dart';
import 'pages/calc/pecuaria/loteamento_bovino/index.dart';
import 'pages/calc/previsao/index.dart';
import 'pages/calc/rendimento/index.dart';
import 'pages/calc/rotacao_culturas/index.dart';
import 'pages/calc/semeadura/index.dart';
import 'pages/implementos/cadastro/index.dart';
import 'pages/implementos/detalhes/index.dart';
import 'pages/implementos/lista/index.dart';
import 'pages/noticias/noticias_agricultura_page.dart';
import 'pages/noticias/noticias_pecuaria_page.dart';
import 'pages/subscription_page.dart';

// Calc Pages

// Noticias Pages

// Subscription Page

class AgriHurbiRoutes {
  // Main Routes
  static const String home = '/agrihurbi';

  // Bovinos Routes
  static const String bovinosLista = '/bovinos/listar';
  static const String bovinosDetalhes = '/bovinos/detalhes';
  static const String bovinosCadastro = '/bovinos/cadastro';

  // Implementos Routes
  static const String implementosLista = '/implementos/listar';
  static const String implementosDetalhes = '/implementos/detalhes';
  static const String implementosCadastro = '/implementos/cadastro';

  // Bulas Routes
  static const String bulasLista = '/bulas/listar';

  // Noticias Routes
  static const String noticiasAgricultura = '/agricultura/noticias';
  static const String noticiasPecuaria = '/pecuaria/noticias';

  // Calc Routes
  static const String calculos = '/calc/agro';
  static const String fertilizantes = '/calc/fertilizantes';
  static const String previsao = '/calc/previsao';
  static const String semeadura = '/calc/semeadura';
  static const String maquinario = '/calc/maquinario';
  static const String aplicacao = '/calc/aplicacao';
  static const String rotacaoCulturas = '/calc/rotacao-culturas';
  static const String fruticultura = '/calc/fruticultura';
  static const String balancoNutricional = '/calc/balanco-nutricional';
  static const String manejoIntegrado = '/calc/manejo-integrado';
  static const String rendimento = '/calc/rendimento';
  static const String loteamentoBovino = '/calc/loteamento-bovino';
  static const String aproveitamentoCarcaca = '/calc/aproveitamento-carcaca';

  // Subscription Routes
  static const String subscription = '/agrihurbi/subscription';
}

class AgriHurbiPages {
  static final List<GetPage> routes = [
    // Bovinos
    GetPage(
      name: AgriHurbiRoutes.bovinosLista,
      page: () => const BovinosListaPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.bovinosDetalhes,
      page: () => const BovinosDetalhesPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.bovinosCadastro,
      page: () => const BovinosCadastroPage(),
      transition: Transition.rightToLeft,
    ),

    //Implementos
    GetPage(
      name: AgriHurbiRoutes.implementosLista,
      page: () => ImplementosAgListaPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.implementosDetalhes,
      page: () {
        final idReg = Get.arguments as String? ?? '';
        return ImplementosAgDetalhesPage(idReg: idReg);
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.implementosCadastro,
      page: () {
        final idReg = Get.arguments as String? ?? '';
        return ImplementosCadastroPage(idReg: idReg);
      },
      transition: Transition.rightToLeft,
    ),

    // Calc Routes
    GetPage(
      name: AgriHurbiRoutes.calculos,
      page: () => const CalculosPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.fertilizantes,
      page: () => const FertilizantesPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.previsao,
      page: () => const PrevisaoPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.semeadura,
      page: () => const SemeaduraPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.maquinario,
      page: () => const MaquinarioPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.aplicacao,
      page: () => const AplicacaoPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.rotacaoCulturas,
      page: () => const RotacaoCulturasPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.fruticultura,
      page: () => const FruticulturaPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.balancoNutricional,
      page: () => const BalancoNutricionalPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.manejoIntegrado,
      page: () => const ManejoIntegradoPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.rendimento,
      page: () => const RendimentoIndexPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.loteamentoBovino,
      page: () => const LoteamentoBovinoPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.aproveitamentoCarcaca,
      page: () => const AproveitamentoCarcacaPage(),
      transition: Transition.rightToLeft,
    ),

    // Bulas Routes
    GetPage(
      name: AgriHurbiRoutes.bulasLista,
      page: () => const BulasListaPage(),
      transition: Transition.rightToLeft,
    ),

    // Noticias Routes
    GetPage(
      name: AgriHurbiRoutes.noticiasAgricultura,
      page: () => const NoticiasAgricolassPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AgriHurbiRoutes.noticiasPecuaria,
      page: () => const NoticiasPecuariasPage(),
      transition: Transition.rightToLeft,
    ),

    // Subscription Routes
    GetPage(
      name: AgriHurbiRoutes.subscription,
      page: () => const AgriHurbiSubscriptionPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}
