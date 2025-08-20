// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../models/12_consulta_model.dart';
import '../../../../repository/consulta_repository.dart';
import '../utils/consulta_utils.dart';

class ConsultaService {
  Future<List<Consulta>> getConsultasByAnimal({
    required String animalId,
    required ConsultaRepository repository,
    DateTime? dataInicial,
    DateTime? dataFinal,
  }) async {
    try {
      return await repository.getConsultas(
        animalId,
        dataInicial: dataInicial?.millisecondsSinceEpoch,
        dataFinal: dataFinal?.millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Erro ao buscar consultas do animal: $e');
      return [];
    }
  }

  Future<Consulta?> getConsultaById({
    required String id,
    required ConsultaRepository repository,
  }) async {
    try {
      return await repository.getConsultaById(id);
    } catch (e) {
      debugPrint('Erro ao buscar consulta por ID: $e');
      return null;
    }
  }

  Future<bool> addConsulta({
    required Consulta consulta,
    required ConsultaRepository repository,
  }) async {
    try {
      final sanitizedConsulta = sanitizeConsultaData(consulta);
      return await repository.addConsulta(sanitizedConsulta);
    } catch (e) {
      debugPrint('Erro ao adicionar consulta: $e');
      return false;
    }
  }

  Future<bool> updateConsulta({
    required Consulta consulta,
    required ConsultaRepository repository,
  }) async {
    try {
      final sanitizedConsulta = sanitizeConsultaData(consulta);
      return await repository.updateConsulta(sanitizedConsulta);
    } catch (e) {
      debugPrint('Erro ao atualizar consulta: $e');
      return false;
    }
  }

  Future<bool> deleteConsulta({
    required Consulta consulta,
    required ConsultaRepository repository,
  }) async {
    try {
      return await repository.deleteConsulta(consulta);
    } catch (e) {
      debugPrint('Erro ao excluir consulta: $e');
      return false;
    }
  }

  Consulta sanitizeConsultaData(Consulta consulta) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Consulta(
      id: consulta.id,
      createdAt: consulta.createdAt,
      updatedAt: now,
      isDeleted: false,
      needsSync: true,
      version: consulta.version + 1,
      lastSyncAt: consulta.lastSyncAt,
      animalId: consulta.animalId.trim(),
      dataConsulta: consulta.dataConsulta,
      veterinario: _sanitizeText(consulta.veterinario),
      motivo: _sanitizeText(consulta.motivo),
      diagnostico: _sanitizeText(consulta.diagnostico),
      valor: consulta.valor,
      observacoes: consulta.observacoes != null ? _sanitizeText(consulta.observacoes!) : null,
    );
  }

  String _sanitizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  List<Consulta> searchConsultas(List<Consulta> consultas, String query) {
    if (query.isEmpty) return consultas;

    final lowercaseQuery = query.toLowerCase();
    return consultas.where((consulta) {
      return consulta.veterinario.toLowerCase().contains(lowercaseQuery) ||
             consulta.motivo.toLowerCase().contains(lowercaseQuery) ||
             consulta.diagnostico.toLowerCase().contains(lowercaseQuery) ||
             (consulta.observacoes?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  List<Consulta> filterByDate(List<Consulta> consultas, DateTime date) {
    return consultas.where((consulta) {
      final consultaDate = DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta);
      return ConsultaUtils.isSameDay(consultaDate, date);
    }).toList();
  }

  List<Consulta> filterByDateRange(
    List<Consulta> consultas,
    DateTime startDate,
    DateTime endDate,
  ) {
    return consultas.where((consulta) {
      final consultaDate = DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta);
      return consultaDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             consultaDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  List<Consulta> filterByVeterinario(List<Consulta> consultas, String veterinario) {
    return consultas.where((consulta) => 
      consulta.veterinario.toLowerCase() == veterinario.toLowerCase()
    ).toList();
  }

  List<Consulta> filterByMotivo(List<Consulta> consultas, String motivo) {
    return consultas.where((consulta) => 
      consulta.motivo.toLowerCase().contains(motivo.toLowerCase())
    ).toList();
  }

  List<Consulta> sortConsultas(List<Consulta> consultas, String sortBy, bool ascending) {
    final sorted = List<Consulta>.from(consultas);
    
    switch (sortBy) {
      case 'data':
        sorted.sort((a, b) {
          final comparison = a.dataConsulta.compareTo(b.dataConsulta);
          return ascending ? comparison : -comparison;
        });
        break;
      case 'veterinario':
        sorted.sort((a, b) {
          final comparison = a.veterinario.compareTo(b.veterinario);
          return ascending ? comparison : -comparison;
        });
        break;
      case 'motivo':
        sorted.sort((a, b) {
          final comparison = a.motivo.compareTo(b.motivo);
          return ascending ? comparison : -comparison;
        });
        break;
      default:
        sorted.sort((a, b) {
          final comparison = a.dataConsulta.compareTo(b.dataConsulta);
          return ascending ? comparison : -comparison;
        });
    }
    
    return sorted;
  }

  Map<String, dynamic> generateStatistics(List<Consulta> consultas) {
    if (consultas.isEmpty) {
      return {
        'total': 0,
        'thisMonth': 0,
        'thisYear': 0,
        'lastConsulta': null,
        'veterinarios': <String>[],
        'motivos': <String>[],
        'monthlyDistribution': <String, int>{},
        'veterinarioDistribution': <String, int>{},
        'motivoDistribution': <String, int>{},
      };
    }

    final now = DateTime.now();
    final thisMonth = consultas.where((c) {
      final date = DateTime.fromMillisecondsSinceEpoch(c.dataConsulta);
      return date.year == now.year && date.month == now.month;
    }).length;

    final thisYear = consultas.where((c) {
      final date = DateTime.fromMillisecondsSinceEpoch(c.dataConsulta);
      return date.year == now.year;
    }).length;

    final sortedByDate = List<Consulta>.from(consultas)
      ..sort((a, b) => b.dataConsulta.compareTo(a.dataConsulta));

    final veterinarios = consultas.map((c) => c.veterinario).toSet().toList();
    final motivos = consultas.map((c) => c.motivo).toSet().toList();

    return {
      'total': consultas.length,
      'thisMonth': thisMonth,
      'thisYear': thisYear,
      'lastConsulta': sortedByDate.isNotEmpty ? sortedByDate.first : null,
      'veterinarios': veterinarios,
      'motivos': motivos,
      'monthlyDistribution': getMonthlyDistribution(consultas),
      'veterinarioDistribution': getVeterinarioStats(consultas),
      'motivoDistribution': getMotivoStats(consultas),
    };
  }

  Map<String, int> getMonthlyDistribution(List<Consulta> consultas) {
    final distribution = <String, int>{};
    
    for (final consulta in consultas) {
      final date = DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      distribution[monthKey] = (distribution[monthKey] ?? 0) + 1;
    }
    
    return distribution;
  }

  List<Map<String, dynamic>> getMonthlyConsultaStats(List<Consulta> consultas) {
    final monthlyData = <String, List<Consulta>>{};
    
    for (final consulta in consultas) {
      final date = DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      
      monthlyData[monthKey] = monthlyData[monthKey] ?? [];
      monthlyData[monthKey]!.add(consulta);
    }

    return monthlyData.entries.map((entry) {
      final monthConsultas = entry.value;
      final veterinarios = monthConsultas.map((c) => c.veterinario).toSet();
      final motivos = monthConsultas.map((c) => c.motivo).toSet();

      return {
        'month': entry.key,
        'count': monthConsultas.length,
        'veterinarios': veterinarios.length,
        'motivos': motivos.length,
        'topVeterinario': _getMostFrequent(monthConsultas.map((c) => c.veterinario).toList()),
        'topMotivo': _getMostFrequent(monthConsultas.map((c) => c.motivo).toList()),
      };
    }).toList()..sort((a, b) => (b['month'] as String).compareTo(a['month'] as String));
  }

  String? _getMostFrequent(List<String> items) {
    if (items.isEmpty) return null;
    
    final frequency = <String, int>{};
    for (final item in items) {
      frequency[item] = (frequency[item] ?? 0) + 1;
    }
    
    var maxCount = 0;
    String? mostFrequent;
    
    for (final entry in frequency.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostFrequent = entry.key;
      }
    }
    
    return mostFrequent;
  }

  Map<String, int> getVeterinarioStats(List<Consulta> consultas) {
    final stats = <String, int>{};
    for (final consulta in consultas) {
      final veterinario = consulta.veterinario.trim();
      if (veterinario.isNotEmpty) {
        stats[veterinario] = (stats[veterinario] ?? 0) + 1;
      }
    }
    return stats;
  }

  Map<String, int> getMotivoStats(List<Consulta> consultas) {
    final stats = <String, int>{};
    for (final consulta in consultas) {
      final motivo = consulta.motivo.trim();
      if (motivo.isNotEmpty) {
        stats[motivo] = (stats[motivo] ?? 0) + 1;
      }
    }
    return stats;
  }

  Future<String> exportToCsv({
    required String animalId,
    required ConsultaRepository repository,
  }) async {
    try {
      return await repository.exportToCsv(animalId);
    } catch (e) {
      debugPrint('Erro ao exportar para CSV: $e');
      return '';
    }
  }

  String generateCsvContent(List<Consulta> consultas) {
    if (consultas.isEmpty) return '';

    const header = 'Data,Veterinário,Motivo,Diagnóstico,Valor,Observações\n';
    final rows = consultas.map((consulta) {
      final date = ConsultaUtils.formatDate(
        DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta),
      );
      
      return [
        _escapeForCsv(date),
        _escapeForCsv(consulta.veterinario),
        _escapeForCsv(consulta.motivo),
        _escapeForCsv(consulta.diagnostico),
        _escapeForCsv('R\$ ${consulta.valor.toStringAsFixed(2)}'),
        _escapeForCsv(consulta.observacoes ?? ''),
      ].join(',');
    }).join('\n');

    return header + rows;
  }

  String _escapeForCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  bool isValidConsultaData(Consulta consulta) {
    return consulta.animalId.isNotEmpty &&
           consulta.veterinario.isNotEmpty &&
           consulta.motivo.isNotEmpty &&
           consulta.dataConsulta > 0;
  }

  Map<String, String?> validateConsultaData(Consulta consulta) {
    final errors = <String, String?>{};

    if (consulta.animalId.isEmpty) {
      errors['animalId'] = 'Animal deve ser selecionado';
    }

    if (consulta.veterinario.trim().isEmpty) {
      errors['veterinario'] = 'Veterinário é obrigatório';
    }

    if (consulta.motivo.trim().isEmpty) {
      errors['motivo'] = 'Motivo é obrigatório';
    }

    if (consulta.dataConsulta <= 0) {
      errors['dataConsulta'] = 'Data da consulta é obrigatória';
    }

    if (consulta.veterinario.length > 100) {
      errors['veterinario'] = 'Nome do veterinário muito longo (máx. 100 caracteres)';
    }

    if (consulta.motivo.length > 255) {
      errors['motivo'] = 'Motivo muito longo (máx. 255 caracteres)';
    }

    if (consulta.diagnostico.length > 500) {
      errors['diagnostico'] = 'Diagnóstico muito longo (máx. 500 caracteres)';
    }

    if ((consulta.observacoes?.length ?? 0) > 1000) {
      errors['observacoes'] = 'Observações muito longas (máx. 1000 caracteres)';
    }

    return errors;
  }

  List<String> getValidationErrors(Consulta consulta) {
    final errors = <String>[];
    final validation = validateConsultaData(consulta);
    
    validation.forEach((field, error) {
      if (error != null) {
        errors.add('$field: $error');
      }
    });
    
    return errors;
  }

  Consulta createNewConsulta({
    required String animalId,
    required String veterinario,
    required String motivo,
    DateTime? dataConsulta,
    String diagnostico = '',
    double valor = 0.0,
    String? observacoes,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Consulta(
      id: '',
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      needsSync: true,
      version: 1,
      lastSyncAt: null,
      animalId: animalId,
      dataConsulta: dataConsulta?.millisecondsSinceEpoch ?? now,
      veterinario: veterinario,
      motivo: motivo,
      diagnostico: diagnostico,
      valor: 0.0,
      observacoes: observacoes,
    );
  }

  Future<bool> duplicateConsulta({
    required Consulta originalConsulta,
    required ConsultaRepository repository,
    DateTime? newDate,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final duplicatedConsulta = Consulta(
        id: '',
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
        needsSync: true,
        version: 1,
        lastSyncAt: null,
        animalId: originalConsulta.animalId,
        dataConsulta: newDate?.millisecondsSinceEpoch ?? now,
        veterinario: originalConsulta.veterinario,
        motivo: '${originalConsulta.motivo} (Cópia)',
        diagnostico: originalConsulta.diagnostico,
        valor: originalConsulta.valor,
        observacoes: '${originalConsulta.observacoes}\n\n[Consulta duplicada]',
      );

      return await repository.addConsulta(duplicatedConsulta);
    } catch (e) {
      debugPrint('Erro ao duplicar consulta: $e');
      return false;
    }
  }
}
