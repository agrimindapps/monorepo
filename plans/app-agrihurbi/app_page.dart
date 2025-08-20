// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'pages/desktop_page.dart';
import 'pages/mobile_page.dart';
import 'services/agrihurbi_hive_service.dart';

class AppAgriHurbiMain extends StatefulWidget {
  const AppAgriHurbiMain({super.key});

  @override
  State<AppAgriHurbiMain> createState() => _AppAgriHurbiMainState();
}

class _AppAgriHurbiMainState extends State<AppAgriHurbiMain> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAgrihurbiModule();
  }

  Future<void> _initializeAgrihurbiModule() async {
    try {
      // Inicializar Hive para o módulo app-agrihurbi
      await AgrihurbiHiveService.initialize();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('❌ Erro ao inicializar módulo app-agrihurbi: $e');
      // Em caso de erro, continua com a inicialização
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return const Scaffold(
            body: DesktopPageMain(),
          );
        } else {
          return const MobilePageMain();
        }
      },
    );
  }
}
