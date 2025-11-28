import 'package:flutter/material.dart';

/// TipoPraga enum - Domain layer
/// Representa os tipos de pragas conforme sistema Vue.js
enum TipoPraga {
  inseto('1', 'Insetos', Icons.bug_report),
  doenca('2', 'Doenças', Icons.coronavirus),
  planta('3', 'Plantas Daninhas', Icons.grass);

  final String codigo;
  final String descricao;
  final IconData icon;

  const TipoPraga(this.codigo, this.descricao, this.icon);

  /// Get TipoPraga from codigo string
  static TipoPraga? fromCodigo(String? codigo) {
    if (codigo == null || codigo.isEmpty) return null;
    
    return TipoPraga.values.firstWhere(
      (tipo) => tipo.codigo == codigo,
      orElse: () => TipoPraga.inseto,
    );
  }

  /// Get TipoPraga from name string
  static TipoPraga? fromName(String? name) {
    if (name == null || name.isEmpty) return null;
    
    return TipoPraga.values.firstWhere(
      (tipo) => tipo.name == name,
      orElse: () => TipoPraga.inseto,
    );
  }

  /// Check if this tipo is for insects or diseases (uses PragaInfo)
  bool get usesPragaInfo => this == TipoPraga.inseto || this == TipoPraga.doenca;

  /// Check if this tipo is for plants (uses PlantaInfo)
  bool get usesPlantaInfo => this == TipoPraga.planta;

  /// Get color for the tipo
  Color get color {
    switch (this) {
      case TipoPraga.inseto:
        return Colors.orange;
      case TipoPraga.doenca:
        return Colors.red;
      case TipoPraga.planta:
        return Colors.green;
    }
  }
}
