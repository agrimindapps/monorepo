// Project imports:
import '../../../../models/11_animal_model.dart';

class AnimalCreationModel {
  final String sessionId;
  final DateTime createdAt;
  final AnimalFormData formData;
  final List<String> validationErrors;
  final Map<String, dynamic> metadata;

  const AnimalCreationModel({
    required this.sessionId,
    required this.createdAt,
    required this.formData,
    this.validationErrors = const [],
    this.metadata = const {},
  });

  AnimalCreationModel copyWith({
    String? sessionId,
    DateTime? createdAt,
    AnimalFormData? formData,
    List<String>? validationErrors,
    Map<String, dynamic>? metadata,
  }) {
    return AnimalCreationModel(
      sessionId: sessionId ?? this.sessionId,
      createdAt: createdAt ?? this.createdAt,
      formData: formData ?? this.formData,
      validationErrors: validationErrors ?? this.validationErrors,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isValid => validationErrors.isEmpty && formData.isValid;
  bool get hasErrors => validationErrors.isNotEmpty;
  int get errorCount => validationErrors.length;

  AnimalCreationModel addError(String error) {
    return copyWith(
      validationErrors: [...validationErrors, error],
    );
  }

  AnimalCreationModel removeError(String error) {
    return copyWith(
      validationErrors: validationErrors.where((e) => e != error).toList(),
    );
  }

  AnimalCreationModel clearErrors() {
    return copyWith(validationErrors: []);
  }

  AnimalCreationModel updateFormData(AnimalFormData data) {
    return copyWith(formData: data);
  }

  AnimalCreationModel addMetadata(String key, dynamic value) {
    final newMetadata = Map<String, dynamic>.from(metadata);
    newMetadata[key] = value;
    return copyWith(metadata: newMetadata);
  }

  Animal toAnimal() {
    return formData.toAnimal();
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'formData': formData.toJson(),
      'validationErrors': validationErrors,
      'metadata': metadata,
    };
  }

  factory AnimalCreationModel.fromJson(Map<String, dynamic> json) {
    return AnimalCreationModel(
      sessionId: json['sessionId'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      formData: AnimalFormData.fromJson(json['formData'] ?? {}),
      validationErrors: List<String>.from(json['validationErrors'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'AnimalCreationModel(sessionId: $sessionId, isValid: $isValid, '
        'errorCount: $errorCount, formData: ${formData.nome})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnimalCreationModel &&
        other.sessionId == sessionId &&
        other.createdAt == createdAt &&
        other.formData == formData &&
        _listEquals(other.validationErrors, validationErrors) &&
        _mapEquals(other.metadata, metadata);
  }

  bool _listEquals<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  bool _mapEquals(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return sessionId.hashCode ^
        createdAt.hashCode ^
        formData.hashCode ^
        validationErrors.hashCode ^
        metadata.hashCode;
  }
}

class AnimalFormData {
  final String nome;
  final String especie;
  final String raca;
  final DateTime? dataNascimento;
  final String sexo;
  final String cor;
  final double? pesoAtual;
  final String? foto;
  final String? observacoes;

  const AnimalFormData({
    this.nome = '',
    this.especie = '',
    this.raca = '',
    this.dataNascimento,
    this.sexo = '',
    this.cor = '',
    this.pesoAtual,
    this.foto,
    this.observacoes,
  });

  AnimalFormData copyWith({
    String? nome,
    String? especie,
    String? raca,
    DateTime? dataNascimento,
    String? sexo,
    String? cor,
    double? pesoAtual,
    String? foto,
    String? observacoes,
  }) {
    return AnimalFormData(
      nome: nome ?? this.nome,
      especie: especie ?? this.especie,
      raca: raca ?? this.raca,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      sexo: sexo ?? this.sexo,
      cor: cor ?? this.cor,
      pesoAtual: pesoAtual ?? this.pesoAtual,
      foto: foto ?? this.foto,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  bool get isValid {
    return nome.isNotEmpty &&
        especie.isNotEmpty &&
        raca.isNotEmpty &&
        dataNascimento != null &&
        sexo.isNotEmpty &&
        cor.isNotEmpty &&
        pesoAtual != null &&
        pesoAtual! > 0;
  }

  bool get isEmpty {
    return nome.isEmpty &&
        especie.isEmpty &&
        raca.isEmpty &&
        dataNascimento == null &&
        sexo.isEmpty &&
        cor.isEmpty &&
        pesoAtual == null &&
        (foto?.isEmpty ?? true) &&
        (observacoes?.isEmpty ?? true);
  }

  Animal toAnimal() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Animal(
      id: '',
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      needsSync: true,
      version: 1,
      nome: nome,
      especie: especie,
      raca: raca,
      dataNascimento: dataNascimento?.millisecondsSinceEpoch ?? 0,
      sexo: sexo,
      cor: cor,
      pesoAtual: pesoAtual ?? 0.0,
      foto: foto,
      observacoes: observacoes,
    );
  }

  factory AnimalFormData.fromAnimal(Animal animal) {
    return AnimalFormData(
      nome: animal.nome,
      especie: animal.especie,
      raca: animal.raca,
      dataNascimento:
          DateTime.fromMillisecondsSinceEpoch(animal.dataNascimento),
      sexo: animal.sexo,
      cor: animal.cor,
      pesoAtual: animal.pesoAtual,
      foto: animal.foto,
      observacoes: animal.observacoes,
    );
  }

  AnimalFormData reset() {
    return const AnimalFormData();
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'especie': especie,
      'raca': raca,
      'dataNascimento': dataNascimento?.millisecondsSinceEpoch,
      'sexo': sexo,
      'cor': cor,
      'pesoAtual': pesoAtual,
      'foto': foto,
      'observacoes': observacoes,
    };
  }

  factory AnimalFormData.fromJson(Map<String, dynamic> json) {
    return AnimalFormData(
      nome: json['nome'] ?? '',
      especie: json['especie'] ?? '',
      raca: json['raca'] ?? '',
      dataNascimento: json['dataNascimento'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dataNascimento'])
          : null,
      sexo: json['sexo'] ?? '',
      cor: json['cor'] ?? '',
      pesoAtual: json['pesoAtual']?.toDouble(),
      foto: json['foto'],
      observacoes: json['observacoes'],
    );
  }

  @override
  String toString() {
    return 'AnimalFormData(nome: $nome, especie: $especie, raca: $raca, '
        'sexo: $sexo, cor: $cor, peso: $pesoAtual)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnimalFormData &&
        other.nome == nome &&
        other.especie == especie &&
        other.raca == raca &&
        other.dataNascimento == dataNascimento &&
        other.sexo == sexo &&
        other.cor == cor &&
        other.pesoAtual == pesoAtual &&
        other.foto == foto &&
        other.observacoes == observacoes;
  }

  @override
  int get hashCode {
    return nome.hashCode ^
        especie.hashCode ^
        raca.hashCode ^
        dataNascimento.hashCode ^
        sexo.hashCode ^
        cor.hashCode ^
        pesoAtual.hashCode ^
        foto.hashCode ^
        observacoes.hashCode;
  }
}
