// Project imports:
import '../../../../controllers/medicoes_controller.dart';
import '../../../../controllers/pluviometros_controller.dart';
import '../../../../models/medicoes_models.dart';
import '../../../../models/pluviometros_models.dart';
import '../interfaces/repository_interface.dart';

class ResultadosPluviometroRepository
    implements IResultadosPluviometroRepository {
  final MedicoesController _medicoesController;
  final PluviometrosController _pluviometrosController;

  ResultadosPluviometroRepository({
    MedicoesController? medicoesController,
    PluviometrosController? pluviometrosController,
  })  : _medicoesController = medicoesController ?? MedicoesController(),
        _pluviometrosController =
            pluviometrosController ?? PluviometrosController();

  @override
  Future<List<Pluviometro>> carregarPluviometros() async {
    try {
      return await _pluviometrosController.getPluviometros();
    } catch (e) {
      throw Exception('Erro ao carregar pluviômetros: $e');
    }
  }

  @override
  Future<List<Medicoes>> carregarMedicoes(String pluviometroId) async {
    try {
      return await _medicoesController.getMedicoes(pluviometroId);
    } catch (e) {
      throw Exception('Erro ao carregar medições: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> carregarDadosCompletos() async {
    try {
      final pluviometros = await carregarPluviometros();

      if (pluviometros.isEmpty) {
        return {
          'pluviometros': <Pluviometro>[],
          'medicoes': <Medicoes>[],
          'pluviometroSelecionado': null,
        };
      }

      final primeiroPluviometro = pluviometros.first;
      final medicoes = await carregarMedicoes(primeiroPluviometro.id);

      return {
        'pluviometros': pluviometros,
        'medicoes': medicoes,
        'pluviometroSelecionado': primeiroPluviometro,
      };
    } catch (e) {
      throw Exception('Erro ao carregar dados completos: $e');
    }
  }

  @override
  Future<List<Medicoes>> carregarMedicoesPorPeriodo(
    String pluviometroId,
    DateTime inicio,
    DateTime fim,
  ) async {
    try {
      final medicoes = await carregarMedicoes(pluviometroId);

      return medicoes.where((medicao) {
        final dataMedicao =
            DateTime.fromMillisecondsSinceEpoch(medicao.dtMedicao);
        return dataMedicao.isAfter(inicio) && dataMedicao.isBefore(fim);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar medições por período: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> carregarEstatisticasBasicas(
      String pluviometroId) async {
    try {
      final medicoes = await carregarMedicoes(pluviometroId);

      if (medicoes.isEmpty) {
        return {
          'total': 0.0,
          'media': 0.0,
          'maximo': 0.0,
          'minimo': 0.0,
          'contagem': 0,
        };
      }

      double total =
          medicoes.fold(0.0, (sum, medicao) => sum + medicao.quantidade);
      double media = total / medicoes.length;
      double maximo =
          medicoes.map((m) => m.quantidade).reduce((a, b) => a > b ? a : b);
      double minimo =
          medicoes.map((m) => m.quantidade).reduce((a, b) => a < b ? a : b);

      return {
        'total': total,
        'media': media,
        'maximo': maximo,
        'minimo': minimo,
        'contagem': medicoes.length,
      };
    } catch (e) {
      throw Exception('Erro ao carregar estatísticas básicas: $e');
    }
  }
}
