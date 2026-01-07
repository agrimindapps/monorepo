import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Share button widget for sharing calculation results
class ShareButton extends StatelessWidget {
  final String text;
  final String? subject;
  final IconData icon;
  final String? tooltip;

  const ShareButton({
    super.key,
    required this.text,
    this.subject,
    this.icon = Icons.share,
    this.tooltip = 'Compartilhar',
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () => _share(context),
    );
  }

  Future<void> _share(BuildContext context) async {
    try {
      await Share.share(text);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Share FAB (Floating Action Button)
class ShareFAB extends StatelessWidget {
  final String text;
  final String? subject;
  final String? label;

  const ShareFAB({super.key, required this.text, this.subject, this.label});

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: () => _share(context),
        icon: const Icon(Icons.share),
        label: Text(label!),
      );
    }

    return FloatingActionButton(
      onPressed: () => _share(context),
      child: const Icon(Icons.share),
    );
  }

  Future<void> _share(BuildContext context) async {
    try {
      await Share.share(text);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Utility class for formatting share messages
class ShareFormatter {
  static const String _footer = '''

_________________
Calculado por Calculei
by Agrimind
https://calculei.com.br''';

  /// Format vacation calculation for sharing
  static String formatVacationCalculation({
    required double grossSalary,
    required int vacationDays,
    required double totalGross,
    required double totalNet,
    int? dependents,
    bool? sellVacationDays,
  }) {
    return '''
📋 Cálculo de Férias - Calculei App

💰 Salário Bruto: R\$ ${grossSalary.toStringAsFixed(2)}
📅 Dias de Férias: $vacationDays
${sellVacationDays == true ? '💰 Abono Pecuniário (Venda): Sim' : ''}
${dependents != null ? '👨‍👩‍👧‍👦 Dependentes: $dependents' : ''}

✅ Total Bruto: R\$ ${totalGross.toStringAsFixed(2)}
💵 Total Líquido: R\$ ${totalNet.toStringAsFixed(2)}
$_footer''';
  }

  /// Format thirteenth salary calculation for sharing
  static String formatThirteenthSalary({
    required double grossSalary,
    required int monthsWorked,
    required double totalGross,
    required double totalNet,
    required bool isAdvance,
  }) {
    return '''
📋 Cálculo de 13º Salário - Calculei App

💰 Salário Bruto: R\$ ${grossSalary.toStringAsFixed(2)}
📅 Meses Trabalhados: $monthsWorked
${isAdvance ? '🔹 Primeira Parcela (Adiantamento)' : '🔹 Parcela Única / Segunda Parcela'}

✅ Total Bruto: R\$ ${totalGross.toStringAsFixed(2)}
💵 Total Líquido: R\$ ${totalNet.toStringAsFixed(2)}
$_footer''';
  }

  /// Format net salary calculation for sharing
  static String formatNetSalary({
    required double grossSalary,
    required double inss,
    required double ir,
    required double netSalary,
    double? discounts,
  }) {
    return '''
📋 Cálculo de Salário Líquido - Calculei App

💰 Salário Bruto: R\$ ${grossSalary.toStringAsFixed(2)}
${discounts != null && discounts > 0 ? '📉 Outros Descontos: R\$ ${discounts.toStringAsFixed(2)}' : ''}

📉 Descontos Legais:
• INSS: R\$ ${inss.toStringAsFixed(2)}
• IRRF: R\$ ${ir.toStringAsFixed(2)}

💵 Salário Líquido: R\$ ${netSalary.toStringAsFixed(2)}
$_footer''';
  }

  /// Format overtime calculation for sharing
  static String formatOvertime({
    required double grossSalary,
    required double totalOvertimeValue,
    required int weeklyHours,
  }) {
    return '''
📋 Cálculo de Horas Extras - Calculei App

💰 Salário Base: R\$ ${grossSalary.toStringAsFixed(2)}
⏱️ Jornada Semanal: ${weeklyHours}h

✅ Valor Total Horas Extras: R\$ ${totalOvertimeValue.toStringAsFixed(2)}
$_footer''';
  }

  /// Format unemployment insurance calculation for sharing
  static String formatUnemploymentInsurance({
    required double averageSalary,
    required int monthsWorked,
    required int installmentsCount,
    required double installmentValue,
  }) {
    return '''
📋 Cálculo de Seguro Desemprego - Calculei App

💰 Média Salarial: R\$ ${averageSalary.toStringAsFixed(2)}
📅 Meses Trabalhados: $monthsWorked

✅ Parcelas: $installmentsCount x R\$ ${installmentValue.toStringAsFixed(2)}
$_footer''';
  }

  /// Format emergency reserve calculation for sharing
  static String formatEmergencyReserve({
    required double monthlyExpenses,
    required int monthsToCover,
    required double totalReserve,
    double? monthlySavings,
  }) {
    return '''
📋 Reserva de Emergência - Calculei App

💸 Gastos Mensais: R\$ ${monthlyExpenses.toStringAsFixed(2)}
📅 Meses para Cobrir: $monthsToCover

✅ Valor da Reserva: R\$ ${totalReserve.toStringAsFixed(2)}
${monthlySavings != null && monthlySavings > 0 ? '💰 Investimento Mensal Sugerido: R\$ ${monthlySavings.toStringAsFixed(2)}' : ''}
$_footer''';
  }

  /// Format cash vs installment calculation for sharing
  static String formatCashVsInstallment({
    required double cashPrice,
    required double installmentPrice,
    required int installments,
    required String bestOption,
  }) {
    return '''
📋 À Vista ou Parcelado? - Calculei App

💵 Preço à Vista: R\$ ${cashPrice.toStringAsFixed(2)}
💳 Parcelado: $installments x R\$ ${installmentPrice.toStringAsFixed(2)}

✅ Melhor Opção: $bestOption
$_footer''';
  }

  /// Generic share message
  static String formatGeneric({
    required String title,
    required Map<String, String> data,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('📋 $title - Calculei App\n');

    data.forEach((key, value) {
      buffer.writeln('$key: $value');
    });

    buffer.writeln(_footer);

    return buffer.toString();
  }
}
