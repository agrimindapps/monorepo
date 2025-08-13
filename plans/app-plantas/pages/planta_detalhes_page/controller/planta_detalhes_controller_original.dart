// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../database/comentario_model.dart';
import '../../../database/espaco_model.dart';
import '../../../database/planta_config_model.dart';
import '../../../database/planta_model.dart';
import '../../../database/tarefa_model.dart';
import '../../../navigation/plantas_navigator.dart';
import '../../../repository/espaco_repository.dart';
import '../../../repository/planta_config_repository.dart';
import '../../../repository/planta_repository.dart';
import '../../../repository/tarefa_repository.dart';
import '../services/concurrency_service.dart';
import '../services/i18n_service.dart';
import '../services/state_management_service.dart';

class PlantaDetalhesController extends GetxController {
  final PlantaModel planta;
  late final PlantaState _plantaState;

  PlantaDetalhesController({required this.planta});

  // Getters para acessar estado reativo centralizado
  Rx<PlantaModel> get plantaAtual => _plantaState.plantaAtual;
  Rx<PlantaConfigModel?> get configuracoes => _plantaState.configuracoes;
  Rx<EspacoModel?> get espaco => _plantaState.espaco;
  RxList<TarefaModel> get tarefasRecentes => _plantaState.tarefasRecentes;
  RxList<TarefaModel> get proximasTarefas => _plantaState.proximasTarefas;
  RxBool get isLoading => _plantaState.isLoading;
  RxBool get isLoadingTarefas => _plantaState.isLoadingTarefas;
  RxBool get hasError => _plantaState.hasError;
  RxString get errorMessage => _plantaState.errorMessage;

  // Controllers para comentários
  final TextEditingController comentarioController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Inicializar estado centralizado
    _plantaState = StateManagementService.getPlantaState(planta.id, planta);
    _carregarDados();
  }

  @override
  void onClose() {
    // Cancelar operações pendentes para este controller
    ConcurrencyService.cancelOperation('carregar_dados_${planta.id}');
    ConcurrencyService.cancelOperation('adicionar_comentario_${planta.id}');
    ConcurrencyService.cancelOperation('comentarios_${planta.id}');
    ConcurrencyService.cancelOperation('refresh_${planta.id}');

    // Não remover estado aqui - pode ser reutilizado por outras instâncias
    // StateManagementService.removePlantaState(planta.id);

    comentarioController.dispose();
    super.onClose();
  }

  Future<void> _carregarDados() async {
    await ConcurrencyService.withLock('carregar_dados_${planta.id}', () async {
      try {
        _plantaState.setLoading(true);

        // Carregar dados em paralelo com timeout
        await ConcurrencyService.executeWithTimeout([
          _carregarConfiguracoes(),
          _carregarEspaco(),
          _carregarTarefas(),
        ], const Duration(seconds: 30));
      } catch (e) {
        debugPrint('❌ Erro ao carregar dados da planta: $e');
        Get.snackbar(
          I18nService.error,
          '${I18nService.errorLoadingData}: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        _plantaState.setLoading(false);
      }
    });
  }

  Future<void> _carregarConfiguracoes() async {
    try {
      final configRepo = PlantaConfigRepository.instance;
      await configRepo.initialize();
      final config = await configRepo.findByPlantaId(planta.id);
      _plantaState.updateConfiguracoes(config);
    } catch (e) {
      debugPrint('❌ Erro ao carregar configurações: $e');
    }
  }

  Future<void> _carregarEspaco() async {
    try {
      if (planta.espacoId != null) {
        final espacoRepo = EspacoRepository.instance;
        await espacoRepo.initialize();
        final espacoData = await espacoRepo.findById(planta.espacoId!);
        _plantaState.updateEspaco(espacoData);
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar espaço: $e');
    }
  }

  Future<void> _carregarTarefas() async {
    try {
      _plantaState.setLoadingTarefas(true);

      // Usar repository diretamente
      final tarefaRepo = TarefaRepository.instance;
      await tarefaRepo.initialize();

      // Carregar tarefas da planta
      final todasTarefas = await tarefaRepo.findByPlanta(planta.id);
      final agora = DateTime.now();
      final trintaDiasAtras = agora.subtract(const Duration(days: 30));

      // Filtrar tarefas concluídas recentemente
      final tarefasRecentesData = todasTarefas
          .where((tarefa) =>
              tarefa.concluida &&
              tarefa.dataConclusao != null &&
              tarefa.dataConclusao!.isAfter(trintaDiasAtras))
          .toList()
        ..sort((a, b) => b.dataConclusao!.compareTo(a.dataConclusao!));

      // Filtrar próximas tarefas (não concluídas)
      final proximasTarefasData = todasTarefas
          .where((tarefa) => !tarefa.concluida)
          .toList()
        ..sort((a, b) => a.dataExecucao.compareTo(b.dataExecucao));

      // Atualizar estado centralizado
      _plantaState.updateTarefas(tarefasRecentesData, proximasTarefasData);
    } catch (e) {
      debugPrint('❌ Erro ao carregar tarefas: $e');
    } finally {
      _plantaState.setLoadingTarefas(false);
    }
  }

  Future<void> adicionarComentario() async {
    final texto = comentarioController.text.trim();
    if (texto.isEmpty) return;

    // Usar debounce para evitar adições múltiplas rápidas
    await ConcurrencyService.debounceAsync(
      'adicionar_comentario_${planta.id}',
      const Duration(milliseconds: 500),
      () => _executarAdicaoComentario(texto),
    );
  }

  Future<void> _executarAdicaoComentario(String texto) async {
    await ConcurrencyService.withLock('comentarios_${planta.id}', () async {
      try {
        final novoComentario = ComentarioModel(
          id: '',
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          conteudo: texto,
          dataCriacao: DateTime.now(),
        );

        // Usar estado centralizado para adicionar comentário
        await _plantaState.adicionarComentario(novoComentario);
        comentarioController.clear();

        Get.snackbar(
          I18nService.success,
          I18nService.commentAdded,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF20B2AA),
          colorText: Colors.white,
        );
      } catch (e) {
        debugPrint('❌ Erro ao adicionar comentário: $e');
        Get.snackbar(
          I18nService.error,
          '${I18nService.errorAddingComment}: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }

  Future<void> removerComentario(ComentarioModel comentario) async {
    await ConcurrencyService.withLock('comentarios_${planta.id}', () async {
      try {
        // Usar estado centralizado para remover comentário
        await _plantaState.removerComentario(comentario);

        Get.snackbar(
          I18nService.success,
          I18nService.commentRemoved,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF20B2AA),
          colorText: Colors.white,
        );
      } catch (e) {
        debugPrint('❌ Erro ao remover comentário: $e');
        Get.snackbar(
          I18nService.error,
          '${I18nService.errorRemovingComment}: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }

  Future<void> marcarTarefaConcluida(TarefaModel tarefa) async {
    await ConcurrencyService.withLock('tarefa_${tarefa.id}', () async {
      try {
        // Usar repository diretamente para marcar como concluída com timeout
        await ConcurrencyService.executeWithTimeout([
          () async {
            final tarefaRepo = TarefaRepository.instance;
            await tarefaRepo.initialize();
            await tarefaRepo.marcarConcluida(tarefa.id);
          }(),
        ], const Duration(seconds: 15));

        // Recarregar tarefas de forma segura
        await _carregarTarefas();

        Get.snackbar(
          I18nService.success,
          I18nService.getFormatted(
              'taskCompleted', {'task': tarefa.tipoCuidado}),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF20B2AA),
          colorText: Colors.white,
        );
      } catch (e) {
        debugPrint('❌ Erro ao marcar tarefa como concluída: $e');
        Get.snackbar(
          I18nService.error,
          '${I18nService.errorMarkingTask}: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }

  Future<void> editarPlanta() async {
    final result = await PlantasNavigator.toEditarPlanta(plantaAtual.value);
    if (result == true) {
      // Recarregar dados após edição
      await _carregarDados();
    }
  }

  Future<void> removerPlanta() async {
    final confirmed = await PlantasNavigator.showRemoveConfirmation(
        plantaAtual.value.nome ?? 'Planta');

    if (confirmed) {
      await ConcurrencyService.withLock('remover_planta_${planta.id}',
          () async {
        try {
          // Remover planta com timeout
          await ConcurrencyService.executeWithTimeout([
            () async {
              final plantaRepo = PlantaRepository.instance;
              await plantaRepo.initialize();
              await plantaRepo.delete(planta.id);
            }(),
          ], const Duration(seconds: 20));

          Get.back(); // Voltar para a tela anterior
          Get.snackbar(
            I18nService.success,
            I18nService.plantRemoved,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF20B2AA),
            colorText: Colors.white,
          );
        } catch (e) {
          debugPrint('❌ Erro ao remover planta: $e');
          Get.snackbar(
            I18nService.error,
            '${I18nService.errorRemovingPlant}: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      });
    }
  }

  @override
  Future<void> refresh() async {
    // Usar debounce para evitar múltiplos refreshes rápidos
    ConcurrencyService.debounce(
      'refresh_${planta.id}',
      const Duration(milliseconds: 300),
      () => _carregarDados(),
    );
  }

  // Getters convenientes
  String get nomeFormatado => plantaAtual.value.nome ?? I18nService.noPlantName;
  String get especieFormatada =>
      plantaAtual.value.especie ?? I18nService.noPlantSpecies;
  String get espacoFormatado =>
      espaco.value?.nome ?? I18nService.noSpaceDefined;
  List<ComentarioModel> get comentariosOrdenados {
    final comentarios = plantaAtual.value.comentarios ?? [];
    return List<ComentarioModel>.from(comentarios)
      ..sort((a, b) {
        final dateA =
            a.dataCriacao ?? DateTime.fromMillisecondsSinceEpoch(a.createdAt);
        final dateB =
            b.dataCriacao ?? DateTime.fromMillisecondsSinceEpoch(b.createdAt);
        return dateB.compareTo(dateA);
      });
  }

  int get totalTarefasConcluidas => tarefasRecentes.length;
  int get totalProximasTarefas => proximasTarefas.length;

  bool get temConfiguracoes => configuracoes.value != null;
  bool get temComentarios =>
      (plantaAtual.value.comentarios?.isNotEmpty) ?? false;
}
