// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../data/volume_sanguineo_data.dart';

/// Formatador especializado para dados de volume sanguíneo
///
/// Responsável apenas pela formatação e apresentação de dados,
/// sem lógica de negócio ou dependências de UI.
class VolumeSanguineoFormatter {
  static final NumberFormat _weightFormat = NumberFormat('#,##0.00', 'pt_BR');
  static final NumberFormat _volumeFormat = NumberFormat('#,##0.000', 'pt_BR');
  static final NumberFormat _percentFormat = NumberFormat('#,##0.0', 'pt_BR');
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

  /// Formata peso em kg
  static String formatWeight(double weight) {
    return '${_weightFormat.format(weight)} kg';
  }

  /// Formata volume em litros
  static String formatVolume(double volume) {
    return '${_volumeFormat.format(volume)} L';
  }

  /// Formata percentual
  static String formatPercentage(double percentage) {
    return '${_percentFormat.format(percentage)}%';
  }

  /// Formata fator de cálculo
  static String formatFactor(int factor) {
    return '$factor ml/kg';
  }

  /// Formata data e hora
  static String formatDateTime(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  /// Formata data sem hora
  static String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(dateTime);
  }

  /// Gera texto para compartilhamento
  static String generateShareText(VolumeSanguineoData data) {
    if (!data.isCalculated) {
      throw StateError('Dados não foram calculados');
    }

    final buffer = StringBuffer();
    buffer.writeln('📊 Volume Sanguíneo');
    buffer.writeln();
    buffer.writeln('👤 Dados de Entrada:');
    buffer.writeln('• Tipo: ${data.tipoPessoaTexto}');
    buffer.writeln('• Peso: ${formatWeight(data.peso)}');
    buffer.writeln();
    buffer.writeln('🩸 Resultados:');
    buffer.writeln(
        '• Volume sanguíneo: ${formatVolume(data.volumeSanguineoLitros!)}');
    buffer.writeln('• Fator utilizado: ${formatFactor(data.fatorCalculoMlKg)}');

    if (data.dataCalculo != null) {
      buffer.writeln('• Calculado em: ${formatDateTime(data.dataCalculo!)}');
    }

    buffer.writeln();
    buffer.writeln(
        'ℹ️ Este cálculo fornece uma estimativa baseada em valores médios.');
    buffer.writeln('O volume real pode variar conforme fatores individuais.');

    return buffer.toString();
  }

  /// Gera resumo técnico para profissionais
  static String generateTechnicalSummary(VolumeSanguineoData data) {
    if (!data.isCalculated) {
      throw StateError('Dados não foram calculados');
    }

    final buffer = StringBuffer();
    buffer.writeln('CÁLCULO DE VOLUME SANGUÍNEO');
    buffer.writeln('=' * 40);
    buffer.writeln('Paciente: ${data.tipoPessoaTexto}');
    buffer.writeln('Peso corporal: ${formatWeight(data.peso)}');
    buffer.writeln('Fator aplicado: ${formatFactor(data.fatorCalculoMlKg)}');
    buffer.writeln();
    buffer.writeln('FÓRMULA: Volume (L) = Peso (kg) × Fator (ml/kg) ÷ 1000');
    buffer.writeln(
        'CÁLCULO: ${data.peso} × ${data.fatorCalculoMlKg} ÷ 1000 = ${formatVolume(data.volumeSanguineoLitros!)}');
    buffer.writeln();
    buffer.writeln('RESULTADO: ${formatVolume(data.volumeSanguineoLitros!)}');

    if (data.dataCalculo != null) {
      buffer.writeln('Data/Hora: ${formatDateTime(data.dataCalculo!)}');
    }

    return buffer.toString();
  }

  /// Formata dados para exibição em cards
  static Map<String, String> formatForCards(VolumeSanguineoData data) {
    return {
      'tipo': data.tipoPessoaTexto,
      'peso': formatWeight(data.peso),
      'volume': data.isCalculated
          ? formatVolume(data.volumeSanguineoLitros!)
          : 'Não calculado',
      'fator': formatFactor(data.fatorCalculoMlKg),
      'data': data.dataCalculo != null
          ? formatDateTime(data.dataCalculo!)
          : 'Não disponível',
    };
  }

  /// Formata para CSV (exportação)
  static String formatForCsv(VolumeSanguineoData data) {
    final peso = data.peso.toString().replaceAll('.', ',');
    final volume = data.isCalculated
        ? data.volumeSanguineoLitros.toString().replaceAll('.', ',')
        : '';
    final dataCalculo = data.dataCalculo?.toIso8601String() ?? '';

    return '"${data.tipoPessoaTexto}",$peso,${data.fatorCalculoMlKg},$volume,$dataCalculo';
  }

  /// Cabeçalho CSV
  static String get csvHeader => 'Tipo,Peso(kg),Fator(ml/kg),Volume(L),Data';

  /// Formata valor monetário (para custos de procedimentos)
  static String formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  /// Formata duração em minutos
  static String formatDuration(double minutes) {
    if (minutes < 1) {
      return '${(minutes * 60).toStringAsFixed(0)} segundos';
    } else if (minutes < 60) {
      return '${minutes.toStringAsFixed(1)} minutos';
    } else {
      final hours = minutes / 60;
      return '${hours.toStringAsFixed(1)} horas';
    }
  }

  /// Formata número grande (ex: contagem de células)
  static String formatLargeNumber(double number) {
    if (number >= 1e9) {
      return '${(number / 1e9).toStringAsFixed(1)}B';
    } else if (number >= 1e6) {
      return '${(number / 1e6).toStringAsFixed(1)}M';
    } else if (number >= 1e3) {
      return '${(number / 1e3).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }
}
