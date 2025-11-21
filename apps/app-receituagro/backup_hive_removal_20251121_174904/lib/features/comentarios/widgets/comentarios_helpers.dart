import 'package:flutter/material.dart';

/// Helpers para ComentariosPage
///
/// Responsabilidades:
/// - Ícones por origem
/// - Formatação de datas relativas
class ComentariosHelpers {
  ComentariosHelpers._();

  /// Retorna ícone baseado na origem/ferramenta
  static IconData getOriginIcon(String origem) {
    switch (origem.toLowerCase()) {
      case 'defensivos':
        return Icons.shield_outlined;
      case 'pragas':
        return Icons.bug_report_outlined;
      case 'diagnóstico':
        return Icons.medical_services_outlined;
      case 'comentários':
      case 'comentário direto':
        return Icons.comment_outlined;
      default:
        return Icons.note_outlined;
    }
  }

  /// Formata data como tempo relativo (ex: "5h atrás")
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'Agora';
    }
  }
}
