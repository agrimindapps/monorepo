// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/mobile_page_controller.dart';
import '../router.dart';

class MobilePageMain extends GetView<MobilePageController> {
  final GlobalKey<NavigatorState>? navigatorKey;

  const MobilePageMain({super.key, this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    // Verificação de segurança para o controller
    if (!Get.isRegistered<MobilePageController>()) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SafeArea(
      top: false,
      bottom: false,
      minimum: const EdgeInsets.only(top: 0, bottom: 0),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // Vamos usar o Navigator com onGenerateRoute que sabemos que funciona
    // GetRouterOutlet pode ter problemas de sincronização com navegação por ID
    debugPrint('Using Navigator with nested key for ID: 1');
    return Navigator(
      key: Get.nestedKey(1),
      initialRoute: AppRoutes.defensivosHome,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    // Procura a rota correspondente nas GetPages
    final page = AppPages.routes.firstWhereOrNull(
      (page) => page.name == settings.name,
    );

    if (page != null) {
      // Aplica o binding se existir
      if (page.binding != null) {
        page.binding!.dependencies();
      }

      // Cria a rota sem animações de transição
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => page.page(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child; // Sem animação
        },
      );
    }

    // Rota padrão - defensivos home
    final defaultPage = AppPages.routes.firstWhereOrNull(
      (page) => page.name == AppRoutes.defensivosHome,
    );

    if (defaultPage != null) {
      if (defaultPage.binding != null) {
        defaultPage.binding!.dependencies();
      }
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => defaultPage.page(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child; // Sem animação
        },
      );
    }

    // Fallback extremo sem animação
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => const Scaffold(
        body: Center(
          child: Text('Página não encontrada'),
        ),
      ),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child; // Sem animação
      },
    );
  }
}
