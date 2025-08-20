// Project imports:
import '../../../../models/13_despesa_model.dart';
import '../config/despesa_config.dart';

// Legacy DespesaConstants class - now uses DespesaConfig
// Kept for backward compatibility
class DespesaConstants {
  static double get maxWidth => DespesaConfig.maxFormWidth;
  static double get maxHeight => DespesaConfig.maxFormHeight;
  static int get descricaoMaxLength => DespesaConfig.descricaoMaxLength;
  static int get descricaoMinLength => DespesaConfig.descricaoMinLength;
  static double get valorMinimo => DespesaConfig.valorMinimo;
  static double get valorMaximo => DespesaConfig.valorMaximo;
  static List<String> get tiposDespesa => DespesaConfig.tiposDespesa;
}

class DespesaFormModel {
  String animalId;
  int dataDespesa;
  String tipo;
  String descricao;
  double valor;

  DespesaFormModel({
    this.animalId = '',
    int? dataDespesa,
    String? tipo,
    this.descricao = '',
    this.valor = 0.0,
  }) : dataDespesa = dataDespesa ?? DateTime.now().millisecondsSinceEpoch,
       tipo = tipo ?? DespesaConfig.defaultTipo;

  factory DespesaFormModel.fromDespesa(DespesaVet despesa) {
    return DespesaFormModel(
      animalId: despesa.animalId,
      dataDespesa: despesa.dataDespesa,
      tipo: despesa.tipo,
      descricao: despesa.descricao,
      valor: despesa.valor,
    );
  }

  factory DespesaFormModel.withAnimalId(String selectedAnimalId) {
    return DespesaFormModel(
      animalId: selectedAnimalId,
      dataDespesa: DateTime.now().millisecondsSinceEpoch,
      tipo: DespesaConfig.defaultTipo,
    );
  }

  DespesaFormModel copyWith({
    String? animalId,
    int? dataDespesa,
    String? tipo,
    String? descricao,
    double? valor,
  }) {
    return DespesaFormModel(
      animalId: animalId ?? this.animalId,
      dataDespesa: dataDespesa ?? this.dataDespesa,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
    );
  }

  DespesaVet toDespesa({
    String? id,
    int? createdAt,
    int? version,
    int? lastSyncAt,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return DespesaVet(
      id: id ?? '',
      createdAt: createdAt ?? now,
      updatedAt: now,
      isDeleted: false,
      needsSync: true,
      version: version ?? 1,
      lastSyncAt: lastSyncAt,
      animalId: animalId,
      dataDespesa: dataDespesa,
      tipo: tipo,
      descricao: descricao,
      valor: valor,
    );
  }

  void updateFromDespesa(DespesaVet despesa) {
    animalId = despesa.animalId;
    dataDespesa = despesa.dataDespesa;
    tipo = despesa.tipo;
    descricao = despesa.descricao;
    valor = despesa.valor;
  }

  void reset({String? selectedAnimalId}) {
    animalId = selectedAnimalId ?? '';
    dataDespesa = DateTime.now().millisecondsSinceEpoch;
    tipo = DespesaConfig.defaultTipo;
    descricao = '';
    valor = DespesaConfig.defaultValor;
  }

  bool get isValid {
    return _isValidAnimalId() &&
           _isValidTipo() &&
           _isValidValor() &&
           _isValidDescricao() &&
           _isValidDataDespesa();
  }

  bool _isValidAnimalId() {
    return animalId.isNotEmpty;
  }

  bool _isValidTipo() {
    return tipo.isNotEmpty && DespesaConstants.tiposDespesa.contains(tipo);
  }

  bool _isValidValor() {
    return valor >= DespesaConstants.valorMinimo && valor <= DespesaConstants.valorMaximo;
  }

  bool _isValidDescricao() {
    return descricao.length <= DespesaConstants.descricaoMaxLength;
  }

  bool _isValidDataDespesa() {
    final now = DateTime.now();
    final data = DateTime.fromMillisecondsSinceEpoch(dataDespesa);
    final oneYearAgo = now.subtract(const Duration(days: 365));
    final oneYearFromNow = now.add(const Duration(days: 365));
    
    return data.isAfter(oneYearAgo) && data.isBefore(oneYearFromNow);
  }

  List<String> get tiposDespesaOptions => DespesaConstants.tiposDespesa;

  DateTime get dataDateTime => DateTime.fromMillisecondsSinceEpoch(dataDespesa);

  String get valorFormatted {
    return valor.toStringAsFixed(DespesaConfig.valorDecimalPlaces)
        .replaceAll('.', DespesaConfig.decimalSeparator);
  }

  String get valorComMoeda {
    return DespesaConfig.formatCurrency(valor);
  }

  String get dataFormatted {
    final date = dataDateTime;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get tipoIcon {
    switch (tipo.toLowerCase()) {
      case 'consulta':
        return '🏥';
      case 'medicamento':
        return '💊';
      case 'vacina':
        return '💉';
      case 'exame':
        return '🔬';
      case 'cirurgia':
        return '⚕️';
      case 'emergência':
        return '🚨';
      case 'banho e tosa':
        return '🛁';
      case 'alimentação':
        return '🍽️';
      case 'petiscos':
        return '🦴';
      case 'brinquedos':
        return '🎾';
      case 'acessórios':
        return '🎀';
      case 'hospedagem':
        return '🏠';
      case 'transporte':
        return '🚗';
      case 'seguro':
        return '🛡️';
      default:
        return '📝';
    }
  }

  bool validateValor() {
    return _isValidValor();
  }

  bool validateDescricao() {
    return _isValidDescricao();
  }

  bool validateTipo() {
    return _isValidTipo();
  }

  bool validateAnimalId() {
    return _isValidAnimalId();
  }

  bool validateDataDespesa() {
    return _isValidDataDespesa();
  }

  String? validateField(String field, dynamic value) {
    switch (field) {
      case 'animalId':
        if (value == null || value.isEmpty) {
          return 'Animal deve ser selecionado';
        }
        return null;
      case 'valor':
        if (value == null || value <= 0) {
          return 'O valor deve ser maior que zero';
        }
        if (value > DespesaConstants.valorMaximo) {
          return 'Valor muito alto (máx. R\$ ${DespesaConstants.valorMaximo.toStringAsFixed(2).replaceAll('.', ',')})';
        }
        return null;
      case 'tipo':
        if (value == null || value.isEmpty) {
          return 'Selecione um tipo de despesa';
        }
        if (!DespesaConstants.tiposDespesa.contains(value)) {
          return 'Tipo de despesa inválido';
        }
        return null;
      case 'descricao':
        if (value != null && value.length > DespesaConstants.descricaoMaxLength) {
          return 'Descrição muito longa (máx. ${DespesaConstants.descricaoMaxLength} caracteres)';
        }
        return null;
      case 'dataDespesa':
        if (value == null) {
          return 'Data é obrigatória';
        }
        if (!_isValidDataDespesa()) {
          return 'Data deve estar entre 1 ano atrás e 1 ano no futuro';
        }
        return null;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'animalId': animalId,
      'dataDespesa': dataDespesa,
      'tipo': tipo,
      'descricao': descricao,
      'valor': valor,
    };
  }

  factory DespesaFormModel.fromJson(Map<String, dynamic> json) {
    return DespesaFormModel(
      animalId: json['animalId'] ?? '',
      dataDespesa: json['dataDespesa'] ?? DateTime.now().millisecondsSinceEpoch,
      tipo: json['tipo'] ?? DespesaConstants.tiposDespesa.first,
      descricao: json['descricao'] ?? '',
      valor: (json['valor'] ?? 0.0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'DespesaFormModel(animalId: $animalId, dataDespesa: $dataFormatted, '
           'tipo: $tipo, descricao: $descricao, valor: $valorComMoeda)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DespesaFormModel &&
        other.animalId == animalId &&
        other.dataDespesa == dataDespesa &&
        other.tipo == tipo &&
        other.descricao == descricao &&
        other.valor == valor;
  }

  @override
  int get hashCode {
    return animalId.hashCode ^
        dataDespesa.hashCode ^
        tipo.hashCode ^
        descricao.hashCode ^
        valor.hashCode;
  }
}
