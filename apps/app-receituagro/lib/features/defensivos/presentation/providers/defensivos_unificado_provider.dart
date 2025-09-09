import 'package:flutter/foundation.dart';

import '../../domain/entities/defensivo_entity.dart';
import '../../domain/usecases/get_defensivos_agrupados_usecase.dart';
import '../../domain/usecases/get_defensivos_completos_usecase.dart';
import '../../domain/usecases/get_defensivos_com_filtros_usecase.dart';

/// Provider unificado para gerenciar defensivos
/// Consolida funcionalidades de defensivos individuais e agrupados
/// Segue arquitetura SOLID e Clean Architecture
class DefensivosUnificadoProvider extends ChangeNotifier {
  final GetDefensivosAgrupadosUseCase _getDefensivosAgrupadosUseCase;
  final GetDefensivosCompletosUseCase _getDefensivosCompletosUseCase;
  final GetDefensivosComFiltrosUseCase _getDefensivosComFiltrosUseCase;

  DefensivosUnificadoProvider({
    required GetDefensivosAgrupadosUseCase getDefensivosAgrupadosUseCase,
    required GetDefensivosCompletosUseCase getDefensivosCompletosUseCase,
    required GetDefensivosComFiltrosUseCase getDefensivosComFiltrosUseCase,
  }) : _getDefensivosAgrupadosUseCase = getDefensivosAgrupadosUseCase,
       _getDefensivosCompletosUseCase = getDefensivosCompletosUseCase,
       _getDefensivosComFiltrosUseCase = getDefensivosComFiltrosUseCase;

  // Estados
  List<DefensivoEntity> _defensivos = [];
  List<DefensivoEntity> _defensivosFiltrados = [];
  List<DefensivoEntity> _defensivosSelecionados = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filtros e configurações
  String _tipoAgrupamento = 'classe';
  String _filtroTexto = '';
  String _ordenacao = 'prioridade';
  String _filtroToxicidade = 'todos';
  String _filtroTipo = 'todos';
  bool _apenasComercializados = true;
  bool _apenasElegiveis = false;
  bool _modoComparacao = false;

  // Getters
  List<DefensivoEntity> get defensivos => _defensivos;
  List<DefensivoEntity> get defensivosFiltrados => _defensivosFiltrados;
  List<DefensivoEntity> get defensivosSelecionados => _defensivosSelecionados;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  
  String get tipoAgrupamento => _tipoAgrupamento;
  String get filtroTexto => _filtroTexto;
  String get ordenacao => _ordenacao;
  String get filtroToxicidade => _filtroToxicidade;
  String get filtroTipo => _filtroTipo;
  bool get apenasComercializados => _apenasComercializados;
  bool get apenasElegiveis => _apenasElegiveis;
  bool get modoComparacao => _modoComparacao;

  /// Carrega defensivos agrupados por tipo
  Future<void> carregarDefensivosAgrupados({
    required String tipoAgrupamento,
    String? filtroTexto,
  }) async {
    _setLoading(true);
    _tipoAgrupamento = tipoAgrupamento;
    _filtroTexto = filtroTexto ?? '';
    
    final result = await _getDefensivosAgrupadosUseCase(
      tipoAgrupamento: tipoAgrupamento,
      filtroTexto: filtroTexto,
    );
    
    result.fold(
      (failure) => _setError('Erro ao carregar defensivos: ${failure.message}'),
      (defensivos) {
        _defensivos = defensivos;
        _defensivosFiltrados = defensivos;
        _setLoading(false);
      },
    );
  }

  /// Carrega defensivos completos para comparação
  Future<void> carregarDefensivosCompletos() async {
    _setLoading(true);
    
    final result = await _getDefensivosCompletosUseCase();
    
    result.fold(
      (failure) => _setError('Erro ao carregar defensivos: ${failure.message}'),
      (defensivos) {
        _defensivos = defensivos;
        _aplicarFiltros();
        _setLoading(false);
      },
    );
  }

  /// Aplica filtros avançados aos defensivos
  Future<void> aplicarFiltrosAvancados() async {
    _setLoading(true);
    
    final result = await _getDefensivosComFiltrosUseCase(
      ordenacao: _ordenacao,
      filtroToxicidade: _filtroToxicidade,
      filtroTipo: _filtroTipo,
      apenasComercializados: _apenasComercializados,
      apenasElegiveis: _apenasElegiveis,
    );
    
    result.fold(
      (failure) => _setError('Erro ao filtrar defensivos: ${failure.message}'),
      (defensivos) {
        _defensivosFiltrados = defensivos;
        _setLoading(false);
      },
    );
  }

  /// Aplica filtros localmente (mais rápido para mudanças simples)
  void _aplicarFiltros() {
    var filtrados = List<DefensivoEntity>.from(_defensivos);
    
    // Filtro por texto
    if (_filtroTexto.isNotEmpty) {
      filtrados = filtrados.where((d) {
        final texto = _filtroTexto.toLowerCase();
        return d.displayName.toLowerCase().contains(texto) ||
               d.displayIngredient.toLowerCase().contains(texto) ||
               d.displayFabricante.toLowerCase().contains(texto) ||
               d.displayClass.toLowerCase().contains(texto);
      }).toList();
    }
    
    _defensivosFiltrados = filtrados;
    notifyListeners();
  }

  /// Atualiza filtros e aplica
  void atualizarFiltros({
    String? ordenacao,
    String? filtroToxicidade,
    String? filtroTipo,
    bool? apenasComercializados,
    bool? apenasElegiveis,
    String? filtroTexto,
  }) {
    bool changed = false;
    
    if (ordenacao != null && ordenacao != _ordenacao) {
      _ordenacao = ordenacao;
      changed = true;
    }
    
    if (filtroToxicidade != null && filtroToxicidade != _filtroToxicidade) {
      _filtroToxicidade = filtroToxicidade;
      changed = true;
    }
    
    if (filtroTipo != null && filtroTipo != _filtroTipo) {
      _filtroTipo = filtroTipo;
      changed = true;
    }
    
    if (apenasComercializados != null && apenasComercializados != _apenasComercializados) {
      _apenasComercializados = apenasComercializados;
      changed = true;
    }
    
    if (apenasElegiveis != null && apenasElegiveis != _apenasElegiveis) {
      _apenasElegiveis = apenasElegiveis;
      changed = true;
    }
    
    if (filtroTexto != null && filtroTexto != _filtroTexto) {
      _filtroTexto = filtroTexto;
      changed = true;
    }
    
    if (changed) {
      aplicarFiltrosAvancados();
    }
  }

  /// Limpa todos os filtros
  void limparFiltros() {
    _ordenacao = 'prioridade';
    _filtroToxicidade = 'todos';
    _filtroTipo = 'todos';
    _apenasComercializados = false;
    _apenasElegiveis = false;
    _filtroTexto = '';
    
    aplicarFiltrosAvancados();
  }

  /// Toggle modo comparação
  void toggleModoComparacao() {
    _modoComparacao = !_modoComparacao;
    if (!_modoComparacao) {
      _defensivosSelecionados.clear();
    }
    notifyListeners();
  }

  /// Seleciona/deseleciona defensivo para comparação
  void toggleSelecaoDefensivo(DefensivoEntity defensivo) {
    if (_defensivosSelecionados.contains(defensivo)) {
      _defensivosSelecionados.remove(defensivo);
    } else if (_defensivosSelecionados.length < 3) {
      _defensivosSelecionados.add(defensivo);
    }
    notifyListeners();
  }

  /// Limpa seleção de defensivos
  void limparSelecao() {
    _defensivosSelecionados.clear();
    notifyListeners();
  }

  /// Métodos privados para gerenciar estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _isLoading = false;
    _errorMessage = error;
    notifyListeners();
  }

  /// Recarrega dados
  Future<void> reload() async {
    if (_modoComparacao) {
      return carregarDefensivosCompletos();
    } else {
      return carregarDefensivosAgrupados(
        tipoAgrupamento: _tipoAgrupamento,
        filtroTexto: _filtroTexto.isNotEmpty ? _filtroTexto : null,
      );
    }
  }
}