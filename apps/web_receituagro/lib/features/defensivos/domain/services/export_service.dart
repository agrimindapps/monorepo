import 'dart:convert';

import '../entities/defensivo.dart';
import '../entities/defensivo_info.dart';
import '../entities/diagnostico.dart';

/// Service responsible for exporting defensivos data
/// Supports CSV and JSON formats
class ExportService {
  /// Export defensivos to CSV format
  String exportToCsv({
    required List<Defensivo> defensivos,
    List<Diagnostico>? diagnosticos,
    List<DefensivoInfo>? infos,
  }) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
      'ID,Nome Comum,Nome Técnico,Fabricante,Ingrediente Ativo,'
      'MAPA,Formulação,Modo de Ação,Classe Agronômica,'
      'Classe Toxicológica,Classe Ambiental,Inflamável,Corrosivo,Comercializado',
    );

    // Data rows
    for (final defensivo in defensivos) {
      buffer.writeln(
        '${_escapeCsv(defensivo.id)},'
        '${_escapeCsv(defensivo.nomeComum)},'
        '${_escapeCsv(defensivo.nomeTecnico ?? '')},'
        '${_escapeCsv(defensivo.fabricante)},'
        '${_escapeCsv(defensivo.ingredienteAtivo)},'
        '${_escapeCsv(defensivo.mapa ?? '')},'
        '${_escapeCsv(defensivo.formulacao ?? '')},'
        '${_escapeCsv(defensivo.modoAcao ?? '')},'
        '${_escapeCsv(defensivo.classeAgronomica ?? '')},'
        '${_escapeCsv(defensivo.toxico ?? '')},'
        '${_escapeCsv(defensivo.classAmbiental ?? '')},'
        '${_escapeCsv(defensivo.inflamavel ?? '')},'
        '${_escapeCsv(defensivo.corrosivo ?? '')},'
        '${_escapeCsv(defensivo.comercializado ?? '')}',
      );
    }

    return buffer.toString();
  }

  /// Export defensivos to JSON format
  String exportToJson({
    required List<Defensivo> defensivos,
    List<Diagnostico>? diagnosticos,
    List<DefensivoInfo>? infos,
  }) {
    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'totalDefensivos': defensivos.length,
      'totalDiagnosticos': diagnosticos?.length ?? 0,
      'totalInfos': infos?.length ?? 0,
      'defensivos': defensivos.map((d) => _defensivoToMap(d)).toList(),
      if (diagnosticos != null && diagnosticos.isNotEmpty)
        'diagnosticos': diagnosticos.map((d) => _diagnosticoToMap(d)).toList(),
      if (infos != null && infos.isNotEmpty)
        'infos': infos.map((i) => _infoToMap(i)).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Export only defensivos ready for export (complete)
  String exportFiltered({
    required List<Defensivo> defensivos,
    required List<Diagnostico> diagnosticos,
    required List<DefensivoInfo> infos,
    required bool Function(Defensivo, List<Diagnostico>, DefensivoInfo?) filter,
  }) {
    final filtered = <Defensivo>[];

    for (final defensivo in defensivos) {
      final defDiagnosticos = diagnosticos
          .where((d) => d.defensivoId == defensivo.id)
          .toList();
      final defInfo = infos.cast<DefensivoInfo?>().firstWhere(
            (i) => i?.defensivoId == defensivo.id,
            orElse: () => null,
          );

      if (filter(defensivo, defDiagnosticos, defInfo)) {
        filtered.add(defensivo);
      }
    }

    return exportToJson(
      defensivos: filtered,
      diagnosticos: diagnosticos
          .where((d) => filtered.any((f) => f.id == d.defensivoId))
          .toList(),
      infos: infos
          .where((i) => filtered.any((f) => f.id == i.defensivoId))
          .toList(),
    );
  }

  /// Escape CSV special characters
  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Map<String, dynamic> _defensivoToMap(Defensivo d) => {
        'id': d.id,
        'nomeComum': d.nomeComum,
        'nomeTecnico': d.nomeTecnico,
        'fabricante': d.fabricante,
        'ingredienteAtivo': d.ingredienteAtivo,
        'quantProduto': d.quantProduto,
        'mapa': d.mapa,
        'formulacao': d.formulacao,
        'modoAcao': d.modoAcao,
        'classeAgronomica': d.classeAgronomica,
        'toxico': d.toxico,
        'classAmbiental': d.classAmbiental,
        'inflamavel': d.inflamavel,
        'corrosivo': d.corrosivo,
        'comercializado': d.comercializado,
        'createdAt': d.createdAt.toIso8601String(),
        'updatedAt': d.updatedAt.toIso8601String(),
      };

  Map<String, dynamic> _diagnosticoToMap(Diagnostico d) => {
        'id': d.id,
        'defensivoId': d.defensivoId,
        'culturaId': d.culturaId,
        'pragaId': d.pragaId,
        'dsMin': d.dsMin,
        'dsMax': d.dsMax,
        'um': d.um,
        'minAplicacaoT': d.minAplicacaoT,
        'maxAplicacaoT': d.maxAplicacaoT,
        'umT': d.umT,
        'minAplicacaoA': d.minAplicacaoA,
        'maxAplicacaoA': d.maxAplicacaoA,
        'umA': d.umA,
        'intervalo': d.intervalo,
        'intervalo2': d.intervalo2,
        'epocaAplicacao': d.epocaAplicacao,
        'createdAt': d.createdAt.toIso8601String(),
        'updatedAt': d.updatedAt.toIso8601String(),
      };

  Map<String, dynamic> _infoToMap(DefensivoInfo i) => {
        'id': i.id,
        'defensivoId': i.defensivoId,
        'embalagens': i.embalagens,
        'tecnologia': i.tecnologia,
        'pHumanas': i.pHumanas,
        'pAmbiental': i.pAmbiental,
        'manejoResistencia': i.manejoResistencia,
        'compatibilidade': i.compatibilidade,
        'manejoIntegrado': i.manejoIntegrado,
        'createdAt': i.createdAt.toIso8601String(),
        'updatedAt': i.updatedAt.toIso8601String(),
      };
}
