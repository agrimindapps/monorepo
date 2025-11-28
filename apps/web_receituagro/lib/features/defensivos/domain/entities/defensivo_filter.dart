import 'package:flutter/material.dart';

/// Enum representing the available filters for defensivos
/// Based on Vue.js ReceituagroCadastro-master logic
enum DefensivoFilter {
  todos('Todos', null),
  paraExportacao('Para Exportação', Icons.cloud_upload),
  semDiagnostico('Sem Diagnóstico', Icons.warning_amber),
  diagnosticoFaltante('Diagnóstico Faltante', Icons.pending),
  semInformacoes('Sem Informações', Icons.info_outline);

  final String label;
  final IconData? icon;

  const DefensivoFilter(this.label, this.icon);
}

/// Extension to hold statistics for a defensivo
/// Used by the filtering and display logic
class DefensivoStats {
  /// Total number of diagnósticos (quantDiag)
  final int quantDiag;

  /// Number of diagnósticos with dosage filled (quantDiagP - preenchidos)
  final int quantDiagP;

  /// Count of DefensivoInfo fields filled (temInfo)
  final int temInfo;

  const DefensivoStats({
    required this.quantDiag,
    required this.quantDiagP,
    required this.temInfo,
  });

  /// Empty stats for defensivos without data
  const DefensivoStats.empty()
      : quantDiag = 0,
        quantDiagP = 0,
        temInfo = 0;

  /// Whether all diagnósticos are complete (filled)
  bool get isDiagnosticosComplete => quantDiag > 0 && quantDiag == quantDiagP;

  /// Whether this defensivo has any diagnósticos
  bool get hasDiagnosticos => quantDiag > 0;

  /// Whether this defensivo has DefensivoInfo filled
  bool get hasInfo => temInfo > 0;

  /// Whether this defensivo is ready for export
  /// Based on Vue.js logic: quantDiag === quantDiagP && temInfo > 0 && quantDiag > 0
  bool get isReadyForExport =>
      isDiagnosticosComplete && hasInfo && hasDiagnosticos;

  /// Whether this defensivo has no diagnósticos at all
  /// Based on Vue.js logic: quantDiag === 0 && quantDiagP === 0
  bool get hasNoDiagnosticos => quantDiag == 0 && quantDiagP == 0;

  /// Whether this defensivo has missing (incomplete) diagnósticos
  /// Based on Vue.js logic: quantDiag !== quantDiagP
  bool get hasMissingDiagnosticos => quantDiag != quantDiagP;

  /// Format diagnóstico count as "X/Y"
  String get diagnosticoDisplay => '$quantDiagP/$quantDiag';
}
