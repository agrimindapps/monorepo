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
import '../services/comentarios_service.dart';
import '../services/i18n_service.dart';
import '../services/planta_data_service.dart';
import '../services/planta_detalhes_service.dart';
import '../services/state_management_service.dart';
import '../services/tarefas_management_service.dart';

/// Controller refatorado usando composição e services especializados
/// Mantém apenas controle de estado de UI, delegando lógica para services
class PlantaDetalhesController extends GetxController {
  final PlantaModel planta;
  late final PlantaState _plantaState;

  PlantaDetalhesController({required this.planta});

  // ========== SERVICES (COMPOSIÇÃO) ==========

  /// Service principal para orquestração de dados
  final _dataService = PlantaDataService.instance;

  /// Service especializado para comentários
  final _comentariosService = ComentariosService.instance;

  /// Service especializado para tarefas
  final _tarefasService = TarefasManagementService.instance;

  /// Service para operações com planta
  final _plantaService = PlantaDetalhesService.instance;

  // ========== ESTADO REATIVO (DELEGADO) ==========

  /// Getters para acessar estado reativo centralizado
  Rx<PlantaModel> get plantaAtual => _plantaState.plantaAtual;
  Rx<PlantaConfigModel?> get configuracoes => _plantaState.configuracoes;
  Rx<EspacoModel?> get espaco => _plantaState.espaco;
  RxList<TarefaModel> get tarefasRecentes => _plantaState.tarefasRecentes;
  RxList<TarefaModel> get proximasTarefas => _plantaState.proximasTarefas;
  RxBool get isLoading => _plantaState.isLoading;
  RxBool get isLoadingTarefas => _plantaState.isLoadingTarefas;
  RxBool get hasError => _plantaState.hasError;
  RxString get errorMessage => _plantaState.errorMessage;

  // ========== UI CONTROLLERS ==========

  final TextEditingController comentarioController = TextEditingController();

  // ========== LIFECYCLE ==========

  @override
  void onInit() {
    super.onInit();
    _initializeState();
    _carregarDados();
    debugPrint(
        '🔄 PlantaDetalhesController: Inicializado com arquitetura de services');
  }

  @override
  void onClose() {
    // Cancelar operações pendentes via service
    _dataService.cancelarOperacoesPendentes(planta.id);
    _comentariosService.cancelarOperacoesPendentes(planta.id);
    comentarioController.dispose();
    super.onClose();
  }

  // ========== INITIALIZATION ==========

  /// Inicializa estado centralizado
  void _initializeState() {
    _plantaState = StateManagementService.getPlantaState(planta.id, planta);
  }

  // ========== OPERAÇÕES PRINCIPAIS (DELEGADAS) ==========

  /// Carrega todos os dados usando service orquestrador
  Future<void> _carregarDados() async {
    try {
      _plantaState.setLoading(true);

      debugPrint('🔄 PlantaDetalhesController: Carregando dados via service');

      // Usar service orquestrador para carregar tudo
      final resultado = await _dataService.carregarDadosCompletos(planta.id);

      if (resultado.success) {
        // Atualizar estado centralizado com dados carregados
        if (resultado.planta != null) {
          _plantaState.updatePlanta(resultado.planta!);
        }
        _plantaState.updateConfiguracoes(resultado.configuracoes);
        _plantaState.updateEspaco(resultado.espaco);

        // Atualizar tarefas categorizadas
        _plantaState.updateTarefas(
            resultado.tarefasData.recentes, resultado.tarefasData.proximas);

        debugPrint('✅ PlantaDetalhesController: Dados carregados com sucesso');
      } else {
        _showError(
            'Erro ao carregar dados', resultado.error ?? 'Erro desconhecido');
      }
    } catch (e) {
      debugPrint('❌ PlantaDetalhesController: Erro ao carregar dados: $e');
      _showError('Erro ao carregar dados', e.toString());
    } finally {
      _plantaState.setLoading(false);
    }
  }

  /// Adiciona comentário usando service especializado
  Future<void> adicionarComentario() async {
    final texto = comentarioController.text.trim();
    if (texto.isEmpty) return;

    try {
      debugPrint(
          '💬 PlantaDetalhesController: Adicionando comentário via service');

      final resultado = await _comentariosService.adicionarComentario(
        plantaId: planta.id,
        conteudo: texto,
      );

      if (resultado.success) {
        // Atualizar estado através do service de estado
        if (resultado.comentario != null) {
          await _plantaState.adicionarComentario(resultado.comentario!);
        }

        comentarioController.clear();
        _showSuccess(I18nService.commentAdded);
        debugPrint(
            '✅ PlantaDetalhesController: Comentário adicionado com sucesso');
      } else {
        _showError(I18nService.error,
            resultado.error ?? 'Erro ao adicionar comentário');
      }
    } catch (e) {
      debugPrint(
          '❌ PlantaDetalhesController: Erro ao adicionar comentário: $e');
      _showError(I18nService.error, e.toString());
    }
  }

  /// Remove comentário usando service especializado
  Future<void> removerComentario(ComentarioModel comentario) async {
    try {
      debugPrint(
          '🗑️ PlantaDetalhesController: Removendo comentário via service');

      final resultado = await _comentariosService.removerComentario(
        plantaId: planta.id,
        comentario: comentario,
      );

      if (resultado.success) {
        // Atualizar estado através do service de estado
        await _plantaState.removerComentario(comentario);

        _showSuccess(I18nService.commentRemoved);
        debugPrint(
            '✅ PlantaDetalhesController: Comentário removido com sucesso');
      } else {
        _showError(
            I18nService.error, resultado.error ?? 'Erro ao remover comentário');
      }
    } catch (e) {
      debugPrint('❌ PlantaDetalhesController: Erro ao remover comentário: $e');
      _showError(I18nService.error, e.toString());
    }
  }

  /// Marca tarefa como concluída usando service especializado
  Future<void> marcarTarefaConcluida(TarefaModel tarefa) async {
    try {
      debugPrint(
          '✅ PlantaDetalhesController: Marcando tarefa como concluída via service');

      final resultado =
          await _tarefasService.marcarTarefaConcluida(tarefa: tarefa);

      if (resultado.success) {
        // Recarregar tarefas para refletir mudanças
        await _recarregarTarefas();

        _showSuccess(resultado.message ??
            I18nService.getFormatted(
                'taskCompleted', {'task': tarefa.tipoCuidado}));
        debugPrint('✅ PlantaDetalhesController: Tarefa marcada como concluída');
      } else {
        _showError(I18nService.error,
            resultado.error ?? 'Erro ao marcar tarefa como concluída');
      }
    } catch (e) {
      debugPrint('❌ PlantaDetalhesController: Erro ao marcar tarefa: $e');
      _showError(I18nService.error, e.toString());
    }
  }

  /// Reagenda tarefa usando service especializado
  Future<void> reagendarTarefa(TarefaModel tarefa, DateTime novaData) async {
    try {
      debugPrint('📅 PlantaDetalhesController: Reagendando tarefa via service');

      final resultado = await _tarefasService.reagendarTarefa(
        tarefa: tarefa,
        novaData: novaData,
      );

      if (resultado.success) {
        // Recarregar tarefas para refletir mudanças
        await _recarregarTarefas();

        _showSuccess(resultado.message ?? 'Tarefa reagendada com sucesso');
        debugPrint('✅ PlantaDetalhesController: Tarefa reagendada');
      } else {
        _showError(
            I18nService.error, resultado.error ?? 'Erro ao reagendar tarefa');
      }
    } catch (e) {
      debugPrint('❌ PlantaDetalhesController: Erro ao reagendar tarefa: $e');
      _showError(I18nService.error, e.toString());
    }
  }

  /// Edita planta usando navegação e service
  Future<void> editarPlanta() async {
    try {
      final result = await PlantasNavigator.toEditarPlanta(plantaAtual.value);
      if (result == true) {
        // Sincronizar dados após edição
        await _sincronizarDados();
      }
    } catch (e) {
      debugPrint(
          '❌ PlantaDetalhesController: Erro na navegação para edição: $e');
      _showError('Erro', 'Não foi possível abrir a tela de edição');
    }
  }

  /// Remove planta com confirmação usando service
  Future<void> removerPlanta() async {
    try {
      final confirmed = await PlantasNavigator.showRemoveConfirmation(
          plantaAtual.value.nome ?? 'Planta');

      if (confirmed) {
        debugPrint(
            '🗑️ PlantaDetalhesController: Removendo planta via service');

        final resultado = await _plantaService.removerPlanta(planta.id);

        if (resultado.success) {
          Get.back(); // Voltar para a tela anterior
          _showSuccess(I18nService.plantRemoved);
          debugPrint('✅ PlantaDetalhesController: Planta removida com sucesso');
        } else {
          _showError(
              I18nService.error, resultado.error ?? 'Erro ao remover planta');
        }
      }
    } catch (e) {
      debugPrint('❌ PlantaDetalhesController: Erro ao remover planta: $e');
      _showError(I18nService.error, e.toString());
    }
  }

  // ========== OPERAÇÕES AUXILIARES ==========

  /// Recarrega apenas tarefas de forma otimizada
  Future<void> _recarregarTarefas() async {
    try {
      _plantaState.setLoadingTarefas(true);

      final tarefasData =
          await _tarefasService.carregarTarefasPlanta(planta.id);

      if (tarefasData.success) {
        _plantaState.updateTarefas(tarefasData.recentes, tarefasData.proximas);
      }
    } catch (e) {
      debugPrint('❌ PlantaDetalhesController: Erro ao recarregar tarefas: $e');
    } finally {
      _plantaState.setLoadingTarefas(false);
    }
  }

  /// Sincroniza todos os dados usando service orquestrador
  Future<void> _sincronizarDados() async {
    try {
      debugPrint(
          '🔄 PlantaDetalhesController: Sincronizando dados via service');

      final resultado = await _dataService.sincronizarTudo(planta.id);

      if (resultado.success) {
        // Atualizar estado com dados sincronizados
        if (resultado.plantaDetalhes?.planta != null) {
          _plantaState.updatePlanta(resultado.plantaDetalhes!.planta!);
        }
        if (resultado.plantaDetalhes?.configuracoes != null) {
          _plantaState
              .updateConfiguracoes(resultado.plantaDetalhes!.configuracoes);
        }
        if (resultado.plantaDetalhes?.espaco != null) {
          _plantaState.updateEspaco(resultado.plantaDetalhes!.espaco);
        }
        if (resultado.tarefasData != null) {
          _plantaState.updateTarefas(
              resultado.tarefasData!.recentes, resultado.tarefasData!.proximas);
        }

        debugPrint('✅ PlantaDetalhesController: Dados sincronizados');
      }
    } catch (e) {
      debugPrint('❌ PlantaDetalhesController: Erro na sincronização: $e');
    }
  }

  @override
  Future<void> refresh() async {
    debugPrint('🔄 PlantaDetalhesController: Executando refresh via service');
    await _sincronizarDados();
  }

  // ========== GETTERS CONVENIENTES (SIMPLIFICADOS) ==========

  String get nomeFormatado => plantaAtual.value.nome ?? I18nService.noPlantName;
  String get especieFormatada =>
      plantaAtual.value.especie ?? I18nService.noPlantSpecies;
  String get espacoFormatado =>
      espaco.value?.nome ?? I18nService.noSpaceDefined;

  /// Comentários ordenados usando service
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

  // ========== OPERAÇÕES DE ESTATÍSTICAS ==========

  /// Obtém resumo executivo usando service
  Future<String> get resumoExecutivo async {
    try {
      final summary = await _dataService.obterResumoExecutivo(planta.id);

      final comentarios = summary.comentarioStats?.resumo ?? 'Sem comentários';
      final tarefas = summary.tarefaStats?.resumo ?? 'Sem tarefas';
      final cronograma =
          summary.cronogramaResumo?.statusResumo ?? 'Sem cronograma';

      return 'Comentários: $comentarios\nTarefas: $tarefas\nCronograma: $cronograma';
    } catch (e) {
      return 'Erro ao gerar resumo: $e';
    }
  }

  /// Verifica integridade dos dados
  Future<String> verificarIntegridade() async {
    try {
      final resultado = await _dataService.verificarConsistencia(planta.id);
      return resultado.summary;
    } catch (e) {
      return 'Erro na verificação: $e';
    }
  }

  // ========== MÉTODOS UTILITÁRIOS PRIVADOS ==========

  /// Exibe mensagem de sucesso padronizada
  void _showSuccess(String message) {
    Get.snackbar(
      I18nService.success,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF20B2AA),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Exibe mensagem de erro padronizada
  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}
