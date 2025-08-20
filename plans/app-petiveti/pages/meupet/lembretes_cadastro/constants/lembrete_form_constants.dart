// Flutter imports:
import 'package:flutter/material.dart';

/// Constantes para o formulário de lembretes
class LembreteFormConstants {
  // Espaçamentos
  static const double sectionSpacing = 16.0;
  static const double fieldSpacing = 12.0;
  static const double cardPadding = 16.0;
  static const double cardElevation = 2.0;
  static const double borderRadius = 12.0;

  // Seções do formulário
  static const String basicInfoTitle = 'Informações Básicas';
  static const String schedulingTitle = 'Agendamento';
  static const String statusTitle = 'Status';

  // Ícones das seções
  static const IconData basicInfoIcon = Icons.event_note;
  static const IconData schedulingIcon = Icons.schedule;
  static const IconData statusIcon = Icons.task_alt;

  // Cores das seções
  static const Color basicInfoColor = Color(0xFF2563EB);
  static const Color schedulingColor = Color(0xFF059669);
  static const Color statusColor = Color(0xFFDC2626);

  // Textos dos campos
  static const String tituloLabel = 'Título';
  static const String tituloHint = 'Digite o título do lembrete';
  static const String descricaoLabel = 'Descrição';
  static const String descricaoHint = 'Digite uma descrição detalhada';
  static const String dataLabel = 'Data';
  static const String horaLabel = 'Hora';
  static const String tipoLabel = 'Tipo';
  static const String repetirLabel = 'Repetir';
  static const String concluidoLabel = 'Concluído';

  // Configurações de campos
  static const int tituloMaxLength = 50;
  static const int descricaoMaxLength = 200;
  static const int descricaoMaxLines = 3;
}
