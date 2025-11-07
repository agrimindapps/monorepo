import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../tokens/list_item_design_tokens.dart';

/// Estilos de exibição de data disponíveis
enum DateDisplayStyle {
  /// Formato compacto: DD MMM
  compact,
  /// Formato padrão: DD/MM
  standard,
  /// Formato completo: DD MMM YYYY
  full,
}

/// Widget padronizado para exibição de datas em list items
/// 
/// Segue o padrão estabelecido pelo componente de odômetro,
/// garantindo consistência visual em todos os tipos de list items.
class DateDisplayWidget extends StatelessWidget {

  const DateDisplayWidget({
    super.key,
    required this.date,
    this.style = DateDisplayStyle.compact,
    this.showRelativeTime = false,
    this.textColor,
    this.textAlign = TextAlign.center,
  });
  
  /// Factory para criar data no estilo do odômetro (padrão atual)
  factory DateDisplayWidget.odometer(DateTime date) {
    return DateDisplayWidget(
      date: date,
      style: DateDisplayStyle.compact,
      showRelativeTime: false,
    );
  }
  
  /// Factory para criar data com tempo relativo
  factory DateDisplayWidget.withRelativeTime(DateTime date) {
    return DateDisplayWidget(
      date: date,
      style: DateDisplayStyle.compact,
      showRelativeTime: true,
    );
  }
  
  /// Factory para criar data em formato padrão brasileiro
  factory DateDisplayWidget.standard(DateTime date) {
    return DateDisplayWidget(
      date: date,
      style: DateDisplayStyle.standard,
      showRelativeTime: false,
    );
  }
  /// Data a ser exibida
  final DateTime date;
  
  /// Estilo de exibição da data
  final DateDisplayStyle style;
  
  /// Se deve mostrar tempo relativo (ex: "há 3 dias")
  final bool showRelativeTime;
  
  /// Cor customizada para o texto
  final Color? textColor;
  
  /// Alinhamento do texto
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ListItemDesignTokens.dateColumnWidth,
      child: Padding(
        padding: ListItemDesignTokens.dateColumnPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: _getCrossAxisAlignment(),
          children: [
            _buildPrimaryDate(context),
            if (showRelativeTime && _shouldShowRelativeTime()) ...[
              const SizedBox(height: 2),
              _buildRelativeTime(context),
            ],
          ],
        ),
      ),
    );
  }
  
  CrossAxisAlignment _getCrossAxisAlignment() {
    switch (textAlign) {
      case TextAlign.start:
      case TextAlign.left:
        return CrossAxisAlignment.start;
      case TextAlign.end:
      case TextAlign.right:
        return CrossAxisAlignment.end;
      case TextAlign.center:
      default:
        return CrossAxisAlignment.center;
    }
  }

  Widget _buildPrimaryDate(BuildContext context) {
    final formattedDate = _formatDate();
    
    return Text(
      formattedDate,
      style: ListItemDesignTokens.dateTextStyle.copyWith(
        color: textColor ?? ListItemDesignTokens.dateTextStyle.color,
      ),
      textAlign: textAlign,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRelativeTime(BuildContext context) {
    final relativeTime = _getRelativeTime();
    
    return Text(
      relativeTime,
      style: ListItemDesignTokens.monthTextStyle.copyWith(
        color: textColor?.withValues(alpha: 0.7) ?? 
               ListItemDesignTokens.monthTextStyle.color,
      ),
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _formatDate() {
    switch (style) {
      case DateDisplayStyle.compact:
        return _formatCompact();
      case DateDisplayStyle.standard:
        return _formatStandard();
      case DateDisplayStyle.full:
        return _formatFull();
    }
  }
  
  String _formatCompact() {
    final formatter = DateFormat('dd\nMMM', 'pt_BR');
    return formatter.format(date);
  }
  
  String _formatStandard() {
    final formatter = DateFormat('dd/MM', 'pt_BR');
    return formatter.format(date);
  }
  
  String _formatFull() {
    final formatter = DateFormat('dd MMM\nyyyy', 'pt_BR');
    return formatter.format(date);
  }

  bool _shouldShowRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(date);
    return difference.inDays <= 30; // Mostra tempo relativo apenas para últimos 30 dias
  }

  String _getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'agora';
      } else if (difference.inHours == 1) {
        return 'há 1h';
      } else {
        return 'há ${difference.inHours}h';
      }
    } else if (difference.inDays == 1) {
      return 'ontem';
    } else if (difference.inDays <= 7) {
      return 'há ${difference.inDays}d';
    } else if (difference.inDays <= 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'há 1 sem' : 'há $weeks sem';
    } else {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'há 1 mês' : 'há $months meses';
    }
  }
}
