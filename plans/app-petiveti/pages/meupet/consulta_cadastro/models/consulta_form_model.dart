// Project imports:
import '../../../../models/12_consulta_model.dart';

class ConsultaFormModel {
  String animalId;
  int dataConsulta;
  String veterinario;
  String motivo;
  String diagnostico;
  double valor;
  String? observacoes;

  ConsultaFormModel({
    this.animalId = '',
    int? dataConsulta,
    this.veterinario = '',
    this.motivo = '',
    this.diagnostico = '',
    this.valor = 0.0,
    this.observacoes = '',
  }) : dataConsulta = dataConsulta ?? DateTime.now().millisecondsSinceEpoch;

  factory ConsultaFormModel.fromConsulta(Consulta consulta) {
    return ConsultaFormModel(
      animalId: consulta.animalId,
      dataConsulta: consulta.dataConsulta,
      veterinario: consulta.veterinario,
      motivo: consulta.motivo,
      diagnostico: consulta.diagnostico,
      valor: consulta.valor,
      observacoes: consulta.observacoes,
    );
  }

  factory ConsultaFormModel.withAnimalId(String selectedAnimalId) {
    return ConsultaFormModel(
      animalId: selectedAnimalId,
      dataConsulta: DateTime.now().millisecondsSinceEpoch,
    );
  }

  ConsultaFormModel copyWith({
    String? animalId,
    int? dataConsulta,
    String? veterinario,
    String? motivo,
    String? diagnostico,
    double? valor,
    String? observacoes,
  }) {
    return ConsultaFormModel(
      animalId: animalId ?? this.animalId,
      dataConsulta: dataConsulta ?? this.dataConsulta,
      veterinario: veterinario ?? this.veterinario,
      motivo: motivo ?? this.motivo,
      diagnostico: diagnostico ?? this.diagnostico,
      valor: valor ?? this.valor,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  Consulta toConsulta({
    String? id,
    int? createdAt,
    Consulta? existingConsulta,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Consulta(
      id: id ?? '',
      createdAt: createdAt ?? now,
      updatedAt: now,
      isDeleted: false,
      needsSync: true,
      version: existingConsulta != null ? existingConsulta.version + 1 : 1,
      lastSyncAt: existingConsulta?.lastSyncAt,
      animalId: animalId,
      dataConsulta: dataConsulta,
      veterinario: veterinario,
      motivo: motivo,
      diagnostico: diagnostico,
      valor: valor,
      observacoes: observacoes?.isEmpty == true ? null : observacoes,
    );
  }

  void updateFromConsulta(Consulta consulta) {
    animalId = consulta.animalId;
    dataConsulta = consulta.dataConsulta;
    veterinario = consulta.veterinario;
    motivo = consulta.motivo;
    diagnostico = consulta.diagnostico;
    valor = consulta.valor;
    observacoes = consulta.observacoes;
  }

  void reset({String? selectedAnimalId}) {
    animalId = selectedAnimalId ?? '';
    dataConsulta = DateTime.now().millisecondsSinceEpoch;
    veterinario = '';
    motivo = '';
    diagnostico = '';
    valor = 0.0;
    observacoes = '';
  }

  bool get isValid {
    return _isValidAnimalId() &&
        _isValidVeterinario() &&
        _isValidMotivo() &&
        _isValidDiagnostico() &&
        _isValidDataConsulta() &&
        _isValidValor();
  }

  bool _isValidAnimalId() {
    return animalId.isNotEmpty;
  }

  bool _isValidVeterinario() {
    return veterinario.trim().isNotEmpty && veterinario.length <= 100;
  }

  bool _isValidMotivo() {
    return motivo.trim().isNotEmpty && motivo.length <= 255;
  }

  bool _isValidDiagnostico() {
    return diagnostico.trim().isNotEmpty && diagnostico.length <= 500;
  }

  bool _isValidObservacoes() {
    return observacoes == null || observacoes!.length <= 1000;
  }

  bool _isValidDataConsulta() {
    final now = DateTime.now();
    final data = DateTime.fromMillisecondsSinceEpoch(dataConsulta);
    final twoYearsAgo = now.subtract(const Duration(days: 730));
    final oneYearFromNow = now.add(const Duration(days: 365));

    return data.isAfter(twoYearsAgo) && data.isBefore(oneYearFromNow);
  }

  bool _isValidValor() {
    return valor >= 0 && valor <= 999999.99;
  }

  DateTime get dataDateTime =>
      DateTime.fromMillisecondsSinceEpoch(dataConsulta);

  String get dataFormatted {
    final date = dataDateTime;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get dataCompleta {
    final date = dataDateTime;
    return '$dataFormatted ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  bool validateVeterinario() {
    return _isValidVeterinario();
  }

  bool validateMotivo() {
    return _isValidMotivo();
  }

  bool validateDiagnostico() {
    return _isValidDiagnostico();
  }

  bool validateObservacoes() {
    return _isValidObservacoes();
  }

  bool validateAnimalId() {
    return _isValidAnimalId();
  }

  bool validateDataConsulta() {
    return _isValidDataConsulta();
  }

  bool validateValor() {
    return _isValidValor();
  }

  String? validateField(String field, dynamic value) {
    switch (field) {
      case 'animalId':
        if (value == null || value.isEmpty) {
          return 'Animal deve ser selecionado';
        }
        return null;
      case 'veterinario':
        if (value == null || value.trim().isEmpty) {
          return 'Veterinário é obrigatório';
        }
        if (value.length > 100) {
          return 'Nome muito longo (máx. 100 caracteres)';
        }
        return null;
      case 'motivo':
        if (value == null || value.trim().isEmpty) {
          return 'Motivo é obrigatório';
        }
        if (value.length > 255) {
          return 'Motivo muito longo (máx. 255 caracteres)';
        }
        return null;
      case 'diagnostico':
        if (value == null || value.trim().isEmpty) {
          return 'Diagnóstico é obrigatório';
        }
        if (value.length > 500) {
          return 'Diagnóstico muito longo (máx. 500 caracteres)';
        }
        return null;
      case 'observacoes':
        if (value != null && value.length > 1000) {
          return 'Observações muito longas (máx. 1000 caracteres)';
        }
        return null;
      case 'dataConsulta':
        if (value == null) {
          return 'Data é obrigatória';
        }
        if (!_isValidDataConsulta()) {
          return 'Data deve estar entre 2 anos atrás e 1 ano no futuro';
        }
        return null;
      case 'valor':
        if (value == null) {
          return 'Valor é obrigatório';
        }
        if (value < 0) {
          return 'Valor não pode ser negativo';
        }
        if (value > 999999.99) {
          return 'Valor muito alto (máx. R\$ 999.999,99)';
        }
        return null;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'animalId': animalId,
      'dataConsulta': dataConsulta,
      'veterinario': veterinario,
      'motivo': motivo,
      'diagnostico': diagnostico,
      'valor': valor,
      'observacoes': observacoes,
    };
  }

  factory ConsultaFormModel.fromJson(Map<String, dynamic> json) {
    return ConsultaFormModel(
      animalId: json['animalId'] ?? '',
      dataConsulta:
          json['dataConsulta'] ?? DateTime.now().millisecondsSinceEpoch,
      veterinario: json['veterinario'] ?? '',
      motivo: json['motivo'] ?? '',
      diagnostico: json['diagnostico'] ?? '',
      valor: json['valor']?.toDouble() ?? 0.0,
      observacoes: json['observacoes'],
    );
  }

  @override
  String toString() {
    return 'ConsultaFormModel(animalId: $animalId, dataConsulta: $dataFormatted, '
        'veterinario: $veterinario, motivo: $motivo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConsultaFormModel &&
        other.animalId == animalId &&
        other.dataConsulta == dataConsulta &&
        other.veterinario == veterinario &&
        other.motivo == motivo &&
        other.diagnostico == diagnostico &&
        other.valor == valor &&
        other.observacoes == observacoes;
  }

  @override
  int get hashCode {
    return animalId.hashCode ^
        dataConsulta.hashCode ^
        veterinario.hashCode ^
        motivo.hashCode ^
        diagnostico.hashCode ^
        valor.hashCode ^
        observacoes.hashCode;
  }

  /// Formats the valor field for display
  String get valorFormatted {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Parses a string value to double, handling Brazilian currency format
  static double parseValor(String value) {
    // Remove currency symbols and normalize decimal separator
    final normalized = value
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .trim();

    return double.tryParse(normalized) ?? 0.0;
  }
}
