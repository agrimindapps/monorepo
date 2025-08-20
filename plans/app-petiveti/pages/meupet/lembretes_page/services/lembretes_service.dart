// Project imports:
import '../../../../models/14_lembrete_model.dart';
import '../../../../repository/lembrete_repository.dart';

class LembretesService {
  final LembreteRepository _repository;

  LembretesService({LembreteRepository? repository})
      : _repository = repository ?? LembreteRepository();

  static Future<LembretesService> initialize() async {
    await LembreteRepository.initialize();
    return LembretesService();
  }

  Future<List<LembreteVet>> getLembretes(
    String animalId, {
    int? dataInicial,
    int? dataFinal,
  }) async {
    try {
      return await _repository.getLembretes(
        animalId,
        dataInicial: dataInicial,
        dataFinal: dataFinal,
      );
    } catch (e) {
      throw Exception('Erro ao buscar lembretes: ${e.toString()}');
    }
  }

  Future<LembreteVet?> getLembreteById(String id) async {
    try {
      return await _repository.getLembreteById(id);
    } catch (e) {
      throw Exception('Erro ao buscar lembrete: ${e.toString()}');
    }
  }

  Future<bool> deleteLembrete(LembreteVet lembrete) async {
    try {
      return await _repository.deleteLembrete(lembrete);
    } catch (e) {
      throw Exception('Erro ao deletar lembrete: ${e.toString()}');
    }
  }

  Future<bool> updateLembrete(LembreteVet lembrete) async {
    try {
      return await _repository.updateLembrete(lembrete);
    } catch (e) {
      throw Exception('Erro ao atualizar lembrete: ${e.toString()}');
    }
  }

  Future<List<LembreteVet>> getLembretesAtrasados(String animalId) async {
    try {
      final lembretes = await _repository.getLembretes(animalId);
      final now = DateTime.now();
      
      return lembretes.where((lembrete) {
        final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
        return !lembrete.concluido && !lembrete.isDeleted && dataHora.isBefore(now);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar lembretes atrasados: ${e.toString()}');
    }
  }

  Future<List<LembreteVet>> getLembretesPendentes(String animalId) async {
    try {
      final lembretes = await _repository.getLembretes(animalId);
      return lembretes.where((lembrete) => !lembrete.concluido && !lembrete.isDeleted).toList();
    } catch (e) {
      throw Exception('Erro ao buscar lembretes pendentes: ${e.toString()}');
    }
  }

  Future<List<LembreteVet>> getLembretesCompletos(String animalId) async {
    try {
      final lembretes = await _repository.getLembretes(animalId);
      return lembretes.where((lembrete) => lembrete.concluido && !lembrete.isDeleted).toList();
    } catch (e) {
      throw Exception('Erro ao buscar lembretes completos: ${e.toString()}');
    }
  }

  Future<List<LembreteVet>> getLembretesHoje(String animalId) async {
    try {
      final lembretes = await _repository.getLembretes(animalId);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      
      return lembretes.where((lembrete) {
        final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
        return dataHora.isAfter(today.subtract(const Duration(milliseconds: 1))) &&
               dataHora.isBefore(tomorrow);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar lembretes de hoje: ${e.toString()}');
    }
  }

  Future<List<LembreteVet>> searchLembretes(
    String animalId,
    String query,
  ) async {
    try {
      final lembretes = await _repository.getLembretes(animalId);
      
      if (query.isEmpty) return lembretes;
      
      final lowercaseQuery = query.toLowerCase();
      return lembretes.where((lembrete) {
        return lembrete.titulo.toLowerCase().contains(lowercaseQuery) ||
               lembrete.descricao.toLowerCase().contains(lowercaseQuery) ||
               lembrete.tipo.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar lembretes: ${e.toString()}');
    }
  }

  Future<bool> toggleLembreteConcluido(LembreteVet lembrete) async {
    try {
      final updatedLembrete = LembreteVet(
        id: lembrete.id,
        createdAt: lembrete.createdAt,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        isDeleted: lembrete.isDeleted,
        needsSync: true,
        version: lembrete.version + 1,
        lastSyncAt: lembrete.lastSyncAt,
        animalId: lembrete.animalId,
        titulo: lembrete.titulo,
        descricao: lembrete.descricao,
        dataHora: lembrete.dataHora,
        tipo: lembrete.tipo,
        repetir: lembrete.repetir,
        concluido: !lembrete.concluido,
      );
      
      return await _repository.updateLembrete(updatedLembrete);
    } catch (e) {
      throw Exception('Erro ao alterar status do lembrete: ${e.toString()}');
    }
  }

  String exportToCsv(List<LembreteVet> lembretes) {
    if (lembretes.isEmpty) return '';
    
    const csvHeader = 'Título,Data/Hora,Descrição,Tipo,Repetir,Concluído\n';
    final csvRows = lembretes.map((lembrete) {
      final titulo = _escapeField(lembrete.titulo);
      final dataHora = _escapeField(_formatDateTimeToString(lembrete.dataHora));
      final descricao = _escapeField(lembrete.descricao);
      final tipo = _escapeField(lembrete.tipo);
      final repetir = _escapeField(lembrete.repetir);
      final concluido = lembrete.concluido ? 'Sim' : 'Não';
      return '$titulo,$dataHora,$descricao,$tipo,$repetir,$concluido';
    }).join('\n');
    
    return csvHeader + csvRows;
  }

  String _escapeField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  String _formatDateTimeToString(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '$dateStr $timeStr';
  }
}
