// Flutter imports:
import 'package:flutter/material.dart';

/// Constantes para o formulário de cadastro de consultas
/// Organiza títulos de seções, ícones, rótulos de campos e configurações
class ConsultaFormConstants {
  // === SEÇÕES DO FORMULÁRIO ===

  /// Títulos das seções do formulário
  static const Map<String, String> titulosSecoes = {
    'agendamento': 'Agendamento da Consulta',
    'informacoes_veterinarias': 'Informações Veterinárias',
    'informacoes_clinicas': 'Informações Clínicas',
    'informacoes_financeiras': 'Informações Financeiras',
  };

  /// Ícones das seções do formulário
  static const Map<String, IconData> iconesSecoes = {
    'agendamento': Icons.schedule,
    'informacoes_veterinarias': Icons.medical_services,
    'informacoes_clinicas': Icons.assignment,
    'informacoes_financeiras': Icons.attach_money,
  };

  // === RÓTULOS DOS CAMPOS ===

  /// Rótulos dos campos do formulário
  static const Map<String, String> rotulosCampos = {
    'animal': 'Animal',
    'data_consulta': 'Data da Consulta',
    'veterinario': 'Veterinário',
    'motivo': 'Motivo da Consulta',
    'diagnostico': 'Diagnóstico',
    'observacoes': 'Observações',
    'valor': 'Valor da Consulta',
  };

  /// Dicas dos campos do formulário
  static const Map<String, String> dicasCampos = {
    'animal': 'Selecione o animal',
    'data_consulta': 'dd/mm/aaaa hh:mm',
    'veterinario': 'Nome do veterinário responsável',
    'motivo': 'Selecione o motivo da consulta',
    'diagnostico': 'Diagnóstico ou resultado da consulta',
    'observacoes': 'Observações adicionais sobre a consulta...',
    'valor': 'Digite o valor cobrado',
  };

  // === VALIDAÇÃO ===

  /// Mensagens de validação
  static const Map<String, String> mensagensValidacao = {
    'animal_obrigatorio': 'Selecione um animal',
    'data_obrigatoria': 'Selecione a data da consulta',
    'veterinario_obrigatorio': 'Nome do veterinário é obrigatório',
    'veterinario_tamanho': 'Nome deve ter entre 2 e 100 caracteres',
    'motivo_obrigatorio': 'Selecione o motivo da consulta',
    'valor_invalido': 'Digite um valor válido',
    'valor_negativo': 'Valor não pode ser negativo',
    'diagnostico_tamanho': 'Diagnóstico deve ter no máximo 500 caracteres',
    'observacoes_tamanho': 'Observações devem ter no máximo 1000 caracteres',
  };

  // === CONFIGURAÇÕES DE CAMPOS ===

  /// Configurações de texto
  static const int maxVeterinarioLength = 100;
  static const int maxDiagnosticoLength = 500;
  static const int maxObservacoesLength = 1000;
  static const int maxLinhasObservacoes = 4;
  static const int maxLinhasDiagnostico = 3;

  // === ESPAÇAMENTOS ===

  /// Espaçamento entre seções
  static const double sectionSpacing = 16.0;
  
  /// Espaçamento entre campos
  static const double fieldSpacing = 12.0;

  // === OPÇÕES DE FORMULÁRIO ===

  /// Opções de motivos de consulta
  static const List<String> motivosConsulta = [
    'Consulta de rotina',
    'Vacinação',
    'Emergência',
    'Retorno',
    'Cirurgia',
    'Exames',
    'Castração',
    'Tratamento',
    'Outro',
  ];

  /// Ícones para motivos de consulta
  static const Map<String, IconData> iconesMotivos = {
    'Consulta de rotina': Icons.health_and_safety,
    'Vacinação': Icons.vaccines,
    'Emergência': Icons.emergency,
    'Retorno': Icons.refresh,
    'Cirurgia': Icons.medical_services,
    'Exames': Icons.science,
    'Castração': Icons.pets,
    'Tratamento': Icons.healing,
    'Outro': Icons.more_horiz,
  };

  // === LIMITES DE VALORES ===

  /// Valor máximo para consulta
  static const double maxValorConsulta = 9999.99;
  
  /// Valor mínimo para consulta
  static const double minValorConsulta = 0.0;

  // === CONFIGURAÇÕES DE DATA ===

  /// Data mínima para consulta (1 ano atrás)
  static DateTime get dataMinima => DateTime.now().subtract(const Duration(days: 365));
  
  /// Data máxima para consulta (1 ano à frente)
  static DateTime get dataMaxima => DateTime.now().add(const Duration(days: 365));
}
