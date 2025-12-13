import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Utilitários para formatação de datas
String formatDate(dynamic date) {
  if (date == null) return 'N/A';

  DateTime dateTime;
  if (date is DateTime) {
    dateTime = date;
  } else if (date is String) {
    dateTime = DateTime.tryParse(date) ?? DateTime.now();
  } else {
    return 'N/A';
  }

  return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
}

/// Utilitários para construção de widgets comuns
Widget buildSectionHeader(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        fontSize: (Theme.of(context).textTheme.titleSmall?.fontSize ?? 14) + 2,
      ),
    ),
  );
}

Widget buildInfoRow(BuildContext context, String label, String value) {
  final theme = Theme.of(context);
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      Text(
        value,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
