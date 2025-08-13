// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'bindings/mobile_page_binding.dart';
import 'injections.dart';

import 'pages/assinaturas/index.dart';
import 'pages/atualizacao/bindings/atualizacao_bindings.dart';
import 'pages/atualizacao/views/atualizacao_page.dart';
import 'pages/comentarios/index.dart';
import 'pages/config/config_page.dart';
import 'pages/desktop_page.dart';
import 'pages/detalhes_defensivos/bindings/detalhes_defensivos_bindings.dart';
import 'pages/detalhes_defensivos/views/detalhes_defensivos_page.dart';
import 'pages/detalhes_diagnostico/index.dart';
import 'pages/detalhes_pragas/index.dart';
import 'pages/favoritos/bindings/favoritos_binding.dart';
import 'pages/favoritos/favoritos_page.dart';
import 'pages/home_defensivos/bindings/home_defensivos_bindings.dart';
import 'pages/home_defensivos/views/home_defensivos_page.dart';
import 'pages/home_pragas/views/home_pragas_page.dart';
import 'pages/lista_culturas/bindings/lista_culturas_bindings.dart';
import 'pages/lista_culturas/views/lista_culturas_page.dart';
import 'pages/lista_defensivos/bindings/lista_defensivos_bindings.dart';
import 'pages/lista_defensivos/views/lista_defensivos_page.dart';
import 'pages/lista_defensivos_agrupados/bindings/lista_defensivos_agrupados_bindings.dart';
import 'pages/lista_defensivos_agrupados/views/lista_defensivos_agrupados_page.dart';
import 'pages/lista_pragas/bindings/lista_pragas_bindings.dart';
import 'pages/lista_pragas/views/lista_pragas_page.dart';
import 'pages/lista_pragas_por_cultura/bindings/lista_pragas_por_cultura_bindings.dart';
import 'pages/lista_pragas_por_cultura/views/lista_pragas_por_cultura_page.dart';
import 'pages/loading_page/index.dart';
import 'pages/mobile_page.dart';
import 'pages/not_found_page.dart';
import 'pages/sobre/bindings/sobre_bindings.dart';
import 'pages/sobre/views/sobre_page.dart';

// Define constantes para rotas para evitar strings literais
class AppRoutes {
  // Prefixo base para todas as rotas
  static const String _baseRoute = '/receituagro';

  // Gerais
  static const String main = '$_baseRoute/index';
  static const String rHome = '$_baseRoute/home';
  static const String rMobile = '$_baseRoute/mobile';
  static const String rDesktop = '$_baseRoute/desktop';

  // Culturas
  static const String culturasListar = '$_baseRoute/culturas/listar';

  // Defensivos
  static const String defensivos = '$_baseRoute/defensivos/detalhes';
  static const String defensivosHome = '$_baseRoute/defensivos/home';
  static const String defensivosListar = '$_baseRoute/defensivos/listar';
  static const String defensivosListarNew = '$_baseRoute/defensivos/listar-new';
  static const String defensivosAgrupados = '$_baseRoute/defensivos/agrupados';

  // Pragas
  static const String pragasHome = '$_baseRoute/pragas/home';
  static const String pragasHomeNew = '$_baseRoute/pragas/home-new';
  static const String pragasDetalhes = '$_baseRoute/pragas/detalhes';
  static const String pragasListar = '$_baseRoute/pragas/listar';
  static const String pragasListarSimples = '$_baseRoute/pragas/listar-simples';
  static const String pragasCulturas = '$_baseRoute/pragas/culturas';

  // Outros recursos
  static const String favoritos = '$_baseRoute/favoritos';
  static const String diagnostico = '$_baseRoute/diagnostico';
  static const String diagnosticoDetalhes = '$_baseRoute/diagnostico/detalhes';

  // Ferramentas
  static const String comentarios = '$_baseRoute/ferramentas/comentarios';

  // Configurações
  static const String config = '$_baseRoute/config';
  static const String configTTS = '$_baseRoute/config/tts';
  static const String sobre = '$_baseRoute/sobre';
  static const String atualizacao = '$_baseRoute/atualizacao';
  static const String premium = '$_baseRoute/premium';

  // Página de erro
  static const String notFound = '$_baseRoute/404';
}

class AppPages {
  static final routes = [
    // Carregamento e páginas iniciais
    GetPage(
      name: AppRoutes.main,
      page: () => const CarregandoPage(),
    ),
    GetPage(
      name: AppRoutes.rHome,
      page: () => const HomeDefensivosPage(),
      binding: ReceituagroBindings(),
    ),

    // Culturas
    GetPage(
      name: AppRoutes.culturasListar,
      page: () => const ListaCulturasPage(),
      binding: ListaCulturasBindings(),
    ),

    // Defensivos
    GetPage(
      name: AppRoutes.defensivos,
      page: () => const DetalhesDefensivosPage(),
      binding: DetalhesDefensivosBindings(),
    ),
    GetPage(
      name: AppRoutes.defensivosHome,
      page: () => const HomeDefensivosPage(),
      binding: HomeDefensivosBindings(),
    ),
    GetPage(
      name: AppRoutes.defensivosListar,
      page: () => const ListaDefensivosPage(),
      binding: ReceituagroBindings(),
    ),
    GetPage(
      name: AppRoutes.defensivosListarNew,
      page: () => const ListaDefensivosPage(),
      binding: ListaDefensivosBindings(),
    ),
    GetPage(
      name: AppRoutes.defensivosAgrupados,
      page: () {
        final arguments = Get.arguments as Map<String, String>? ?? {};
        final tipoAgrupamento = arguments['tipoAgrupamento'] ??
            Get.parameters['tipoAgrupamento'] ??
            'fabricantes';
        final textoFiltro =
            arguments['textoFiltro'] ?? Get.parameters['textoFiltro'] ?? '';
        return ListaDefensivosAgrupadosPage(
          tipoAgrupamento: tipoAgrupamento,
          textoFiltro: textoFiltro,
        );
      },
      binding:
          ListaDefensivosAgrupadosBindings(), // <-- Adicionado binding correto
    ),

    // Pragas
    GetPage(
      name: AppRoutes.pragasHome,
      page: () => const HomePragasPage(),
      binding: ReceituagroBindings(),
    ),
    GetPage(
      name: AppRoutes.pragasListar,
      page: () => const ListaPragasPage(),
      binding: ListaPragasBindings(),
    ),
    GetPage(
      name: AppRoutes.pragasListarSimples,
      page: () => const ListaPragasPage(),
      binding: ListaPragasBindings(),
    ),
    GetPage(
      name: AppRoutes.pragasCulturas,
      page: () => const ListaPragasPorCulturaPage(),
      binding: ListaPragasPorCulturaBindings(),
    ),
    GetPage(
      name: AppRoutes.pragasDetalhes,
      page: () => const DetalhesPragasPage(),
      binding: DetalhesPragasBindings(),
    ),

    // Favoritos
    GetPage(
      name: AppRoutes.favoritos,
      page: () => const FavoritosPage(),
      binding: FavoritosBinding(),
    ),

    // Diagnóstico
    GetPage(
      name: AppRoutes.diagnostico,
      page: () => const DetalhesDiagnosticoPage(),
      binding: DetalhesDiagnosticoBindings(),
    ),
    GetPage(
      name: AppRoutes.diagnosticoDetalhes,
      page: () => const DetalhesDiagnosticoPage(),
      binding: DetalhesDiagnosticoBindings(),
    ),

    // Navegação principal
    GetPage(
      name: AppRoutes.rMobile,
      page: () => const MobilePageMain(),
      binding: MobilePageBinding(),
    ),
    GetPage(
      name: AppRoutes.rDesktop,
      page: () => const DesktopPageMain(),
    ),

    // Ferramentas
    GetPage(
      name: AppRoutes.comentarios,
      page: () => const ComentariosPage(),
      binding: ComentariosBindings(),
    ),

    // Configurações
    GetPage(
      name: AppRoutes.config,
      page: () => const ConfigPage(),
    ),
    GetPage(
      name: AppRoutes.configTTS,
      page: () => const ConfigPage(), // Using ConfigPage as fallback
    ),
    GetPage(
      name: AppRoutes.premium,
      page: () => const AssinaturasPage(),
      binding: AssinaturasBindings(),
    ),
    GetPage(
      name: AppRoutes.sobre,
      page: () => const SobrePage(),
      binding: SobreBindings(),
    ),
    GetPage(
      name: AppRoutes.atualizacao,
      page: () => const AtualizacaoPage(),
      binding: AtualizacaoBindings(),
    ),

    // Página 404 - Não encontrada
    GetPage(
      name: AppRoutes.notFound,
      page: () => const NotFoundPage(),
    ),
  ];

  /// Handler para rotas não encontradas
  /// Redireciona automaticamente para a página 404
  static GetPage get unknownRoute => GetPage(
        name: '/not-found',
        page: () => const NotFoundPage(),
      );
}
