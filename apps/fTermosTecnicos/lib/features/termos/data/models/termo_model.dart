import '../../domain/entities/termo.dart';

/// Data model for Termo extending the domain entity
/// Handles JSON serialization/deserialization
class TermoModel extends Termo {
  const TermoModel({
    required super.id,
    required super.termo,
    required super.descricao,
    required super.categoria,
    super.favorito,
  });

  /// Create TermoModel from JSON map
  factory TermoModel.fromJson(
    Map<String, dynamic> json, {
    required String categoria,
    bool favorito = false,
  }) {
    return TermoModel(
      id: json['id']?.toString() ?? '',
      termo: json['termo']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      categoria: categoria,
      favorito: favorito,
    );
  }

  /// Convert TermoModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'termo': termo,
      'descricao': descricao,
      'categoria': categoria,
      'favorito': favorito,
    };
  }

  /// Create TermoModel from domain Termo entity
  factory TermoModel.fromEntity(Termo termo) {
    return TermoModel(
      id: termo.id,
      termo: termo.termo,
      descricao: termo.descricao,
      categoria: termo.categoria,
      favorito: termo.favorito,
    );
  }

  /// Convert TermoModel to domain Termo entity
  Termo toEntity() {
    return Termo(
      id: id,
      termo: termo,
      descricao: descricao,
      categoria: categoria,
      favorito: favorito,
    );
  }
}
