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
      await Share.share(
        text,
        subject: subject,
      );
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

  const ShareFAB({
    super.key,
    required this.text,
    this.subject,
    this.label,
  });

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
      await Share.share(
        text,
        subject: subject,
      );
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
  /// Format vacation calculation for sharing
  static String formatVacationCalculation({
    required double grossSalary,
    required int vacationDays,
    required double totalGross,
    required double totalNet,
  }) {
    return '''
📋 Cálculo de Férias - Calculei App

💰 Salário Bruto: R\$ ${grossSalary.toStringAsFixed(2)}
📅 Dias de Férias: $vacationDays

✅ Total Bruto: R\$ ${totalGross.toStringAsFixed(2)}
💵 Total Líquido: R\$ ${totalNet.toStringAsFixed(2)}

Calculado em: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
📱 Baixe o Calculei para fazer seus cálculos!
''';
  }

  /// Format thirteenth salary calculation for sharing
  static String formatThirteenthSalary({
    required double grossSalary,
    required int monthsWorked,
    required double totalGross,
    required double totalNet,
  }) {
    return '''
📋 Cálculo de 13º Salário - Calculei App

💰 Salário Bruto: R\$ ${grossSalary.toStringAsFixed(2)}
📅 Meses Trabalhados: $monthsWorked

✅ Total Bruto: R\$ ${totalGross.toStringAsFixed(2)}
💵 Total Líquido: R\$ ${totalNet.toStringAsFixed(2)}

Calculado em: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
📱 Baixe o Calculei para fazer seus cálculos!
''';
  }

  /// Format net salary calculation for sharing
  static String formatNetSalary({
    required double grossSalary,
    required double inss,
    required double ir,
    required double netSalary,
  }) {
    return '''
📋 Cálculo de Salário Líquido - Calculei App

💰 Salário Bruto: R\$ ${grossSalary.toStringAsFixed(2)}

📉 Descontos:
• INSS: R\$ ${inss.toStringAsFixed(2)}
• IR: R\$ ${ir.toStringAsFixed(2)}

💵 Salário Líquido: R\$ ${netSalary.toStringAsFixed(2)}

Calculado em: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
📱 Baixe o Calculei para fazer seus cálculos!
''';
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

    buffer.writeln();
    buffer.writeln(
        'Calculado em: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');
    buffer.writeln('📱 Baixe o Calculei para fazer seus cálculos!');

    return buffer.toString();
  }
}
