// Flutter imports:
import 'package:flutter/material.dart';

enum BoxType {
  animais('box_vet_animais', 'Animais', Icons.pets),
  consultas('box_vet_consultas', 'Consultas', Icons.medical_services),
  despesas('box_vet_despesas', 'Despesas', Icons.receipt_long),
  lembretes('box_vet_lembrete', 'Lembretes', Icons.notifications),
  medicamentos('box_vet_medicamentos', 'Medicamentos', Icons.medication),
  pesos('box_vet_pesos', 'Pesos', Icons.monitor_weight),
  vacinas('box_vet_vacinas', 'Vacinas', Icons.vaccines);

  final String key;
  final String displayName;
  final IconData icon;
  
  const BoxType(this.key, this.displayName, this.icon);

  static BoxType? fromKey(String key) {
    for (BoxType boxType in BoxType.values) {
      if (boxType.key == key) {
        return boxType;
      }
    }
    return null;
  }

  static List<BoxType> get availableBoxes => BoxType.values;

  String get description {
    switch (this) {
      case BoxType.animais:
        return 'Dados dos animais cadastrados';
      case BoxType.consultas:
        return 'Histórico de consultas veterinárias';
      case BoxType.despesas:
        return 'Controle de gastos com pets';
      case BoxType.lembretes:
        return 'Lembretes e notificações';
      case BoxType.medicamentos:
        return 'Medicamentos administrados';
      case BoxType.pesos:
        return 'Histórico de peso dos animais';
      case BoxType.vacinas:
        return 'Controle de vacinação';
    }
  }
}

class BoxInfo {
  final BoxType type;
  final int recordCount;
  final DateTime? lastModified;
  final List<String> fields;

  const BoxInfo({
    required this.type,
    required this.recordCount,
    this.lastModified,
    required this.fields,
  });

  bool get isEmpty => recordCount == 0;
  bool get hasData => recordCount > 0;

  String get recordCountText {
    if (recordCount == 0) return 'Nenhum registro';
    if (recordCount == 1) return '1 registro';
    return '$recordCount registros';
  }
}
