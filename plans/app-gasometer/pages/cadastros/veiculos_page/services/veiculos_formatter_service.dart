// Internal dependencies

// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../../../../database/enums.dart';
import '../../veiculos_cadastro/models/veiculos_constants.dart';

/// Service responsável pela formatação de dados de veículos
class VeiculosFormatterService {
  // Formatação de odômetro
  static String formatOdometer(double value) {
    return '${value.toStringAsFixed(0)} ${VeiculosConstants.sufixos['quilometros']}';
  }

  // Formatação de título do veículo
  static String formatVehicleTitle(VeiculoCar veiculo) {
    return '${veiculo.marca} ${veiculo.modelo}';
  }

  // Formatação de subtítulo do veículo
  static String formatVehicleSubtitle(VeiculoCar veiculo) {
    return '${veiculo.ano} • ${veiculo.cor}';
  }

  // Formatação de combustível
  static String formatCombustivel(int combustivelIndex) {
    try {
      return TipoCombustivel.values[combustivelIndex].descricao;
    } catch (e) {
      return VeiculosConstants.mensagensInfo['naoInformado']!;
    }
  }

  // Formatação de campos opcionais
  static String formatFieldValue(String value) {
    return value.isEmpty
        ? VeiculosConstants.mensagensInfo['naoInformado']!
        : value;
  }

  // Formatação de valores monetários (para futuras implementações)
  static String formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Formatação de datas
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
