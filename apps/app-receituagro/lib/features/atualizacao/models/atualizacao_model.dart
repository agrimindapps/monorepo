import 'package:flutter/foundation.dart';

/// Model representing a single app update/version
@immutable
class AtualizacaoModel {
  /// Version string (e.g., "2.1.0")
  final String versao;
  
  /// List of changes/improvements in this version
  final List<String> notas;

  const AtualizacaoModel({
    required this.versao,
    required this.notas,
  });

  /// Create model from map data (for JSON parsing)
  factory AtualizacaoModel.fromMap(Map<String, dynamic> map) {
    return AtualizacaoModel(
      versao: map['versao'] as String? ?? '',
      notas: List<String>.from(map['notas'] as List? ?? []),
    );
  }

  /// Convert model to map (for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'versao': versao,
      'notas': notas,
    };
  }

  /// Create a copy with modified fields
  AtualizacaoModel copyWith({
    String? versao,
    List<String>? notas,
  }) {
    return AtualizacaoModel(
      versao: versao ?? this.versao,
      notas: notas ?? this.notas,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AtualizacaoModel &&
        other.versao == versao &&
        listEquals(other.notas, notas);
  }

  @override
  int get hashCode => versao.hashCode ^ notas.hashCode;

  @override
  String toString() {
    return 'AtualizacaoModel(versao: $versao, notas: ${notas.length} items)';
  }

  /// Get formatted release notes as bullet points
  String get formattedNotas {
    if (notas.isEmpty) return '';
    return '• ${notas.join('\n• ')}';
  }

  /// Check if this version is empty/invalid
  bool get isEmpty => versao.isEmpty && notas.isEmpty;
  
  /// Check if this version has valid data
  bool get isValid => versao.isNotEmpty;
}