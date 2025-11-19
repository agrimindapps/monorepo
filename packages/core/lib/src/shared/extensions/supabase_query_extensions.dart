import 'package:supabase_flutter/supabase_flutter.dart';

/// Extensions para facilitar queries no Supabase
/// Nota: Use cast dinâmico para evitar problemas de tipo com PostgrestFilterBuilder
extension SupabaseQueryExtensions on PostgrestFilterBuilder<dynamic> {
  /// Busca por campo com padrão case-insensitive (ILIKE)
  PostgrestFilterBuilder<dynamic> searchByField(String field, String query) {
    return ilike(field, '%$query%');
  }

  /// Filtra registros ativos (Status = 1 ou true)
  PostgrestFilterBuilder<dynamic> whereActive() {
    return or('Status.eq.1,Status.eq.true');
  }

  /// Filtra registros inativos (Status = 0 ou false)
  PostgrestFilterBuilder<dynamic> whereInactive() {
    return or('Status.eq.0,Status.eq.false');
  }

  /// Ordena por data de criação
  PostgrestFilterBuilder<dynamic> orderByCreatedAt({bool ascending = false}) {
    return order('createdAt', ascending: ascending)
        as PostgrestFilterBuilder<dynamic>;
  }

  /// Ordena por data de atualização
  PostgrestFilterBuilder<dynamic> orderByUpdatedAt({bool ascending = false}) {
    return order('updatedAt', ascending: ascending)
        as PostgrestFilterBuilder<dynamic>;
  }

  /// Paginação simplificada
  PostgrestFilterBuilder<dynamic> paginate({
    required int page,
    required int pageSize,
  }) {
    final offset = (page - 1) * pageSize;
    return range(offset, offset + pageSize - 1)
        as PostgrestFilterBuilder<dynamic>;
  }

  /// Busca por múltiplos IDs
  PostgrestFilterBuilder<dynamic> whereInIds(String field, List<String> ids) {
    return inFilter(field, ids);
  }

  /// Filtra por intervalo de datas
  PostgrestFilterBuilder<dynamic> whereDateBetween({
    required String field,
    required DateTime start,
    required DateTime end,
  }) {
    return gte(
      field,
      start.toIso8601String(),
    ).lte(field, end.toIso8601String());
  }

  /// Busca por texto em múltiplos campos
  PostgrestFilterBuilder<dynamic> searchInFields(
    List<String> fields,
    String query,
  ) {
    final conditions = fields.map((field) => '$field.ilike.%$query%').join(',');
    return or(conditions);
  }

  /// Limita quantidade de resultados
  PostgrestFilterBuilder<dynamic> take(int count) {
    return limit(count) as PostgrestFilterBuilder<dynamic>;
  }
}

/// Extensions para facilitar uso do SupabaseClient
extension SupabaseClientExtensions on SupabaseClient {
  /// Verifica se a conexão está disponível
  Future<bool> checkConnection() async {
    try {
      await from('_health_check').select().limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}
