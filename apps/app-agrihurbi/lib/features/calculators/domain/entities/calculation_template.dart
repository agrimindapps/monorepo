import 'package:equatable/equatable.dart';

/// Entidade que representa um template de cálculo salvo
/// 
/// Templates permitem salvar configurações de entrada para reutilização
/// e acelerar workflows de cálculos recorrentes
class CalculationTemplate extends Equatable {
  final String id;
  final String name;
  final String calculatorId;
  final String calculatorName;
  final Map<String, dynamic> inputValues;
  final String? description;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final String userId;
  final bool isPublic;

  const CalculationTemplate({
    required this.id,
    required this.name,
    required this.calculatorId,
    required this.calculatorName,
    required this.inputValues,
    required this.createdAt,
    required this.userId,
    this.description,
    this.tags = const [],
    this.lastUsed,
    this.isPublic = false,
  });

  /// Cria cópia do template com valores atualizados
  CalculationTemplate copyWith({
    String? id,
    String? name,
    String? calculatorId,
    String? calculatorName,
    Map<String, dynamic>? inputValues,
    String? description,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? lastUsed,
    String? userId,
    bool? isPublic,
  }) {
    return CalculationTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      calculatorId: calculatorId ?? this.calculatorId,
      calculatorName: calculatorName ?? this.calculatorName,
      inputValues: inputValues ?? this.inputValues,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      userId: userId ?? this.userId,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  /// Marca template como usado (atualiza lastUsed)
  CalculationTemplate markAsUsed() {
    return copyWith(lastUsed: DateTime.now());
  }

  /// Verifica se template foi usado recentemente
  bool get wasUsedRecently {
    if (lastUsed == null) return false;
    final daysSinceLastUse = DateTime.now().difference(lastUsed!).inDays;
    return daysSinceLastUse <= 7; // Considerado recente se usado nos últimos 7 dias
  }

  /// Verifica se template é válido (tem valores não vazios)
  bool get isValid {
    return name.trim().isNotEmpty && 
           calculatorId.isNotEmpty && 
           inputValues.isNotEmpty;
  }

  /// Formata data de criação
  String get formattedCreatedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/'
        '${createdAt.month.toString().padLeft(2, '0')}/'
        '${createdAt.year}';
  }

  /// Formata data de último uso
  String? get formattedLastUsed {
    if (lastUsed == null) return null;
    return '${lastUsed!.day.toString().padLeft(2, '0')}/'
        '${lastUsed!.month.toString().padLeft(2, '0')}/'
        '${lastUsed!.year}';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        calculatorId,
        calculatorName,
        inputValues,
        description,
        tags,
        createdAt,
        lastUsed,
        userId,
        isPublic,
      ];
}