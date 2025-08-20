// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'despesas_date_utils.dart';

class DespesasDisplayUtils {
  static String getTipoIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'veterinário':
      case 'consulta':
        return '🏥';
      case 'medicamento':
      case 'remédio':
        return '💊';
      case 'ração':
      case 'comida':
      case 'alimentação':
        return '🍽️';
      case 'brinquedo':
      case 'brinquedos':
        return '🧸';
      case 'higiene':
      case 'limpeza':
        return '🧽';
      case 'transporte':
        return '🚗';
      case 'hotel':
      case 'hospedagem':
        return '🏨';
      case 'estética':
      case 'tosquia':
        return '✂️';
      case 'vacina':
      case 'vacinação':
        return '💉';
      case 'cirurgia':
        return '⚕️';
      case 'exame':
      case 'exames':
        return '🔬';
      case 'emergência':
      case 'urgência':
        return '🚨';
      case 'petshop':
        return '🏪';
      case 'outros':
      default:
        return '💰';
    }
  }

  static Color getTipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'veterinário':
      case 'consulta':
        return const Color(0xFF4CAF50); // Green
      case 'medicamento':
      case 'remédio':
        return const Color(0xFF2196F3); // Blue
      case 'ração':
      case 'comida':
      case 'alimentação':
        return const Color(0xFFFF9800); // Orange
      case 'brinquedo':
      case 'brinquedos':
        return const Color(0xFFE91E63); // Pink
      case 'higiene':
      case 'limpeza':
        return const Color(0xFF9C27B0); // Purple
      case 'transporte':
        return const Color(0xFF607D8B); // Blue Grey
      case 'hotel':
      case 'hospedagem':
        return const Color(0xFF795548); // Brown
      case 'estética':
      case 'tosquia':
        return const Color(0xFFFF5722); // Deep Orange
      case 'vacina':
      case 'vacinação':
        return const Color(0xFF00BCD4); // Cyan
      case 'cirurgia':
        return const Color(0xFFE53935); // Red
      case 'exame':
      case 'exames':
        return const Color(0xFF673AB7); // Deep Purple
      case 'emergência':
      case 'urgência':
        return const Color(0xFFD32F2F); // Dark Red
      case 'petshop':
        return const Color(0xFF8BC34A); // Light Green
      case 'outros':
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  static String formatValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static String formatValorAbreviado(double valor) {
    if (valor >= 1000000) {
      return 'R\$ ${(valor / 1000000).toStringAsFixed(1).replaceAll('.', ',')}M';
    } else if (valor >= 1000) {
      return 'R\$ ${(valor / 1000).toStringAsFixed(1).replaceAll('.', ',')}K';
    } else {
      return formatValor(valor);
    }
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String capitalizeText(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  static String escapeForCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  static Widget buildTipoBadge(String tipo) {
    final color = getTipoColor(tipo);
    final icon = getTipoIcon(tipo);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            tipo,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildValorChip(double valor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        formatValor(valor),
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  static Map<String, dynamic> exportDisplayData({
    required String animalId,
    required DateTime data,
    required String tipo,
    required double valor,
    required String descricao,
    String? observacao,
  }) {
    return {
      'animalId': animalId,
      'data': data.toIso8601String(),
      'tipo': tipo,
      'valor': valor,
      'descricao': descricao,
      'observacao': observacao,
      'dataFormatada': DespesasDateUtils.formatData(data),
      'tipoIcon': getTipoIcon(tipo),
      'valorFormatado': formatValor(valor),
      'tempoRelativo': DespesasDateUtils.getRelativeTime(data),
    };
  }

  static Color getValorColor(double valor) {
    if (valor <= 50) {
      return Colors.green;
    } else if (valor <= 200) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  static IconData getValorIcon(double valor) {
    if (valor <= 50) {
      return Icons.attach_money;
    } else if (valor <= 200) {
      return Icons.money_off;
    } else {
      return Icons.warning;
    }
  }
}
