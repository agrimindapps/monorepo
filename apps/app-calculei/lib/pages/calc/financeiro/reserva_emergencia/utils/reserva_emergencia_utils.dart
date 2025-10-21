// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:app_calculei/pages/calc/financeiro/reserva_emergencia/utils/model/reserva_emergencia_model.dart';

class ReservaEmergenciaUtils {
  // Formata um valor como moeda brasileira
  static String formatarMoeda(double valor) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return formatter.format(valor);
  }

  // Calcula o valor total da reserva de emergência
  static double calcularReserva(
    double despesasMensais,
    double despesasExtras,
    int mesesDesejados,
  ) {
    final totalMensal = despesasMensais + despesasExtras;
    return totalMensal * mesesDesejados;
  }

  // Estima o tempo necessário para construir a reserva com base no valor poupado mensalmente
  static Map<String, num> estimarTempoConstrucao(
    double valorTotalReserva,
    double valorPoupadoMensal,
  ) {
    // Se não houver valor poupado ou for muito pequeno, retorna zero
    if (valorPoupadoMensal <= 0 ||
        valorPoupadoMensal < (valorTotalReserva * 0.01)) {
      return {'anos': 0, 'meses': 0};
    }

    // Calcular número total de meses
    final mesesTotais = valorTotalReserva / valorPoupadoMensal;

    // Dividir em anos e meses
    final anos = (mesesTotais / 12).floor();
    final meses = (mesesTotais % 12).round();

    return {'anos': anos, 'meses': meses};
  }

  // Retorna uma cor para a categoria de reserva
  static int getCorCategoria(String categoria) {
    switch (categoria) {
      case 'Mínima':
        return Colors.red.value;
      case 'Básica':
        return Colors.orange.value;
      case 'Confortável':
        return Colors.green.shade400.value;
      case 'Robusta':
        return Colors.green.shade700.value;
      default:
        return Colors.blue.value;
    }
  }

  // Gera texto para compartilhamento
  static String gerarTextoCompartilhamento(ReservaEmergenciaModel modelo) {
    final sb = StringBuffer();
    sb.writeln('📊 MINHA RESERVA DE EMERGÊNCIA 📊');
    sb.writeln('');
    sb.writeln(
        '💰 Valor da Reserva: ${formatarMoeda(modelo.valorTotalReserva)}');
    sb.writeln('📅 Período: ${modelo.mesesDesejados} meses');
    sb.writeln('🏷️ Categoria: ${modelo.categoriaReserva}');
    sb.writeln('');
    sb.writeln('📝 Detalhes:');
    sb.writeln('- Despesas Mensais: ${formatarMoeda(modelo.despesasMensais)}');

    if (modelo.despesasExtras > 0) {
      sb.writeln('- Despesas Extras: ${formatarMoeda(modelo.despesasExtras)}');
    }

    sb.writeln('');
    sb.writeln(
        '💡 Dica: Mantenha sua reserva em investimentos de alta liquidez, como Tesouro Selic ou CDBs com liquidez diária.');
    sb.writeln('');
    sb.writeln('Calculado com o app NutriTuti');

    return sb.toString();
  }
}
