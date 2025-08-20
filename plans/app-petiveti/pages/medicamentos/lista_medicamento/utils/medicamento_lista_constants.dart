// Flutter imports:
import 'package:flutter/material.dart';

class MedicamentoListaConstants {
  static const List<String> tiposFiltro = [
    'Todos',
    'Antibiótico',
    'Analgésico',
    'Anti-inflamatório',
    'Antiparasitário',
    'Vermífugo',
    'Suplemento',
    'Corticoide'
  ];

  static const Map<String, Color> tiposCores = {
    'Antibiótico': Colors.blue,
    'Analgésico': Colors.orange,
    'Anti-inflamatório': Colors.red,
    'Antiparasitário': Colors.green,
    'Vermífugo': Colors.purple,
    'Suplemento': Colors.amber,
    'Corticoide': Colors.teal,
  };

  static const Map<String, IconData> tiposIcones = {
    'Antibiótico': Icons.coronavirus,
    'Analgésico': Icons.healing,
    'Anti-inflamatório': Icons.local_fire_department,
    'Antiparasitário': Icons.bug_report,
    'Vermífugo': Icons.pest_control,
    'Suplemento': Icons.fitness_center,
    'Corticoide': Icons.shield,
  };

  static const Color corPadrao = Colors.grey;
  static const IconData iconePadrao = Icons.medication;

  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 0.85;
  static const double gridCrossAxisSpacing = 12;
  static const double gridMainAxisSpacing = 12;

  static const Duration animationDuration = Duration(milliseconds: 300);
}
