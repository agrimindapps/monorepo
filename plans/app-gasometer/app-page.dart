// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../core/themes/manager.dart';
import 'di/gasometer_di_module.dart';
import 'pages/cadastros/veiculos_page/widgets/veiculos_page_widget.dart';
import 'pages/mobile_page.dart';
import 'router.dart';
import 'services/gasometer_hive_service.dart';
import 'services/maintenance_notification_manager.dart';
import 'translations/veiculos_translations.dart';


/// Classe de inicialização do módulo Gasometer
///
/// ARQUITETURA UNIFICADA: Esta classe agora utiliza o novo sistema de rotas
/// baseado em GetX Pages com Bindings automáticos para injeção de dependências.
class GasometerApp {
  /// Inicializa o módulo Gasometer
  /// 
  /// Agora utiliza sistema modular de DI que resolve race conditions e memory leaks
  static Future<void> initialize() async {
    // Inicializa através do novo sistema modular sem verificações manuais
    await GasometerDIManager.instance.initializeAll();
  }

  /// Valida que o sistema de inicialização funciona com múltiplas chamadas simultâneas
  /// 
  /// Este método pode ser usado para testar que race conditions foram resolvidas
  static Future<void> validateConcurrentInitialization() async {
    // Testa múltiplas inicializações simultâneas
    final futures = List.generate(3, (_) => initialize());
    await Future.wait(futures);
  }

  /// Retorna a página inicial do módulo (compatibilidade)
  static Widget homePage() {
    return const VeiculosPage();
  }

  /// Retorna as rotas do módulo usando novo sistema GetX
  ///
  /// MIGRAÇÃO: Substitui o sistema legado de WidgetBuilder por GetPage
  /// com Bindings automáticos e gerenciamento de dependências otimizado.
  static List<GetPage> routes() {
    return GasometerPages.routes;
  }
}

class AppPageGasometer extends StatefulWidget {
  const AppPageGasometer({super.key});

  @override
  State<AppPageGasometer> createState() => _AppPageState();
}

class _AppPageState extends State<AppPageGasometer> {
  Timer? _timerTheme;
  ThemeData currentTheme = ThemeManager().currentTheme;

  @override
  void initState() {
    super.initState();

    _timerTheme = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        currentTheme = ThemeManager().currentTheme;
      });
    });

    // Inicializa o módulo Gasometer através da classe unificada
    _initializeGasometerApp();

    Get.put(Messages());

    // Inicializa o gerenciador de notificações
    _initializeNotifications();
  }

  Future<void> _initializeGasometerApp() async {
    // Inicializar Hive para o módulo app-gasometer
    await GasometerHiveService.initialize();

    // Sistema modular de DI garante inicialização sem verificações manuais
    await GasometerApp.initialize();
  }

  Future<void> _initializeNotifications() async {
    try {
      await MaintenanceNotificationManager().initialize(
        onNotificationTap: (String? payload) {
          // Aqui você pode adicionar lógica para navegar para a tela
          // adequada quando uma notificação for clicada
          debugPrint('Notificação de manutenção clicada: $payload');
        },
      );
      debugPrint(
          'Gerenciador de notificações do GasOMeter inicializado com sucesso');
    } catch (e) {
      debugPrint('Erro ao inicializar o gerenciador de notificações: $e');
    }
  }

  @override
  dispose() {
    _timerTheme?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GasOMeter',
      debugShowCheckedModeBanner: false,
      theme: currentTheme,
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return const MobilePageMain();
            // if (GetPlatform.isMobile) {
            //   return const MobilePageMain();
            // } else {
            //   // Web platform
            //   if (FirebaseAuthService().isUserLoggedIn) {
            //     return const DesktopPageMain();
            //   } else {
            //     return const PromoCarPage();
            //   }
            // }
          },
        ),
      ),
    );
  }
}
