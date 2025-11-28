import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/interfaces/usecase.dart';
import '../../../../core/providers/dependency_providers.dart';
import '../../../defensivos/domain/entities/diagnostico.dart';
import '../../domain/entities/praga.dart';

part 'pragas_providers.g.dart';

/// Provider for pragas list with state management
@riverpod
class PragasNotifier extends _$PragasNotifier {
  @override
  Future<List<Praga>> build() async {
    return _fetchPragas();
  }

  Future<List<Praga>> _fetchPragas() async {
    final useCase = ref.read(getAllPragasUseCaseProvider);
    final result = await useCase(const NoParams());

    return result.fold(
      (failure) => throw Exception(failure.message),
      (pragas) => pragas,
    );
  }

  /// Refresh pragas list
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPragas());
  }
}

/// Alias provider for easier access (matches naming convention)
@riverpod
Future<List<Praga>> pragasList(Ref ref) async {
  return ref.watch(pragasProvider.future);
}

/// Provider for all praga IDs that have PragaInfo
@riverpod
Future<Set<String>> pragasWithInfo(Ref ref) async {
  final client = ref.read(supabaseClientProvider);
  
  try {
    final response = await client
        .from('pragas_info')
        .select('praga_id');
    
    return (response as List)
        .map((json) => json['praga_id'] as String)
        .toSet();
  } catch (e) {
    return {};
  }
}

/// Provider for all praga IDs that have PlantaInfo
@riverpod
Future<Set<String>> pragasWithPlantaInfo(Ref ref) async {
  final client = ref.read(supabaseClientProvider);
  
  try {
    final response = await client
        .from('plantas_info')
        .select('praga_id');
    
    return (response as List)
        .map((json) => json['praga_id'] as String)
        .toSet();
  } catch (e) {
    return {};
  }
}

/// Provider for diagnosticos by praga ID
@riverpod
Future<List<Diagnostico>> diagnosticosByPraga(Ref ref, String pragaId) async {
  final client = ref.read(supabaseClientProvider);
  
  try {
    final response = await client
        .from('diagnosticos')
        .select()
        .eq('praga_id', pragaId);
    
    return (response as List).map((json) {
      return Diagnostico(
        id: json['id']?.toString() ?? '',
        defensivoId: json['defensivo_id']?.toString() ?? '',
        culturaId: json['cultura_id']?.toString() ?? '',
        pragaId: json['praga_id']?.toString() ?? '',
        dsMin: json['ds_min']?.toString(),
        dsMax: json['ds_max']?.toString(),
        um: json['um']?.toString(),
        minAplicacaoT: json['min_aplicacao_t']?.toString(),
        maxAplicacaoT: json['max_aplicacao_t']?.toString(),
        umT: json['um_t']?.toString(),
        minAplicacaoA: json['min_aplicacao_a']?.toString(),
        maxAplicacaoA: json['max_aplicacao_a']?.toString(),
        umA: json['um_a']?.toString(),
        intervalo: json['intervalo']?.toString(),
        intervalo2: json['intervalo2']?.toString(),
        epocaAplicacao: json['epoca_aplicacao']?.toString(),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
    }).toList();
  } catch (e) {
    throw Exception('Erro ao buscar diagnósticos: $e');
  }
}
