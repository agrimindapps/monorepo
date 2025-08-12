// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../database/23_abastecimento_model.dart';
import '../../../../repository/abastecimentos_repository.dart';
import '../../../../repository/veiculos_repository.dart';

class AbastecimentoService extends GetxService {
  final AbastecimentosRepository _abastecimentosRepository =
      AbastecimentosRepository();
  final VeiculosRepository _veiculosRepository = VeiculosRepository();

  final Map<String, List<AbastecimentoCar>> _abastecimentosCache = {};

  Future<List<AbastecimentoCar>> getAbastecimentosByVeiculoId(
      String veiculoId) async {
    if (_abastecimentosCache.containsKey(veiculoId)) {
      return _abastecimentosCache[veiculoId]!;
    }
    final abastecimentos =
        await _abastecimentosRepository.getAbastecimentos(veiculoId);
    _abastecimentosCache[veiculoId] = abastecimentos;
    return abastecimentos;
  }

  Future<void> addAbastecimento(AbastecimentoCar abastecimento) async {
    await _abastecimentosRepository.addAbastecimento(abastecimento);
    _abastecimentosCache.clear(); // Invalidate cache
  }

  Future<void> updateAbastecimento(AbastecimentoCar abastecimento) async {
    await _abastecimentosRepository.updateAbastecimento(abastecimento);
    _abastecimentosCache.clear(); // Invalidate cache
  }

  Future<void> deleteAbastecimento(AbastecimentoCar abastecimento) async {
    await _abastecimentosRepository.deleteAbastecimento(abastecimento);
    _abastecimentosCache.clear(); // Invalidate cache
  }

  Future<void> updateOdometroAtual(String veiculoId, double odometro) async {
    await _veiculosRepository.updateOdometroAtual(veiculoId, odometro);
  }

  Future<String> getSelectedVeiculoId() async {
    return _veiculosRepository.getSelectedVeiculoId();
  }

  List<DateTime> generateMonthsList(
      Map<DateTime, List<AbastecimentoCar>> abastecimentosAgrupados) {
    final List<DateTime> months = abastecimentosAgrupados.keys.toList();
    months.sort((a, b) => b.compareTo(a)); // Sort in descending order
    return months;
  }

  Map<String, dynamic> calcularMetricasMensais(
      DateTime date, List<AbastecimentoCar> abastecimentosDoMes) {
    double totalGastoMes = 0.0;
    double totalLitrosMes = 0.0;
    int count = 0;

    for (var abastecimento in abastecimentosDoMes) {
      totalGastoMes += abastecimento.valorTotal;
      totalLitrosMes += abastecimento.litros;
      count++;
    }

    final precoMedioLitro =
        totalLitrosMes > 0 ? totalGastoMes / totalLitrosMes : 0.0;
    final mediaConsumoMes = count > 1
        ? (abastecimentosDoMes.last.odometro -
                abastecimentosDoMes.first.odometro) /
            totalLitrosMes
        : 0.0;

    return {
      'totalGastoMes': totalGastoMes,
      'totalLitrosMes': totalLitrosMes,
      'precoMedioLitro': precoMedioLitro,
      'mediaConsumoMes': mediaConsumoMes,
    };
  }

  Map<DateTime, List<AbastecimentoCar>> groupAbastecimentosByMonth(
      List<AbastecimentoCar> abastecimentos) {
    final Map<DateTime, List<AbastecimentoCar>> grouped = {};
    for (var abastecimento in abastecimentos) {
      final date = DateTime.fromMillisecondsSinceEpoch(abastecimento.data);
      final monthStart = DateTime(date.year, date.month);
      if (!grouped.containsKey(monthStart)) {
        grouped[monthStart] = [];
      }
      grouped[monthStart]!.add(abastecimento);
    }
    return grouped;
  }
}
