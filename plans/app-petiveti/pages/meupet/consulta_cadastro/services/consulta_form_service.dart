// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../models/12_consulta_model.dart';
import '../../../../repository/consulta_repository.dart';
import '../utils/consulta_form_validators.dart';
import '../utils/date_formatter_service.dart';

class ConsultaFormService {
  Future<bool> saveConsulta({
    required Consulta consulta,
    Consulta? originalConsulta,
    required ConsultaRepository repository,
  }) async {
    try {
      // Sanitize data before saving
      final sanitizedConsulta = sanitizeConsultaData(consulta);

      bool result;
      if (originalConsulta != null) {
        result = await _updateConsulta(
          consulta: sanitizedConsulta,
          originalConsulta: originalConsulta,
          repository: repository,
        );
      } else {
        result = await _createConsulta(
          consulta: sanitizedConsulta,
          repository: repository,
        );
      }

      return result;
    } catch (e) {
      debugPrint('Erro no ConsultaFormService.saveConsulta: $e');
      return false;
    }
  }

  Future<bool> _createConsulta({
    required Consulta consulta,
    required ConsultaRepository repository,
  }) async {
    try {
      if (!isValidConsultaData(consulta)) {
        throw Exception('Dados da consulta são inválidos');
      }

      final result = await repository.addConsulta(consulta);
      return result;
    } catch (e) {
      debugPrint('Erro ao criar consulta: $e');
      return false;
    }
  }

  Future<bool> _updateConsulta({
    required Consulta consulta,
    required Consulta originalConsulta,
    required ConsultaRepository repository,
  }) async {
    try {
      if (!isValidConsultaData(consulta)) {
        throw Exception('Dados da consulta são inválidos');
      }

      final result = await repository.updateConsulta(consulta);
      return result;
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
      final result = await repository.deleteConsulta(consulta);
      return result;
    } catch (e) {
      debugPrint('Erro ao excluir consulta: $e');
      return false;
    }
  }

  bool isValidConsultaData(Consulta consulta) {
    return consulta.animalId.isNotEmpty &&
        consulta.veterinario.isNotEmpty &&
        consulta.motivo.isNotEmpty &&
        consulta.diagnostico.isNotEmpty &&
        consulta.dataConsulta > 0 &&
        _isValidDate(consulta.dataConsulta);
  }

  bool _isValidDate(int timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final twoYearsAgo = now.subtract(const Duration(days: 730));
      final oneYearFromNow = now.add(const Duration(days: 365));

      return date.isAfter(twoYearsAgo) && date.isBefore(oneYearFromNow);
    } catch (e) {
      return false;
    }
  }

  Map<String, String?> validateConsultaData(Consulta consulta) {
    return ConsultaFormValidators.validateAllFields(
      animalId: consulta.animalId,
      veterinario: consulta.veterinario,
      motivo: consulta.motivo,
      diagnostico: consulta.diagnostico,
      observacoes: consulta.observacoes ?? '',
      dataConsulta: DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta),
      valor: consulta.valor,
    );
  }

  Consulta sanitizeConsultaData(Consulta consulta) {
    return Consulta(
      id: consulta.id,
      createdAt: consulta.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isDeleted: consulta.isDeleted,
      needsSync: true,
      version: consulta.version,
      lastSyncAt: consulta.lastSyncAt,
      animalId: consulta.animalId.trim(),
      dataConsulta: consulta.dataConsulta,
      veterinario: _sanitizeText(consulta.veterinario),
      motivo: _sanitizeText(consulta.motivo),
      diagnostico: _sanitizeText(consulta.diagnostico),
      valor: consulta.valor,
      observacoes: consulta.observacoes != null
          ? _sanitizeText(consulta.observacoes!)
          : null,
    );
  }

  String _sanitizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
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

  String formatDate(int timestamp) {
    return DateFormatterService.instance.formatTimestampForDisplay(timestamp);
  }

  DateTime? parseDate(String dateString) {
    return DateFormatterService.instance.parseFromInput(dateString);
  }

  bool isValidDateString(String date) {
    return DateFormatterService.instance.isValidInputDate(date);
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
    required String diagnostico,
    DateTime? dataConsulta,
    String? observacoes,
    double valor = 0.0,
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
      valor: valor,
      observacoes: observacoes?.isEmpty == true ? null : observacoes,
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
        motivo: originalConsulta.motivo,
        diagnostico: '${originalConsulta.diagnostico} (Cópia)',
        valor: originalConsulta.valor,
        observacoes: originalConsulta.observacoes != null
            ? '${originalConsulta.observacoes}\n\n[Consulta duplicada]'
            : '[Consulta duplicada]',
      );

      return await repository.addConsulta(duplicatedConsulta);
    } catch (e) {
      debugPrint('Erro ao duplicar consulta: $e');
      return false;
    }
  }

  bool hasDataChanged(Consulta original, Consulta updated) {
    return original.animalId != updated.animalId ||
        original.dataConsulta != updated.dataConsulta ||
        original.veterinario != updated.veterinario ||
        original.motivo != updated.motivo ||
        original.diagnostico != updated.diagnostico ||
        original.valor != updated.valor ||
        original.observacoes != updated.observacoes;
  }

  Map<String, dynamic> generateSummary(Consulta consulta) {
    return {
      'id': consulta.id,
      'animalId': consulta.animalId,
      'dataConsulta': formatDate(consulta.dataConsulta),
      'veterinario': consulta.veterinario,
      'motivo': consulta.motivo,
      'diagnostico': consulta.diagnostico.length > 100
          ? '${consulta.diagnostico.substring(0, 100)}...'
          : consulta.diagnostico,
      'valor': consulta.valor,
      'hasObservacoes':
          consulta.observacoes != null && consulta.observacoes!.isNotEmpty,
      'isRecent': _isRecentConsulta(consulta.dataConsulta),
    };
  }

  bool _isRecentConsulta(int timestamp) {
    final consultaDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final daysDifference = now.difference(consultaDate).inDays;
    return daysDifference <= 30; // Consider recent if within 30 days
  }

  String getRelativeTime(int timestamp) {
    return DateFormatterService.instance
        .getRelativeTimeFromTimestamp(timestamp);
  }

  List<String> getAvailableMotivos() {
    return [
      'Consulta de rotina',
      'Check-up',
      'Vacina',
      'Emergência',
      'Cirurgia',
      'Exame',
      'Tratamento',
      'Retorno',
      'Outros',
    ];
  }

  List<String> getCommonVeterinarios() {
    // This could be populated from a database or preferences
    return [
      'Dr. João Silva',
      'Dra. Maria Santos',
      'Dr. Pedro Oliveira',
      'Dra. Ana Costa',
      'Dr. Carlos Ferreira',
    ];
  }

  String? generateDiagnosticoSuggestion(String motivo) {
    final suggestions = {
      'Consulta de rotina': 'Animal apresenta bom estado geral de saúde.',
      'Check-up': 'Exame clínico completo realizado.',
      'Vacina': 'Vacinação realizada conforme protocolo.',
      'Emergência': 'Atendimento de emergência realizado.',
      'Cirurgia': 'Procedimento cirúrgico realizado com sucesso.',
      'Exame': 'Exames complementares realizados.',
      'Tratamento': 'Tratamento iniciado conforme prescrição.',
      'Retorno': 'Retorno para acompanhamento do tratamento.',
      'Outros': 'Procedimento específico realizado.',
    };

    return suggestions[motivo];
  }

  bool isValidMotivo(String motivo) {
    return getAvailableMotivos().contains(motivo);
  }

  String normalizeMotivo(String motivo) {
    final found = getAvailableMotivos()
        .where((m) => m.toLowerCase() == motivo.toLowerCase())
        .firstOrNull;
    return found ?? motivo;
  }
}
