import 'package:flutter/foundation.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/repositories/cultura_hive_repository.dart';
import '../../../../core/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/repositories/pragas_hive_repository.dart';
import '../../../../core/services/diagnostico_integration_service.dart';

/// Provider especializado para gerenciar estado complexo da busca avançada
class BuscaAvancadaProvider with ChangeNotifier {
  final DiagnosticoIntegrationService _integrationService = sl<DiagnosticoIntegrationService>();
  final CulturaHiveRepository _culturaRepo = sl<CulturaHiveRepository>();
  final PragasHiveRepository _pragasRepo = sl<PragasHiveRepository>();
  final FitossanitarioHiveRepository _fitossanitarioRepo = sl<FitossanitarioHiveRepository>();

  // Estados da busca
  bool _isLoading = false;
  bool _hasError = false;
  bool _hasSearched = false;
  String? _errorMessage;

  // Filtros selecionados
  String? _culturaIdSelecionada;
  String? _pragaIdSelecionada;
  String? _defensivoIdSelecionado;

  // Resultados
  List<DiagnosticoDetalhado> _resultados = [];

  // Dados para dropdowns
  List<Map<String, String>> _culturas = [];
  List<Map<String, String>> _pragas = [];
  List<Map<String, String>> _defensivos = [];
  bool _dadosCarregados = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get hasSearched => _hasSearched;
  String? get errorMessage => _errorMessage;
  String? get culturaIdSelecionada => _culturaIdSelecionada;
  String? get pragaIdSelecionada => _pragaIdSelecionada;
  String? get defensivoIdSelecionado => _defensivoIdSelecionado;
  List<DiagnosticoDetalhado> get resultados => _resultados;
  List<Map<String, String>> get culturas => _culturas;
  List<Map<String, String>> get pragas => _pragas;
  List<Map<String, String>> get defensivos => _defensivos;
  bool get dadosCarregados => _dadosCarregados;

  // Estado computado
  bool get temFiltrosAtivos => 
    _culturaIdSelecionada != null || 
    _pragaIdSelecionada != null || 
    _defensivoIdSelecionado != null;

  bool get temResultados => _resultados.isNotEmpty;

  String get filtrosAtivosTexto {
    final filtros = <String>[];
    if (_culturaIdSelecionada != null) filtros.add('Cultura');
    if (_pragaIdSelecionada != null) filtros.add('Praga');
    if (_defensivoIdSelecionado != null) filtros.add('Defensivo');
    return filtros.join(', ');
  }

  Map<String, String> get filtrosDetalhados {
    final filtros = <String, String>{};
    
    if (_culturaIdSelecionada != null) {
      final cultura = _culturas.firstWhere(
        (c) => c['id'] == _culturaIdSelecionada,
        orElse: () => {'nome': 'Desconhecida'},
      );
      filtros['Cultura'] = cultura['nome']!;
    }
    
    if (_pragaIdSelecionada != null) {
      final praga = _pragas.firstWhere(
        (p) => p['id'] == _pragaIdSelecionada,
        orElse: () => {'nome': 'Desconhecida'},
      );
      filtros['Praga'] = praga['nome']!;
    }
    
    if (_defensivoIdSelecionado != null) {
      final defensivo = _defensivos.firstWhere(
        (d) => d['id'] == _defensivoIdSelecionado,
        orElse: () => {'nome': 'Desconhecido'},
      );
      filtros['Defensivo'] = defensivo['nome']!;
    }
    
    return filtros;
  }

  /// Carrega dados iniciais dos dropdowns
  Future<void> carregarDadosDropdowns() async {
    if (_dadosCarregados) return;
    
    try {
      // Carregar culturas
      final culturas = _culturaRepo.getAll();
      _culturas = culturas.map((c) => {
        'id': c.idReg,
        'nome': c.cultura,
      }).toList()..sort((a, b) => a['nome']!.compareTo(b['nome']!));

      // Carregar pragas
      final pragas = _pragasRepo.getAll();
      _pragas = pragas.map((p) => {
        'id': p.idReg,
        'nome': p.nomeComum.isNotEmpty ? p.nomeComum : p.nomeCientifico,
      }).toList()..sort((a, b) => a['nome']!.compareTo(b['nome']!));

      // Carregar defensivos
      final defensivos = _fitossanitarioRepo.getAll();
      _defensivos = defensivos.map((d) => {
        'id': d.idReg,
        'nome': d.nomeComum.isNotEmpty ? d.nomeComum : d.nomeTecnico,
      }).toList()..sort((a, b) => a['nome']!.compareTo(b['nome']!));

      _dadosCarregados = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar dados dos dropdowns: $e');
    }
  }

  /// Atualiza filtro de cultura
  void setCulturaId(String? id) {
    if (_culturaIdSelecionada != id) {
      _culturaIdSelecionada = id;
      notifyListeners();
    }
  }

  /// Atualiza filtro de praga
  void setPragaId(String? id) {
    if (_pragaIdSelecionada != id) {
      _pragaIdSelecionada = id;
      notifyListeners();
    }
  }

  /// Atualiza filtro de defensivo
  void setDefensivoId(String? id) {
    if (_defensivoIdSelecionado != id) {
      _defensivoIdSelecionado = id;
      notifyListeners();
    }
  }

  /// Realiza busca com filtros atuais
  Future<String?> realizarBusca() async {
    if (!temFiltrosAtivos) {
      return 'Selecione pelo menos um filtro para realizar a busca';
    }

    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final resultados = await _integrationService.buscarComFiltros(
        culturaId: _culturaIdSelecionada,
        pragaId: _pragaIdSelecionada,
        defensivoId: _defensivoIdSelecionado,
      );

      _isLoading = false;
      _hasSearched = true;
      _resultados = resultados;
      notifyListeners();
      
      return null; // Sucesso
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Erro ao realizar busca: $e';
      notifyListeners();
      
      return _errorMessage;
    }
  }

  /// Limpa todos os filtros e resultados
  void limparFiltros() {
    _culturaIdSelecionada = null;
    _pragaIdSelecionada = null;
    _defensivoIdSelecionado = null;
    _resultados.clear();
    _hasSearched = false;
    _hasError = false;
    _errorMessage = null;

    // Limpar cache do serviço
    _integrationService.clearCache();
    
    notifyListeners();
  }

  /// Reset do estado de erro
  void clearError() {
    if (_hasError) {
      _hasError = false;
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Cleanup resources se necessário
    super.dispose();
  }
}