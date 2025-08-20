// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'pages/desktop_page.dart';
import 'pages/mobile_page.dart';
import 'services/nutrituti_hive_service.dart';

class NutriTutiAppPage extends StatefulWidget {
  const NutriTutiAppPage({super.key});

  @override
  State<NutriTutiAppPage> createState() => _NutriTutiAppPageState();
}

class _NutriTutiAppPageState extends State<NutriTutiAppPage> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNutriTutiModule();
  }

  Future<void> _initializeNutriTutiModule() async {
    try {
      // Inicializar Hive para o módulo app-nutrituti
      await NutriTutiHiveService.initialize();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('❌ Erro ao inicializar módulo app-nutrituti: $e');
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
          return const DesktopPageNutriTuti();
        } else {
          return const MobilePageNutriTuti();
        }
      },
    );
  }
}
