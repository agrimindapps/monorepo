// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../models/bovino_class.dart';

/// Repository para gerenciar bovinos no Supabase
///
/// Tabela: agri_bovinos
/// Estrutura esperada:
/// - id (uuid, primary key)
/// - status (boolean) - false = ativo, true = deletado
/// - id_reg (text) - ID de registro personalizado
/// - nome_comum (text) - Nome comum do bovino
/// - pais_origem (text) - País de origem
/// - imagens (text[]) - Array de URLs das imagens
/// - miniatura (text) - URL da imagem miniatura
/// - tipo_animal (text) - Tipo do animal
/// - origem (text) - Origem detalhada
/// - caracteristicas (text) - Características do bovino
/// - created_at (timestamp) - Data de criação
/// - updated_at (timestamp) - Data de atualização
///
/// Bucket de Storage: agri-bovinos
class BovinosRepository {
  static final BovinosRepository _instance = BovinosRepository._internal();
  factory BovinosRepository() => _instance;
  BovinosRepository._internal();

  final _supabase = Supabase.instance.client;
  static const String _table = 'agri_bovinos';

  // ID do usuário único (definir o seu ID do Supabase aqui)
  static const String _adminUserId = 'seu_id_aqui';

  // Método para obter todos os registros (público)
  Future<List<BovinoClass>> getAll() async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('status', false) // Apenas registros ativos
          .order('nome_comum');

      return response.map((data) => BovinoClass.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar bovinos: $e');
    }
  }

  // Método para obter um único registro (público)
  Future<BovinoClass> get(String id) async {
    try {
      final response =
          await _supabase.from(_table).select().eq('id', id).single();

      return BovinoClass.fromMap(response);
    } catch (e) {
      throw Exception('Erro ao buscar bovino: $e');
    }
  }

  // Método para adicionar/atualizar registro (requer autenticação)
  Future<bool> saveUpdate(BovinoClass bovino) async {
    final user = _supabase.auth.currentUser;
    if (user?.id != _adminUserId) {
      throw Exception('Acesso não autorizado');
    }

    try {
      if (bovino.id.isEmpty) {
        await _supabase.from(_table).insert(bovino.toMap());
      } else {
        await _supabase.from(_table).update(bovino.toMap()).eq('id', bovino.id);
      }
      return true;
    } catch (e) {
      throw Exception('Erro ao salvar bovino: $e');
    }
  }

  // Método para remover registro (soft delete)
  Future<bool> remove(String id) async {
    final user = _supabase.auth.currentUser;
    if (user?.id != _adminUserId) {
      throw Exception('Acesso não autorizado');
    }

    try {
      await _supabase.from(_table).update({'status': true}).eq('id', id);
      return true;
    } catch (e) {
      throw Exception('Erro ao remover bovino: $e');
    }
  }
}
