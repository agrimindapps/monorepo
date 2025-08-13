// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/models/database.dart';
import '../classes/cultura_class.dart';
import '../classes/diagnostico_class.dart';
import '../classes/fitossanitario_class.dart';
import '../classes/fitossanitarioinfo_class.dart';
import '../classes/plantasinf_class.dart';
import '../classes/pragas_class.dart';
import '../classes/pragasinf_class.dart';

class DatabaseRepository extends GetxController {
  List<Fitossanitario> gFitossanitarios = [];
  List<Diagnostico> gDiagnosticos = [];
  List<PlantasInf> gPlantasInf = [];
  List<PragasInf> gPragasInf = [];
  List<Pragas> gPragas = [];
  List<FitossanitariosInfo> gFitossanitariosInfo = [];
  List<Cultura> gCulturas = [];

  RxBool isLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Inicializar carregamento dos dados automaticamente
    initializeData();
  }

  /// Inicializa todos os dados do banco com timeout
  Future<void> initializeData() async {
    try {
      debugPrint('Iniciando carregamento dos dados do DatabaseRepository...');

      // Implementar timeout para evitar travamento (aumentado para 30s)
      await Future.any([
        _loadDataWithProgress(),
        Future.delayed(const Duration(seconds: 30), () {
          throw TimeoutException(
              'Timeout no carregamento dos dados', const Duration(seconds: 30));
        }),
      ]);
    } catch (e) {
      debugPrint('Erro ao inicializar dados do banco: $e');
      // Marcar como carregado mesmo com erro para não travar a aplicação
      isLoaded.value = true;
    }
  }

  /// Carrega os dados com progresso
  Future<void> _loadDataWithProgress() async {
    try {
      isLoaded.value = false;
      debugPrint('Carregando variáveis primárias...');
      await carregaVariaveisPrimarias();

      debugPrint('Carregando variáveis secundárias...');
      await carregaVariaveisSecundarias();

      debugPrint('Dados carregados com sucesso!');
    } catch (e) {
      debugPrint('Erro durante o carregamento: $e');
      rethrow;
    }
  }

  Future<void> carregaVariaveisPrimarias() async {
    isLoaded.value = false;
    var results = await Future.wait([
      Database().getAll('tbfitossanitarios'),
      Database().getAll('tbpragas'),
      Database().getAll('tbculturas'),
    ]);

    gFitossanitarios = List<Map<String, dynamic>>.from(results[0])
        .map((e) => Fitossanitario.fromJson(e))
        .toList();
    gPragas = List<Map<String, dynamic>>.from(results[1])
        .map((e) => Pragas.fromJson(e))
        .toList();
    gCulturas = List<Map<String, dynamic>>.from(results[2])
        .map((e) => Cultura.fromJson(e))
        .toList();
  }

  Future<void> carregaVariaveisSecundarias() async {
    var results = await Future.wait([
      Database().getAll('tbdiagnostico'),
      Database().getAll('tbplantasinf'),
      Database().getAll('tbpragasinf'),
      Database().getAll('tbfitossanitariosinfo'),
    ]);

    gDiagnosticos = List<Map<String, dynamic>>.from(results[0])
        .map((e) => Diagnostico.fromJson(e))
        .toList();
    gPlantasInf = List<Map<String, dynamic>>.from(results[1])
        .map((e) => PlantasInf.fromJson(e))
        .toList();
    gPragasInf = List<Map<String, dynamic>>.from(results[2])
        .map((e) => PragasInf.fromJson(e))
        .toList();
    gFitossanitariosInfo = List<Map<String, dynamic>>.from(results[3])
        .map((e) => FitossanitariosInfo.fromJson(e))
        .toList();
    isLoaded.value = true;
  }
}
