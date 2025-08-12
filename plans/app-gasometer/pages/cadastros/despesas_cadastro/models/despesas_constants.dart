// Flutter imports:
import 'package:flutter/material.dart';

class DespesaConstants {
  static const List<String> tiposDespesa = [
    'Seguro',
    'IPVA',
    'Estacionamento',
    'Lavagem',
    'Multa',
    'Pedágio',
    'Licenciamento',
    'Acessórios',
    'Documentação',
    'Outro'
  ];

  static const Map<String, IconData> tiposIcons = {
    'Seguro': Icons.security,
    'IPVA': Icons.description,
    'Estacionamento': Icons.local_parking,
    'Lavagem': Icons.local_car_wash,
    'Multa': Icons.report_problem,
    'Pedágio': Icons.toll,
    'Licenciamento': Icons.assignment,
    'Acessórios': Icons.shopping_bag,
    'Documentação': Icons.folder,
    'Outro': Icons.attach_money,
  };

  static const Map<String, String> validationMessages = {
    'campoObrigatorio': 'Campo obrigatório',
    'valorInvalido': 'Valor inválido',
    'valorMaiorQueZero': 'O valor deve ser maior que zero',
  };

  static const Map<String, String> sectionTitles = {
    'informacoesBasicas': 'Informações Básicas',
    'despesa': 'Despesa',
    'descricao': 'Descrição',
  };

  static const Map<String, IconData> sectionIcons = {
    'informacoesBasicas': Icons.event_note,
    'despesa': Icons.attach_money,
    'descricao': Icons.description,
  };
}
