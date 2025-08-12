// Flutter imports:
import 'package:flutter/material.dart';

class ManutencaoConstants {
  static const List<String> tiposManutencao = [
    'Preventiva',
    'Corretiva',
    'Revisão'
  ];

  static const Map<String, IconData> tiposIcons = {
    'Preventiva': Icons.build_circle,
    'Corretiva': Icons.build,
    'Revisão': Icons.fact_check,
  };

  static const Map<String, String> validationMessages = {
    'campoObrigatorio': 'Campo obrigatório',
    'valorInvalido': 'Valor inválido',
    'valorMaiorQueZero': 'O valor deve ser maior que zero',
    'numeroValido': 'Digite um número válido',
  };

  static const Map<String, String> sectionTitles = {
    'informacoesBasicas': 'Informações Básicas',
    'custosData': 'Custos e Data',
    'configuracoes': 'Configurações',
  };

  static const Map<String, IconData> sectionIcons = {
    'informacoesBasicas': Icons.event_note,
    'custosData': Icons.attach_money,
    'configuracoes': Icons.settings,
  };

  static const Map<String, String> fieldLabels = {
    'tipo': 'Tipo',
    'descricao': 'Descrição',
    'valor': 'Valor',
    'dataHora': 'Data e Hora',
    'odometro': 'Odômetro',
    'proximaRevisao': 'Próxima Revisão (opcional)',
    'concluida': 'Concluída',
  };

  static const Map<String, String> fieldHints = {
    'descricao': 'Descreva a manutenção realizada',
    'valor': '0,00',
    'proximaRevisao': 'Não definida',
  };

  static const Map<String, String> buttonLabels = {
    'cancelar': 'Cancelar',
    'confirmar': 'Confirmar',
    'selecionar': 'Selecionar',
    'limpar': 'Limpar',
    'selecionarData': 'Selecione a data',
    'selecionarHora': 'Selecione a hora',
  };
}
