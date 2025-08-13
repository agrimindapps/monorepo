// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/models/database.dart';
import '../../core/services/localstorage_service.dart';
import '../models/praga_unica_model.dart';
import 'database_repository.dart';

class PragasRepository extends GetxController {
  static const _maxRecentItems = 7;
  static const _maxSuggestedItems = 5;

  final PragaUnica pragaUnica = PragaUnica();
  final RxBool isLoading = false.obs;

  // Referência ao DatabaseRepository registrado
  DatabaseRepository get _databaseRepo => Get.find<DatabaseRepository>();

  @override
  void onInit() {
    super.onInit();
    // Aguardar que o DatabaseRepository seja carregado antes de inicializar
    ever(_databaseRepo.isLoaded, (bool loaded) {
      if (loaded) {
        initInfo();
      }
    });
  }

  //************************************************************************
  // FUNÇÕES PÚBLICAS (em ordem alfabética)
  //************************************************************************

  Future<List<Map<String, dynamic>>> getCulturas() async {
    try {
      // Aguardar carregamento se necessário
      await _waitForData();

      final rawData = _databaseRepo.gCulturas.map((c) => c.toJson()).toList();
      final processedData =
          rawData.map((culturaMap) => _formatCulturaData(culturaMap)).toList();

      return Database()
          .orderList(processedData, 'cultura', null, false)
          .cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar culturas: $e\n$stackTrace');
      return [];
    }
  }

  /// Obtém os detalhes de uma praga pelo ID
  /// Atualiza a propriedade pragaUnica e retorna true se a operação for bem-sucedida
  Future<bool> getPragaById(String id) async {
    isLoading.value = true;

    try {
      if (id.isEmpty) {
        throw ArgumentError('ID não pode ser vazio');
      }

      // Aguardar carregamento se necessário
      await _waitForData();

      final data = _databaseRepo.gPragas.map((p) => p.toJson()).firstWhere(
            (row) => row['idReg'] == id,
            orElse: () =>
                throw StateError('Praga não encontrada com o ID: $id'),
          );

      _updatePragaUnica(data);
      _loadAdditionalInfo(id, data['tipoPraga']);

      await setPragaAcessada();
      return true;
    } catch (e, stackTrace) {
      debugPrint('Erro ao buscar praga por ID: $e\n$stackTrace');
      _resetPragaUnica();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> getPragasAcessados() async {
    try {
      // Aguardar carregamento se necessário
      await _waitForData();

      final dataPragas = _databaseRepo.gPragas.map((p) => p.toJson()).toList();
      final initialIds = dataPragas.map((e) => e['idReg'].toString()).toList();

      await _initializeRecentAccess(initialIds);
      return await _loadRecentItems(dataPragas);
    } catch (e) {
      debugPrint('Erro ao carregar pragas acessadas: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPragasPorCultura(String id) async {
    try {
      // Aguardar carregamento se necessário
      await _waitForData();

      final pragas = await _loadPragasPorCultura(id);
      return pragas;
    } catch (e) {
      debugPrint('Erro ao carregar pragas por cultura: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPragasRandom() async {
    try {
      // Aguardar carregamento se necessário
      await _waitForData();

      final allPragas = _databaseRepo.gPragas.map((p) => p.toJson()).toList();
      if (allPragas.isEmpty) {
        return [];
      }

      final random = Random();
      final selectedPragas = <Map<String, dynamic>>[];

      while (
          selectedPragas.length < _maxSuggestedItems && allPragas.isNotEmpty) {
        final randomIndex = random.nextInt(allPragas.length);
        final item = allPragas[randomIndex];
        selectedPragas.add(_formatPragaName(item));
      }

      return selectedPragas;
    } catch (e) {
      debugPrint('Erro ao carregar pragas aleatórias: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPragas(String type) async {
    try {
      // Aguardar carregamento se necessário
      await _waitForData();

      final data = _databaseRepo.gPragas.map((p) => p.toJson()).toList();
      final listOrder = Database().orderList(data, 'nomeComum', null, false);
      final processedData = _processePragasData(listOrder);
      return processedData.where((row) => row['tipoPraga'] == type).toList();
    } catch (e) {
      debugPrint('Erro ao carregar pragas do tipo $type: $e');
      return [];
    }
  }

  /// Obtém a lista de diagnósticos filtrados por ID de praga
  /// Se pragaId for fornecido, retorna apenas os diagnósticos relacionados à praga especificada
  /// Caso contrário, retorna todos os diagnósticos
  /// Retorna uma lista de diagnósticos formatados e ordenados
  Future<List<Map<String, dynamic>>> getDiagnosticos(String pragaId) async {
    try {
      // Aguardar carregamento se necessário
      await _waitForData();

      final diagnosticos =
          _databaseRepo.gDiagnosticos.map((d) => d.toJson()).toList();

      if (diagnosticos.isEmpty) {
        return [];
      }

      // Filtra por ID da praga, se especificado
      final filteredDiagnosticos = pragaId.isNotEmpty
          ? diagnosticos.where((diag) => diag['fkIdPraga'] == pragaId).toList()
          : diagnosticos;

      if (filteredDiagnosticos.isEmpty) {
        return [];
      }

      // Processa os dados obtidos
      return _processeDiagnosticosData(filteredDiagnosticos);
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar diagnósticos: $e\n$stackTrace');
      return [];
    }
  }

  // Método para obter a contagem de um tipo específico (insetos, doencas, plantas ou culturas)
  Future<int> getCountByType(String tipo) async {
    try {
      // Aguardar carregamento se necessário
      await _waitForData();

      if (tipo == 'culturas') {
        return _databaseRepo.gCulturas.length;
      } else {
        final pragas = _databaseRepo.gPragas;
        int contador = 0;

        for (final praga in pragas) {
          final tipoPraga = praga.tipoPraga;
          if ((tipo == 'insetos' && tipoPraga == '1') ||
              (tipo == 'doencas' && tipoPraga == '2') ||
              (tipo == 'plantas' && tipoPraga == '3')) {
            contador++;
          }
        }

        return contador;
      }
    } catch (e, stackTrace) {
      debugPrint('Erro ao obter contagem para $tipo: $e\n$stackTrace');
      return 0;
    }
  }

  void initInfo() {
    // Só inicializar se os dados estiverem carregados
    if (_databaseRepo.isLoaded.value) {
      getPragasAcessados();
      getCulturas();
    }
  }

  Future<void> setPragaAcessada() async {
    try {
      if (pragaUnica.idReg.isEmpty) {
        throw Exception('ID da praga inválido');
      }

      await LocalStorageService().setRecentItem(
        'acessadosPragas',
        pragaUnica.idReg,
      );

      await _loadRecentItems(
          _databaseRepo.gPragas.map((p) => p.toJson()).toList());
    } catch (e, stackTrace) {
      debugPrint('Erro ao atualizar praga acessada: $e\n$stackTrace');
      rethrow;
    }
  }

  //************************************************************************
  // FUNÇÕES PRIVADAS (em ordem alfabética)
  //************************************************************************

  /// Aguarda o carregamento dos dados do DatabaseRepository
  Future<void> _waitForData() async {
    if (!_databaseRepo.isLoaded.value) {
      debugPrint('Aguardando carregamento dos dados...');
      int attempts = 0;
      const maxAttempts = 30; // 3 segundos

      while (!_databaseRepo.isLoaded.value && attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (!_databaseRepo.isLoaded.value) {
        debugPrint('Timeout aguardando dados, forçando inicialização...');
        await _databaseRepo.initializeData();
      }
    }
  }

  String _formatCulturaAvatar(String culturaName) {
    return culturaName
        .replaceAll(',', '')
        .substring(0, min(2, culturaName.length))
        .toUpperCase();
  }

  Map<String, dynamic> _formatCulturaData(Map<String, dynamic> cultura) {
    final culturaName = cultura['cultura'] as String;
    return {
      'cultura': culturaName,
      'idReg': cultura['idReg'],
      'avatar': _formatCulturaAvatar(culturaName),
    };
  }

  String _formatImageName(String nome) {
    if (['Espalhante adesivo para calda de pulverização', 'Não classificado']
        .contains(nome)) {
      return 'a';
    }
    return nome.replaceAll('/', '-').replaceAll('ç', 'c').replaceAll('ã', 'a');
  }

  Map<String, dynamic> _formatPragaName(Map<String, dynamic> item) {
    final nomeList = item['nomeComum'].split(';');
    final nomePrincipal = nomeList[0].split('-')[0];
    return {
      ...item, 
      'nomeComum': nomePrincipal,
      'nomeImagem': _formatImageName(item['nomeCientifico'] ?? ''),
    };
  }

  List<Map<String, dynamic>> _formatPragasList(
      List<Map<String, dynamic>> pragas) {
    return pragas.map((praga) {
      final nomeList = praga['nomeComum'].split(';');
      return {
        ...praga,
        'nomeComum': nomeList[0],
        'nomeSecundario': nomeList.sublist(1).join(),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _getDiagnosticosPorCultura(String id) {
    return _databaseRepo.gDiagnosticos
        .map((d) => d.toJson())
        .where((row) => row['fkIdCultura'] == id)
        .toList();
  }

  Future<void> _initializeRecentAccess(List<String> initialIds) async {
    if (initialIds.isEmpty) {
      return;
    }
    await LocalStorageService().initRecentItems(
      'acessadosPragas',
      initialIds.sublist(0, min(15, initialIds.length)),
    );
  }

  void _loadAdditionalInfo(String id, String tipoPraga) {
    if (tipoPraga == '3') {
      _loadPlantInfo(id);
    } else if (tipoPraga == '1' || tipoPraga == '2') {
      _loadPestInfo(id);
    }
  }

  void _loadPestInfo(String id) {
    final dataInfPr =
        _databaseRepo.gPragasInf.where((row) => row.fkIdPraga == id).toList();

    final dataInfPrMap = dataInfPr.map((e) => e.toJson()).toList();

    final fields = [
      {'key': 'descrisao', 'title': 'Descrição', 'list': 'infoPraga'},
      {'key': 'sintomas', 'title': 'Sintomas', 'list': 'infoPraga'},
      {'key': 'bioecologia', 'title': 'Bioecologia', 'list': 'infoPraga'},
      {'key': 'controle', 'title': 'Controle', 'list': 'infoPraga'},
    ];

    _processFields(fields, dataInfPrMap);
  }

  void _loadPlantInfo(String id) {
    final dataInfPl = _databaseRepo.gPlantasInf
        .where((p) => p.fkIdPraga == id)
        .map((p) => p.toJson())
        .toList();

    final fields = [
      {'key': 'ciclo', 'title': 'Ciclo', 'list': 'infoPlanta'},
      {'key': 'reproducao', 'title': 'Reprodução', 'list': 'infoPlanta'},
      {'key': 'habitat', 'title': 'Habitat', 'list': 'infoPlanta'},
      {'key': 'adaptacoes', 'title': 'Adaptações', 'list': 'infoPlanta'},
      {'key': 'altura', 'title': 'Altura', 'list': 'infoPlanta'},
      {
        'key': 'inflorescencia',
        'title': 'Inflorescência',
        'list': 'infoFlores'
      },
      {'key': 'fruto', 'title': 'Fruto', 'list': 'infoFrutos'},
      {'key': 'filotaxia', 'title': 'Filotaxia', 'list': 'infoFolhas'},
      {'key': 'formaLimbo', 'title': 'Forma do Limbo', 'list': 'infoFolhas'},
      {'key': 'superficie', 'title': 'Superfície', 'list': 'infoFolhas'},
      {'key': 'consistencia', 'title': 'Consistência', 'list': 'infoFolhas'},
      {'key': 'nervacao', 'title': 'Nervação', 'list': 'infoFolhas'},
      {
        'key': 'nervacaoComprimento',
        'title': 'Comprimento da Nervação',
        'list': 'infoFolhas'
      },
    ];

    _processFields(fields, dataInfPl);
  }

  Future<List<Map<String, dynamic>>> _loadPragasPorCultura(String id) async {
    try {
      if (id.isEmpty) {
        throw ArgumentError('ID da cultura não pode ser vazio');
      }

      final diagnosticos = _getDiagnosticosPorCultura(id);
      if (diagnosticos.isEmpty) {
        return [];
      }

      final allPragas = _databaseRepo.gPragas.map((p) => p.toJson()).toList();
      if (allPragas.isEmpty) {
        throw StateError('Lista de pragas não inicializada');
      }

      final pragasOrdenadas =
          await _processAndOrderPragas(diagnosticos, allPragas);
      final formattedPragas = _formatPragasList(pragasOrdenadas);
      return formattedPragas;
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar pragas por cultura: $e\n$stackTrace');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _loadRecentItems(
      List<Map<String, dynamic>> allPragas) async {
    final accessedIds =
        await LocalStorageService().getRecentItems('acessadosPragas');
    final recentItems = _processRecentItems(accessedIds, allPragas);
    return recentItems.take(_maxRecentItems).toList();
  }

  Future<List<Map<String, dynamic>>> _processAndOrderPragas(
    List<Map<String, dynamic>> diagnosticos,
    List<Map<String, dynamic>> allPragas,
  ) async {
    final orderedDiags =
        Database().orderList(diagnosticos, 'fkIdPraga', null, true);
    final pragas = <Map<String, dynamic>>[];

    for (final diag in orderedDiags) {
      final praga = allPragas.firstWhere(
        (p) => p['idReg'] == diag['fkIdPraga'],
        orElse: () => {},
      );

      if (praga.isNotEmpty) {
        pragas.add(praga);
      }
    }

    return Database()
        .orderList(pragas, 'nomeComum', null, false)
        .cast<Map<String, dynamic>>();
  }

  void _processFields(
      List<Map<String, dynamic>> fields, List<Map<String, dynamic>> data) {
    for (var field in fields) {
      final listName = field['list']?.toString() ?? '';

      // Criando um InfoItem com os dados
      final infoItem = InfoItem(
        titulo: field['title']?.toString() ?? '',
        descricao:
            data.isEmpty ? ' - ' : data[0][field['key']]?.toString() ?? '-',
      );

      // Adicionando o item à lista apropriada na classe PragaUnica
      pragaUnica.addInfoItem(listName, infoItem);
    }
  }

  List<Map<String, dynamic>> _processePragasData(List<dynamic> data) {
    return data.map((row) {
      final nomeList = row['nomeComum'].split(';');
      return {
        'idReg': row['idReg'],
        'nomeComum': nomeList[0],
        'nomeSecundario': nomeList.sublist(1).join(),
        'nomeCientifico': row['nomeCientifico'],
        'nomeImagem': _formatImageName(row['nomeCientifico']),
        'tipoPraga': row['tipoPraga'],
      };
    }).toList();
  }

  List<Map<String, dynamic>> _processRecentItems(
    List<String> accessedIds,
    List<Map<String, dynamic>> allPragas,
  ) {
    final items = <Map<String, dynamic>>[];

    for (final id in accessedIds) {
      if (id.isEmpty) continue;

      try {
        final item = allPragas.firstWhere(
          (r) => r['idReg'] == id,
          orElse: () => {},
        );

        if (item.isNotEmpty) {
          items.add(_formatPragaName(item));
        }
      } catch (e) {
        debugPrint('Erro ao processar item com ID $id: $e');
        continue;
      }
    }

    return items;
  }

  List<Map<String, dynamic>> _processeDiagnosticosData(
      List<Map<String, dynamic>> data) {
    final processedData = <Map<String, dynamic>>[];

    for (final row in data) {
      // Busca informações relacionadas
      final defensivo = _databaseRepo.gFitossanitarios
          .map((f) => f.toJson())
          .firstWhere((f) => f['idReg'] == row['fkIdDefensivo'],
              orElse: () => {});

      final praga = _databaseRepo.gPragas
          .map((p) => p.toJson())
          .firstWhere((p) => p['idReg'] == row['fkIdPraga'], orElse: () => {});

      final cultura = _databaseRepo.gCulturas.map((c) => c.toJson()).firstWhere(
          (c) => c['idReg'] == row['fkIdCultura'],
          orElse: () => {});

      if (defensivo.isEmpty || praga.isEmpty || cultura.isEmpty) {
        continue; // Pula registros com dados incompletos
      }

      // Formata e adiciona o item
      processedData.add({
        ...row,
        'nomeDefensivo': defensivo['nomeComum'] ?? '',
        'nomePraga': praga['nomeComum'] ?? '',
        'nomeCultura': cultura['cultura'] ?? '',
        'dosagem': _formatDosagem(row['dsMin'], row['dsMax'], row['um']),
        'ingredienteAtivo': defensivo['ingredienteAtivo'] ?? '',
        'quantProduto': defensivo['quantProduto'] ?? '',
        'formulacao': defensivo['formulacao'] ?? '',
      });
    }

    // Ordena por cultura e depois por praga
    return Database()
        .orderList(processedData, 'nomeCultura', 'nomePraga', false)
        .cast<Map<String, dynamic>>();
  }

  String _formatDosagem(String? min, String? max, String? um) {
    final minVal = min ?? '';
    final maxVal = max ?? '';
    final unit = um ?? '';
    
    if (minVal.isEmpty && maxVal.isEmpty) {
      return 'Não especificado';
    }
    
    if (minVal == maxVal) {
      return '$minVal $unit';
    }
    
    if (minVal.isEmpty) {
      return 'até $maxVal $unit';
    }
    
    if (maxVal.isEmpty) {
      return 'a partir de $minVal $unit';
    }
    
    return '$minVal a $maxVal $unit';
  }

  void _resetPragaUnica() {
    pragaUnica.reset();
  }

  void _updatePragaUnica(Map<String, dynamic> data) {
    pragaUnica.updateFromMap(data);
  }
}
