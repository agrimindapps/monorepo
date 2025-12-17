import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/extensions/diagnostico_drift_extension.dart';
import '../../../../core/providers/premium_notifier.dart';
import '../../../../database/providers/database_providers.dart';
import '../../../../database/receituagro_database.dart';
import '../../../diagnosticos/data/mappers/diagnostico_mapper.dart';
import '../../../diagnosticos/domain/entities/diagnostico_entity.dart';
import '../../../favoritos/presentation/providers/favoritos_providers.dart';
import 'diagnosticos_providers.dart';

part 'detalhe_diagnostico_notifier.g.dart';

/// Detalhe Diagnostico state
class DetalheDiagnosticoState {
  final DiagnosticoEntity? diagnostico;
  final Diagnostico? diagnosticoDrift;
  final Map<String, String> diagnosticoData;
  final bool isFavorited;
  final bool isPremium;
  final bool isLoading;
  final bool isSharingContent;
  final String? errorMessage;

  const DetalheDiagnosticoState({
    this.diagnostico,
    this.diagnosticoDrift,
    required this.diagnosticoData,
    required this.isFavorited,
    required this.isPremium,
    required this.isLoading,
    required this.isSharingContent,
    this.errorMessage,
  });

  factory DetalheDiagnosticoState.initial() {
    return const DetalheDiagnosticoState(
      diagnostico: null,
      diagnosticoDrift: null,
      diagnosticoData: {},
      isFavorited: false,
      isPremium: false,
      isLoading: false,
      isSharingContent: false,
      errorMessage: null,
    );
  }

  DetalheDiagnosticoState copyWith({
    DiagnosticoEntity? diagnostico,
    Diagnostico? diagnosticoDrift,
    Map<String, String>? diagnosticoData,
    bool? isFavorited,
    bool? isPremium,
    bool? isLoading,
    bool? isSharingContent,
    String? errorMessage,
  }) {
    return DetalheDiagnosticoState(
      diagnostico: diagnostico ?? this.diagnostico,
      diagnosticoDrift: diagnosticoDrift ?? this.diagnosticoDrift,
      diagnosticoData: diagnosticoData ?? this.diagnosticoData,
      isFavorited: isFavorited ?? this.isFavorited,
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      isSharingContent: isSharingContent ?? this.isSharingContent,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  DetalheDiagnosticoState clearError() {
    return copyWith(errorMessage: null);
  }

  bool get hasError => errorMessage != null;
  bool get hasDiagnostico => diagnostico != null;
}

/// Notifier para gerenciar estado de Detalhe Diagnóstico (Presentation Layer)
/// Princípios: Single Responsibility + Dependency Inversion
///
/// IMPORTANTE: keepAlive mantém o state mesmo quando não há listeners
/// Isso previne perda de dados ao navegar entre tabs ou fazer rebuilds temporários
@riverpod
class DetalheDiagnosticoNotifier extends _$DetalheDiagnosticoNotifier {
  @override
  Future<DetalheDiagnosticoState> build() async {
    // Setup listener APÓS o estado inicial ser retornado
    unawaited(Future.microtask(() => _setupPremiumStatusListener()));

    return DetalheDiagnosticoState.initial();
  }

  /// Load diagnostico data
  Future<void> loadDiagnosticoData(String diagnosticoId, {String? nomeDefensivoFallback}) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    try {
      final diagnosticosRepository = ref.read(iDiagnosticosRepositoryProvider);
      final result = await diagnosticosRepository.getById(diagnosticoId);

      await result.fold(
        (failure) async {
          throw Exception('Erro no repository Clean Architecture: $failure');
        },
        (diagnosticoEntity) async {
          if (diagnosticoEntity != null) {
            final driftRepository = ref.read(diagnosticoRepositoryProvider);
            final diagnosticoDrift =
                await driftRepository.findById(
              int.parse(diagnosticoId),
            );

            // Fetch related data
            final fitossanitariosRepo = ref.read(fitossanitariosRepositoryProvider);
            final fitossanitariosInfoRepo = ref.read(fitossanitariosInfoRepositoryProvider);
            final pragasRepo = ref.read(pragasRepositoryProvider);

            Fitossanitario? defensivo;
            FitossanitariosInfoData? defensivoInfo;
            Praga? praga;

            if (diagnosticoDrift != null) {
               debugPrint('🔍 [DetalheDiagnosticoNotifier] Buscando dados relacionados...');
               debugPrint('   defensivoId: ${diagnosticoDrift.defensivoId}');
               debugPrint('   pragaId: ${diagnosticoDrift.pragaId}');
               
               defensivo = await fitossanitariosRepo.findById(diagnosticoDrift.defensivoId);
               
               // Fallback: Se não achou por ID, tenta pelo nome (Self-Healing)
               if (defensivo == null && nomeDefensivoFallback != null && nomeDefensivoFallback.isNotEmpty) {
                 debugPrint('⚠️ [DetalheDiagnosticoNotifier] Defensivo não encontrado por ID. Tentando fallback por nome: "$nomeDefensivoFallback"');
                 final matches = await fitossanitariosRepo.findByNome(nomeDefensivoFallback);
                 // Tenta match exato primeiro
                 defensivo = matches.firstWhere(
                   (f) => f.nome.toLowerCase() == nomeDefensivoFallback.toLowerCase(),
                   orElse: () => matches.isNotEmpty ? matches.first : throw Exception('Defensivo não encontrado'),
                 );
                 if (defensivo != null) {
                   debugPrint('✅ [DetalheDiagnosticoNotifier] Defensivo recuperado por nome: ${defensivo.nome} (ID: ${defensivo.id})');
                 }
               }

               debugPrint('   defensivo encontrado: ${defensivo != null ? defensivo.nome : "NULL"}');
               
               if (defensivo != null) {
                  // Tenta buscar Info pelo ID do defensivo (Foreign Key)
                  defensivoInfo = await fitossanitariosInfoRepo.findByDefensivoId(defensivo.id);
                  
                  // Se não achou, tenta buscar pelo ID da tabela (caso onde ID == DefensivoID)
                  if (defensivoInfo == null) {
                     defensivoInfo = await fitossanitariosInfoRepo.findById(defensivo.id);
                  }

                  // Se ainda não achou, tenta pelo idDefensivo (String)
                  if (defensivoInfo == null) {
                     defensivoInfo = await fitossanitariosInfoRepo.findByIdReg(defensivo.idDefensivo);
                  }

                  debugPrint('   defensivoInfo encontrado: ${defensivoInfo != null ? "SIM" : "NULL"}');
                  if (defensivoInfo != null) {
                    debugPrint('   - formulacao: ${defensivoInfo.formulacao}');
                    debugPrint('   - modoAcao: ${defensivoInfo.modoAcao}');
                    debugPrint('   - toxicidade: ${defensivoInfo.toxicidade}');
                  }
               }
               praga = await pragasRepo.findById(diagnosticoDrift.pragaId);
               debugPrint('   praga encontrada: ${praga != null ? praga.nome : "NULL"}');
            }

            // Extensão DiagnosticoExtension já busca dados do defensivo internamente
            final diagnosticoData = diagnosticoDrift != null
                ? await diagnosticoDrift.toDataMap(
                    defensivo: defensivo,
                    defensivoInfo: defensivoInfo,
                    praga: praga,
                  )
                : <String, String>{};

            // Debug logs
            debugPrint(
              '🔍 [DetalheDiagnosticoNotifier] diagnosticoData carregado:',
            );
            debugPrint('  - Keys: ${diagnosticoData.keys.toList()}');
            debugPrint(
              '  - ingredienteAtivo: ${diagnosticoData['ingredienteAtivo']}',
            );
            debugPrint(
              '  - classificacaoToxicologica: ${diagnosticoData['classificacaoToxicologica']}',
            );
            debugPrint('  - formulacao: ${diagnosticoData['formulacao']}');
            debugPrint('  - modoAcao: ${diagnosticoData['modoAcao']}');

            state = AsyncValue.data(
              currentState
                  .copyWith(
                    diagnostico: diagnosticoEntity,
                    diagnosticoDrift: diagnosticoDrift,
                    diagnosticoData: diagnosticoData,
                    isLoading: false,
                  )
                  .clearError(),
            );

            // Load premium status after loading data
            await loadPremiumStatus();
          } else {
            final driftRepository = ref.read(diagnosticoRepositoryProvider);
            final result = await driftRepository.getAll();
            final totalDiagnosticos = result.length;
            final errorMsg = totalDiagnosticos == 0
                ? 'Base de dados vazia. Nenhum diagnóstico foi carregado. Verifique se o aplicativo foi inicializado corretamente ou tente resincronizar os dados.'
                : 'Diagnóstico com ID "$diagnosticoId" não encontrado. Existem $totalDiagnosticos diagnósticos na base de dados local.';

            state = AsyncValue.data(
              currentState.copyWith(isLoading: false, errorMessage: errorMsg),
            );
          }
        },
      );
    } catch (e) {
      try {
        final driftRepository = ref.read(diagnosticoRepositoryProvider);
        final diagnosticoDrift =
            await driftRepository.findById(
          int.parse(diagnosticoId),
        );
        if (diagnosticoDrift != null) {
          final diagnostico = DiagnosticoMapper.fromDrift(diagnosticoDrift);

          // Fetch related data
          final fitossanitariosRepo = ref.read(fitossanitariosRepositoryProvider);
          final fitossanitariosInfoRepo = ref.read(fitossanitariosInfoRepositoryProvider);
          final pragasRepo = ref.read(pragasRepositoryProvider);

          final defensivo = await fitossanitariosRepo.findById(diagnosticoDrift.defensivoId);
          debugPrint('🔍 [Fallback] defensivo encontrado: ${defensivo != null ? defensivo.nome : "NULL"}');
          
          FitossanitariosInfoData? defensivoInfo;
          if (defensivo != null) {
             // O id em FitossanitariosInfo é o mesmo id do Fitossanitario
             defensivoInfo = await fitossanitariosInfoRepo.findById(defensivo.id);
             debugPrint('🔍 [Fallback] defensivoInfo encontrado: ${defensivoInfo != null ? "SIM" : "NULL"}');
          }
          final praga = await pragasRepo.findById(diagnosticoDrift.pragaId);
          debugPrint('🔍 [Fallback] praga encontrada: ${praga != null ? praga.nome : "NULL"}');

          // Extensão DiagnosticoExtension já busca dados do defensivo internamente
          final diagnosticoData = await diagnosticoDrift.toDataMap(
            defensivo: defensivo,
            defensivoInfo: defensivoInfo,
            praga: praga,
          );

          state = AsyncValue.data(
            currentState
                .copyWith(
                  diagnostico: diagnostico,
                  diagnosticoDrift: diagnosticoDrift,
                  diagnosticoData: diagnosticoData,
                  isLoading: false,
                )
                .clearError(),
          );

          // Load premium status after fallback loading
          await loadPremiumStatus();
        } else {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: 'Diagnóstico não encontrado: $diagnosticoId',
            ),
          );
        }
      } catch (fallbackError) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            errorMessage:
                'Erro ao acessar dados locais: $fallbackError. Tente reiniciar o aplicativo ou resincronizar os dados.',
          ),
        );
      }
    }
  }

  /// Load premium status
  Future<void> loadPremiumStatus() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final premiumState = ref.read(premiumProvider).value;
      state = AsyncValue.data(
        currentState.copyWith(isPremium: premiumState?.isPremium ?? false),
      );
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(isPremium: false));
    }
  }

  /// Setup premium status listener
  void _setupPremiumStatusListener() {
    ref.listen(premiumProvider, (previous, next) {
      // Usar whenData para garantir que o estado está pronto
      state.whenData((currentState) {
        next.whenData((premiumState) {
          state = AsyncValue.data(
            currentState.copyWith(isPremium: premiumState.isPremium),
          );
        });
      });
    });
  }

  /// Load favorito state
  Future<void> loadFavoritoState(String diagnosticoId) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final favoritosRepository = ref.read(favoritosRepositorySimplifiedProvider);
      final result = await favoritosRepository.isFavorito(
        'diagnostico',
        diagnosticoId,
      );

      // Unwrap Either<Failure, bool>
      final isFavorited = result.fold(
        (failure) => false, // On failure, assume not favorited
        (value) => value,
      );

      state = AsyncValue.data(currentState.copyWith(isFavorited: isFavorited));
    } catch (e) {
      // Fallback: try with 'diagnosticos' (plural)
      try {
        final favoritosRepository = ref.read(favoritosRepositorySimplifiedProvider);
        final result = await favoritosRepository.isFavorito(
          'diagnosticos',
          diagnosticoId,
        );

        final isFavorited = result.fold(
          (failure) => false,
          (value) => value,
        );

        state = AsyncValue.data(currentState.copyWith(isFavorited: isFavorited));
      } catch (fallbackError) {
        // On error, assume not favorited
        state = AsyncValue.data(currentState.copyWith(isFavorited: false));
      }
    }
  }

  /// Toggle favorito
  Future<bool> toggleFavorito(
    String diagnosticoId,
    Map<String, String> itemData,
  ) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final wasAlreadyFavorited = currentState.isFavorited;
    state = AsyncValue.data(
      currentState.copyWith(isFavorited: !wasAlreadyFavorited),
    );

    try {
      final favoritosRepository = ref.read(favoritosRepositorySimplifiedProvider);
      final result = await favoritosRepository.toggleFavorito(
        'diagnostico',
        diagnosticoId,
      );

      // Unwrap Either<Failure, bool>
      return result.fold(
        (failure) {
          // On failure, revert state
          state = AsyncValue.data(
            currentState.copyWith(isFavorited: wasAlreadyFavorited),
          );
          return false;
        },
        (success) {
          // On success, keep toggled state
          if (!success) {
            state = AsyncValue.data(
              currentState.copyWith(isFavorited: wasAlreadyFavorited),
            );
          }
          return success;
        },
      );
    } catch (e) {
      // On exception, revert state
      state = AsyncValue.data(
        currentState.copyWith(isFavorited: wasAlreadyFavorited),
      );
      return false;
    }
  }

  /// Build share text
  String buildShareText(
    String diagnosticoId,
    String nomeDefensivo,
    String nomePraga,
    String cultura,
  ) {
    final currentState = state.value;
    if (currentState == null) return '';

    final buffer = StringBuffer();
    buffer.writeln('🔬 DIAGNÓSTICO RECEITUAGRO');
    buffer.writeln('═' * 30);
    buffer.writeln();
    buffer.writeln('📋 INFORMAÇÕES GERAIS');
    buffer.writeln('• Defensivo: $nomeDefensivo');
    buffer.writeln('• Praga: $nomePraga');
    buffer.writeln('• Cultura: $cultura');
    buffer.writeln();
    if (currentState.diagnosticoData['ingredienteAtivo']?.isNotEmpty ?? false) {
      buffer.writeln('🧪 INGREDIENTE ATIVO');
      buffer.writeln('• ${currentState.diagnosticoData['ingredienteAtivo']}');
      buffer.writeln();
    }
    buffer.writeln('⚠️ CLASSIFICAÇÕES');
    buffer.writeln(
      '• Toxicológica: ${currentState.diagnosticoData['toxico'] ?? 'N/A'}',
    );
    buffer.writeln(
      '• Ambiental: ${currentState.diagnosticoData['classAmbiental'] ?? 'N/A'}',
    );
    buffer.writeln(
      '• Agronômica: ${currentState.diagnosticoData['classeAgronomica'] ?? 'N/A'}',
    );
    buffer.writeln();
    buffer.writeln('🔧 DETALHES TÉCNICOS');
    if (currentState.diagnosticoData['formulacao']?.isNotEmpty ?? false) {
      buffer.writeln(
        '• Formulação: ${currentState.diagnosticoData['formulacao']}',
      );
    }
    if (currentState.diagnosticoData['modoAcao']?.isNotEmpty ?? false) {
      buffer.writeln(
        '• Modo de Ação: ${currentState.diagnosticoData['modoAcao']}',
      );
    }
    if (currentState.diagnosticoData['mapa']?.isNotEmpty ?? false) {
      buffer.writeln(
        '• Registro MAPA: ${currentState.diagnosticoData['mapa']}',
      );
    }
    buffer.writeln();
    buffer.writeln('💧 INSTRUÇÕES DE APLICAÇÃO');
    if (currentState.diagnosticoData['dosagem']?.isNotEmpty ?? false) {
      buffer.writeln('• Dosagem: ${currentState.diagnosticoData['dosagem']}');
    }
    if (currentState.diagnosticoData['vazaoTerrestre']?.isNotEmpty ?? false) {
      buffer.writeln(
        '• Vazão Terrestre: ${currentState.diagnosticoData['vazaoTerrestre']}',
      );
    }
    if (currentState.diagnosticoData['vazaoAerea']?.isNotEmpty ?? false) {
      buffer.writeln(
        '• Vazão Aérea: ${currentState.diagnosticoData['vazaoAerea']}',
      );
    }
    if (currentState.diagnosticoData['intervaloAplicacao']?.isNotEmpty ??
        false) {
      buffer.writeln(
        '• Intervalo de Aplicação: ${currentState.diagnosticoData['intervaloAplicacao']}',
      );
    }
    if (currentState.diagnosticoData['intervaloSeguranca']?.isNotEmpty ??
        false) {
      buffer.writeln(
        '• Intervalo de Segurança: ${currentState.diagnosticoData['intervaloSeguranca']}',
      );
    }
    buffer.writeln();
    if (currentState.diagnosticoData['tecnologia']?.isNotEmpty ?? false) {
      buffer.writeln('🎯 TECNOLOGIA DE APLICAÇÃO');
      buffer.writeln(currentState.diagnosticoData['tecnologia']);
      buffer.writeln();
    }
    buffer.writeln('═' * 30);
    buffer.writeln('📱 Gerado pelo ReceitaAgro');
    buffer.writeln('Sua ferramenta de diagnóstico agrícola');

    return buffer.toString();
  }

  /// Copy text to clipboard
  Future<bool> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset state for new query
  void reset() {
    state = AsyncValue.data(DetalheDiagnosticoState.initial());
  }

  /// Clear error
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearError());
  }
}
