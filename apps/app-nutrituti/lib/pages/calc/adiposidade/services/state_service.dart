// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../model/adiposidade_model.dart';

/// Estados possíveis da aplicação
enum AdiposidadeAppState {
  initial,
  inputting,
  validating,
  calculating,
  calculated,
  error,
  sharing,
}

/// Estado de um campo específico
class FieldState {
  final String value;
  final String? error;
  final bool isValid;
  final bool isValidating;
  final DateTime lastModified;

  FieldState({
    required this.value,
    this.error,
    this.isValid = false,
    this.isValidating = false,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.fromMillisecondsSinceEpoch(0);

  FieldState copyWith({
    String? value,
    String? error,
    bool? isValid,
    bool? isValidating,
    DateTime? lastModified,
  }) {
    return FieldState(
      value: value ?? this.value,
      error: error,
      isValid: isValid ?? this.isValid,
      isValidating: isValidating ?? this.isValidating,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  factory FieldState.empty() {
    return FieldState(value: '');
  }

  factory FieldState.withValue(String value) {
    return FieldState(value: value, lastModified: DateTime.now());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FieldState &&
        other.value == value &&
        other.error == error &&
        other.isValid == isValid &&
        other.isValidating == isValidating;
  }

  @override
  int get hashCode {
    return Object.hash(value, error, isValid, isValidating);
  }
}

/// Estado completo da aplicação adiposidade
class AdiposidadeState {
  final AdiposidadeAppState appState;
  final FieldState quadrilState;
  final FieldState alturaState;
  final FieldState idadeState;
  final int generoSelecionado;
  final AdipososidadeModel? resultado;
  final String? globalError;
  final List<String> warnings;
  final DateTime lastCalculation;
  final bool hasChangedSinceLastCalculation;

  AdiposidadeState({
    this.appState = AdiposidadeAppState.initial,
    FieldState? quadrilState,
    FieldState? alturaState,
    FieldState? idadeState,
    this.generoSelecionado = 1,
    this.resultado,
    this.globalError,
    this.warnings = const [],
    DateTime? lastCalculation,
    this.hasChangedSinceLastCalculation = false,
  })  : quadrilState = quadrilState ?? FieldState(value: ''),
        alturaState = alturaState ?? FieldState(value: ''),
        idadeState = idadeState ?? FieldState(value: ''),
        lastCalculation =
            lastCalculation ?? DateTime.fromMillisecondsSinceEpoch(0);

  AdiposidadeState copyWith({
    AdiposidadeAppState? appState,
    FieldState? quadrilState,
    FieldState? alturaState,
    FieldState? idadeState,
    int? generoSelecionado,
    AdipososidadeModel? resultado,
    String? globalError,
    List<String>? warnings,
    DateTime? lastCalculation,
    bool? hasChangedSinceLastCalculation,
  }) {
    return AdiposidadeState(
      appState: appState ?? this.appState,
      quadrilState: quadrilState ?? this.quadrilState,
      alturaState: alturaState ?? this.alturaState,
      idadeState: idadeState ?? this.idadeState,
      generoSelecionado: generoSelecionado ?? this.generoSelecionado,
      resultado: resultado ?? this.resultado,
      globalError: globalError,
      warnings: warnings ?? this.warnings,
      lastCalculation: lastCalculation ?? this.lastCalculation,
      hasChangedSinceLastCalculation:
          hasChangedSinceLastCalculation ?? this.hasChangedSinceLastCalculation,
    );
  }

  factory AdiposidadeState.initial() {
    return AdiposidadeState();
  }

  /// Verifica se todos os campos obrigatórios estão preenchidos
  bool get hasAllRequiredFields {
    return quadrilState.value.isNotEmpty &&
        alturaState.value.isNotEmpty &&
        idadeState.value.isNotEmpty;
  }

  /// Verifica se todos os campos são válidos
  bool get areAllFieldsValid {
    return quadrilState.isValid && alturaState.isValid && idadeState.isValid;
  }

  /// Verifica se pode calcular (todos campos válidos e sem validação em andamento)
  bool get canCalculate {
    return hasAllRequiredFields &&
        areAllFieldsValid &&
        !quadrilState.isValidating &&
        !alturaState.isValidating &&
        !idadeState.isValidating;
  }

  /// Verifica se tem resultado válido
  bool get hasValidResult {
    return resultado != null && appState == AdiposidadeAppState.calculated;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdiposidadeState &&
        other.appState == appState &&
        other.quadrilState == quadrilState &&
        other.alturaState == alturaState &&
        other.idadeState == idadeState &&
        other.generoSelecionado == generoSelecionado &&
        other.resultado == resultado &&
        other.globalError == globalError &&
        listEquals(other.warnings, warnings) &&
        other.hasChangedSinceLastCalculation == hasChangedSinceLastCalculation;
  }

  @override
  int get hashCode {
    return Object.hash(
      appState,
      quadrilState,
      alturaState,
      idadeState,
      generoSelecionado,
      resultado,
      globalError,
      Object.hashAll(warnings),
      hasChangedSinceLastCalculation,
    );
  }
}

/// Service para gerenciamento eficiente do estado
class AdiposidadeStateService extends ChangeNotifier {
  AdiposidadeState _state = AdiposidadeState.initial();

  // Stream controllers para diferentes aspectos do estado
  final StreamController<AdiposidadeState> _stateController =
      StreamController.broadcast();
  final StreamController<FieldState> _quadrilController =
      StreamController.broadcast();
  final StreamController<FieldState> _alturaController =
      StreamController.broadcast();
  final StreamController<FieldState> _idadeController =
      StreamController.broadcast();
  final StreamController<AdipososidadeModel?> _resultController =
      StreamController.broadcast();

  // Cache para evitar recalculos desnecessários
  final Map<String, dynamic> _cache = {};
  static const int _maxCacheSize = 50;

  // Getters para o estado
  AdiposidadeState get state => _state;
  FieldState get quadrilState => _state.quadrilState;
  FieldState get alturaState => _state.alturaState;
  FieldState get idadeState => _state.idadeState;
  int get generoSelecionado => _state.generoSelecionado;
  AdipososidadeModel? get resultado => _state.resultado;
  AdiposidadeAppState get appState => _state.appState;

  // Streams para reatividade granular
  Stream<AdiposidadeState> get stateStream => _stateController.stream;
  Stream<FieldState> get quadrilStream => _quadrilController.stream;
  Stream<FieldState> get alturaStream => _alturaController.stream;
  Stream<FieldState> get idadeStream => _idadeController.stream;
  Stream<AdipososidadeModel?> get resultStream => _resultController.stream;

  /// Atualiza o estado de forma eficiente
  void _updateState(AdiposidadeState newState) {
    final oldState = _state;
    _state = newState;

    // Notifica apenas se o estado realmente mudou
    if (oldState != newState) {
      notifyListeners();
      _stateController.add(newState);

      // Notifica streams específicos apenas se os campos específicos mudaram
      if (oldState.quadrilState != newState.quadrilState) {
        _quadrilController.add(newState.quadrilState);
      }
      if (oldState.alturaState != newState.alturaState) {
        _alturaController.add(newState.alturaState);
      }
      if (oldState.idadeState != newState.idadeState) {
        _idadeController.add(newState.idadeState);
      }
      if (oldState.resultado != newState.resultado) {
        _resultController.add(newState.resultado);
      }
    }
  }

  /// Atualiza o campo de quadril
  void updateQuadril(String value,
      {String? error, bool? isValid, bool? isValidating}) {
    final newFieldState = _state.quadrilState.copyWith(
      value: value,
      error: error,
      isValid: isValid,
      isValidating: isValidating,
    );

    _updateState(_state.copyWith(
      quadrilState: newFieldState,
      appState: AdiposidadeAppState.inputting,
      hasChangedSinceLastCalculation: true,
    ));
  }

  /// Atualiza o campo de altura
  void updateAltura(String value,
      {String? error, bool? isValid, bool? isValidating}) {
    final newFieldState = _state.alturaState.copyWith(
      value: value,
      error: error,
      isValid: isValid,
      isValidating: isValidating,
    );

    _updateState(_state.copyWith(
      alturaState: newFieldState,
      appState: AdiposidadeAppState.inputting,
      hasChangedSinceLastCalculation: true,
    ));
  }

  /// Atualiza o campo de idade
  void updateIdade(String value,
      {String? error, bool? isValid, bool? isValidating}) {
    final newFieldState = _state.idadeState.copyWith(
      value: value,
      error: error,
      isValid: isValid,
      isValidating: isValidating,
    );

    _updateState(_state.copyWith(
      idadeState: newFieldState,
      appState: AdiposidadeAppState.inputting,
      hasChangedSinceLastCalculation: true,
    ));
  }

  /// Atualiza o gênero selecionado
  void updateGenero(int genero) {
    if (_state.generoSelecionado != genero) {
      _updateState(_state.copyWith(
        generoSelecionado: genero,
        hasChangedSinceLastCalculation: true,
      ));
    }
  }

  /// Define o estado de validação
  void setValidatingState() {
    _updateState(_state.copyWith(
      appState: AdiposidadeAppState.validating,
    ));
  }

  /// Define o estado de cálculo
  void setCalculatingState() {
    _updateState(_state.copyWith(
      appState: AdiposidadeAppState.calculating,
    ));
  }

  /// Define o resultado do cálculo
  void setCalculationResult(AdipososidadeModel resultado,
      {List<String>? warnings}) {
    // Gera chave de cache
    final cacheKey = _generateCacheKey();
    _addToCache(cacheKey, resultado);

    _updateState(_state.copyWith(
      appState: AdiposidadeAppState.calculated,
      resultado: resultado,
      warnings: warnings ?? [],
      lastCalculation: DateTime.now(),
      hasChangedSinceLastCalculation: false,
      globalError: null,
    ));
  }

  /// Define estado de erro
  void setErrorState(String error) {
    _updateState(_state.copyWith(
      appState: AdiposidadeAppState.error,
      globalError: error,
    ));
  }

  /// Define estado de compartilhamento
  void setSharingState() {
    _updateState(_state.copyWith(
      appState: AdiposidadeAppState.sharing,
    ));
  }

  /// Limpa todos os campos e reinicia o estado
  void clearAll() {
    _updateState(AdiposidadeState.initial());
    _clearCache();
  }

  /// Verifica se existe resultado em cache
  AdipososidadeModel? getCachedResult() {
    final cacheKey = _generateCacheKey();
    return _cache[cacheKey] as AdipososidadeModel?;
  }

  /// Gera chave de cache baseada nos valores atuais
  String _generateCacheKey() {
    return '${_state.quadrilState.value}_${_state.alturaState.value}_${_state.idadeState.value}_${_state.generoSelecionado}';
  }

  /// Adiciona resultado ao cache
  void _addToCache(String key, AdipososidadeModel result) {
    // Limita o tamanho do cache
    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = result;
  }

  /// Limpa o cache
  void _clearCache() {
    _cache.clear();
  }

  /// Obtém estatísticas do estado para debugging
  Map<String, dynamic> getStateStats() {
    return {
      'currentAppState': _state.appState.name,
      'hasAllRequiredFields': _state.hasAllRequiredFields,
      'areAllFieldsValid': _state.areAllFieldsValid,
      'canCalculate': _state.canCalculate,
      'hasValidResult': _state.hasValidResult,
      'cacheSize': _cache.length,
      'lastCalculation': _state.lastCalculation.toIso8601String(),
      'hasChangedSinceLastCalculation': _state.hasChangedSinceLastCalculation,
      'warningsCount': _state.warnings.length,
    };
  }

  /// Backup do estado atual
  Map<String, dynamic> backupState() {
    return {
      'quadril': _state.quadrilState.value,
      'altura': _state.alturaState.value,
      'idade': _state.idadeState.value,
      'genero': _state.generoSelecionado,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Restaura estado do backup
  void restoreState(Map<String, dynamic> backup) {
    _updateState(_state.copyWith(
      quadrilState: FieldState.withValue(backup['quadril'] as String? ?? ''),
      alturaState: FieldState.withValue(backup['altura'] as String? ?? ''),
      idadeState: FieldState.withValue(backup['idade'] as String? ?? ''),
      generoSelecionado: (backup['genero'] as num?)?.toInt() ?? 1,
      appState: AdiposidadeAppState.inputting,
    ));
  }

  @override
  void dispose() {
    _stateController.close();
    _quadrilController.close();
    _alturaController.close();
    _idadeController.close();
    _resultController.close();
    _clearCache();
    super.dispose();
  }
}
