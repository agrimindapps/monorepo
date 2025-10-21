// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/exercicio_model.dart';
import '../repository/exercicio_repository.dart';
import '../services/exercicio_logger_service.dart';

// ============================================================================
// CONTROLLER BASE - EXERCÍCIOS
// ============================================================================

// REFACTOR: PRIORIDADE ALTA - Separação de Responsabilidades
// - Controller base para funcionalidades compartilhadas entre páginas
// - Gerencia repository e operações CRUD básicas
// - Permite reutilização de código entre diferentes controllers

abstract class ExercicioBaseController extends GetxController {
  final ExercicioRepository _repository = ExercicioRepository();

  // Estados compartilhados
  final RxBool isLoading = false.obs;
  final RxList<ExercicioModel> registros = <ExercicioModel>[].obs;

  // Getters para acessar o repository
  ExercicioRepository get repository => _repository;

  // Métodos base para CRUD
  Future<List<ExercicioModel>> getExercicios() async {
    try {
      return await _repository.getExercicios();
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar exercícios: $e');
      rethrow;
    }
  }

  Future<ExercicioModel> saveExercicio(ExercicioModel exercicio) async {
    try {
      return await _repository.saveExercicio(exercicio);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao salvar exercício: $e');
      rethrow;
    }
  }

  Future<void> deleteExercicio(String exercicioId) async {
    try {
      await _repository.deleteExercicio(exercicioId);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao excluir exercício: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMetasExercicios() async {
    try {
      return await _repository.getMetasExercicios();
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar metas: $e');
      return {};
    }
  }

  Future<void> saveMetasExercicios(Map<String, dynamic> metas) async {
    try {
      await _repository.saveMetasExercicios(metas);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao salvar metas: $e');
      rethrow;
    }
  }

  // Método utilitário para formatação de data
  String formatDateTime(int dateTime) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(dateTime);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      ExercicioLoggerService.e('Erro ao formatar timestamp', 
        component: 'BaseController', context: {'timestamp': dateTime});
      return 'Data inválida';
    }
  }

  // Método utilitário para validação de timestamp
  bool isValidTimestamp(int timestamp) {
    try {
      DateTime.fromMillisecondsSinceEpoch(timestamp);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Método para buscar todos os exercícios e atualizar a lista
  Future<void> fetchAllExercicios() async {
    try {
      final exercicios = await getExercicios();
      registros.value = exercicios;
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar exercícios: $e');
      rethrow;
    }
  }
}
