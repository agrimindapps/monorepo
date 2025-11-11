import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/models/diagnostico_legacy.dart';
import '../../../../core/data/repositories/diagnostico_legacy_repository.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/extensions/diagnostico_hive_extension.dart';
import '../../../../core/providers/premium_notifier.dart';
import '../../../diagnosticos/data/mappers/diagnostico_mapper.dart';
import '../../../diagnosticos/domain/entities/diagnostico_entity.dart';
import '../../../diagnosticos/domain/repositories/i_diagnosticos_repository.dart';
import '../../../favoritos/data/repositories/favoritos_repository_simplified.dart';
import '../../../favoritos/favoritos_di.dart';

part 'detalhe_diagnostico_notifier.g.dart';

/// Detalhe Diagnostico state
class DetalheDiagnosticoState {
  final DiagnosticoEntity? diagnostico;
  final DiagnosticoHive? diagnosticoHive;
  final Map<String, String> diagnosticoData;
  final bool isFavorited;
  final bool isPremium;
  final bool isLoading;
  final bool isSharingContent;
  final String? errorMessage;

  const DetalheDiagnosticoState({
    this.diagnostico,
    this.diagnosticoHive,
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
      diagnosticoHive: null,
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
    DiagnosticoHive? diagnosticoHive,
    Map<String, String>? diagnosticoData,
    bool? isFavorited,
    bool? isPremium,
    bool? isLoading,
    bool? isSharingContent,
    String? errorMessage,
  }) {
    return DetalheDiagnosticoState(
      diagnostico: diagnostico ?? this.diagnostico,
      diagnosticoHive: diagnosticoHive ?? this.diagnosticoHive,
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
@Riverpod(keepAlive: true)
class DetalheDiagnosticoNotifier extends _$DetalheDiagnosticoNotifier {
  late final IDiagnosticosRepository _diagnosticosRepository;
  late final DiagnosticoLegacyRepository _hiveRepository;
  late final FavoritosRepositorySimplified _favoritosRepository;

  @override
  Future<DetalheDiagnosticoState> build() async {
    _diagnosticosRepository = di.sl<IDiagnosticosRepository>();
    _hiveRepository = di.sl<DiagnosticoLegacyRepository>();
    _favoritosRepository = FavoritosDI.get<FavoritosRepositorySimplified>();

    // Setup listener APÓS o estado inicial ser retornado
    unawaited(Future.microtask(() => _setupPremiumStatusListener()));

    return DetalheDiagnosticoState.initial();
  }

  /// Load diagnostico data
  Future<void> loadDiagnosticoData(String diagnosticoId) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    try {
      final result = await _diagnosticosRepository.getById(diagnosticoId);

      await result.fold(
        (failure) async {
          throw Exception('Erro no repository Clean Architecture: $failure');
        },
        (diagnosticoEntity) async {
          if (diagnosticoEntity != null) {
            final diagnosticoHive = await _hiveRepository.getByIdOrObjectId(
              diagnosticoId,
            );

            // Extensão DiagnosticoHiveExtension já busca dados do defensivo internamente
            final diagnosticoData = diagnosticoHive != null
                ? await diagnosticoHive.toDataMap()
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
                    diagnosticoHive: diagnosticoHive,
                    diagnosticoData: diagnosticoData,
                    isLoading: false,
                  )
                  .clearError(),
            );

            // Load premium status after loading data
            await loadPremiumStatus();
          } else {
            final result = await _hiveRepository.getAll();
            final totalDiagnosticos = result.isSuccess
                ? result.data!.length
                : 0;
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
        final diagnosticoHive = await _hiveRepository.getByIdOrObjectId(
          diagnosticoId,
        );
        if (diagnosticoHive != null) {
          final diagnostico = DiagnosticoMapper.fromHive(diagnosticoHive);

          // Extensão DiagnosticoHiveExtension já busca dados do defensivo internamente
          final diagnosticoData = await diagnosticoHive.toDataMap();

          state = AsyncValue.data(
            currentState
                .copyWith(
                  diagnostico: diagnostico,
                  diagnosticoHive: diagnosticoHive,
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
      final premiumState = ref.read(premiumNotifierProvider).value;
      state = AsyncValue.data(
        currentState.copyWith(isPremium: premiumState?.isPremium ?? false),
      );
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(isPremium: false));
    }
  }

  /// Setup premium status listener
  void _setupPremiumStatusListener() {
    ref.listen(premiumNotifierProvider, (previous, next) {
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
      final isFavorited = await _favoritosRepository.isFavorito(
        'diagnostico',
        diagnosticoId,
      );
      state = AsyncValue.data(currentState.copyWith(isFavorited: isFavorited));
    } catch (e) {
      final isFavorited = await _favoritosRepository.isFavorito(
        'diagnosticos',
        diagnosticoId,
      );
      state = AsyncValue.data(currentState.copyWith(isFavorited: isFavorited));
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
      final success = await _favoritosRepository.toggleFavorito(
        'diagnostico',
        diagnosticoId,
      );

      if (!success) {
        state = AsyncValue.data(
          currentState.copyWith(isFavorited: wasAlreadyFavorited),
        );
        return false;
      }

      return true;
    } catch (e) {
      try {
        final success = await _favoritosRepository.toggleFavorito(
          'diagnostico',
          diagnosticoId,
        );

        if (!success) {
          state = AsyncValue.data(
            currentState.copyWith(isFavorited: wasAlreadyFavorited),
          );
          return false;
        }

        return true;
      } catch (fallbackError) {
        state = AsyncValue.data(
          currentState.copyWith(isFavorited: wasAlreadyFavorited),
        );
        return false;
      }
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
