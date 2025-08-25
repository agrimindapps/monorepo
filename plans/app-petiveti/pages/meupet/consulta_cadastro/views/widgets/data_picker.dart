// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controllers/consulta_form_controller.dart';
import '../../utils/consulta_form_utils.dart';
import '../styles/consulta_form_styles.dart';

class DataPicker extends StatelessWidget {
  final ConsultaFormController controller;

  const DataPicker({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data *',
          style: ConsultaFormStyles.labelStyle,
        ),
        const SizedBox(height: 8),
        Obx(() {
          final hasError = controller.getFieldError('dataConsulta') != null;
          final currentDate = controller.model.dataDateTime;

          return GestureDetector(
            onTap: () => _selectDate(context),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasError
                      ? ConsultaFormStyles.errorColor
                      : ConsultaFormStyles.dividerColor,
                  width: ConsultaFormStyles.inputBorderWidth,
                ),
                borderRadius:
                    BorderRadius.circular(ConsultaFormStyles.borderRadius),
                color: Colors.white,
              ),
              child: InputDecorator(
                decoration: ConsultaFormStyles.getInputDecoration(
                  labelText: 'Selecione a data',
                  hasError: hasError,
                ).copyWith(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                ),
                child: Text(
                  ConsultaFormUtils.formatDate(currentDate),
                  style: ConsultaFormStyles.inputStyle,
                ),
              ),
            ),
          );
        }),
        Obx(() {
          final error = controller.getFieldError('dataConsulta');
          if (error != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                error,
                style: ConsultaFormStyles.errorStyle,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 8),
        Obx(() {
          final currentDate = controller.model.dataDateTime;
          return _buildDateInfo(currentDate);
        }),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final currentDate = controller.model.dataDateTime;
    final now = DateTime.now();
    final twoYearsAgo = now.subtract(const Duration(days: 730));
    final oneYearFromNow = now.add(const Duration(days: 365));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: twoYearsAgo,
      lastDate: oneYearFromNow,
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecionar data da consulta',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      fieldLabelText: 'Digite a data',
      fieldHintText: 'dd/mm/aaaa',
      errorFormatText: 'Formato inválido',
      errorInvalidText: 'Data inválida',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: ConsultaFormStyles.primaryColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: ConsultaFormStyles.textPrimaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      controller.updateDataConsulta(selectedDate);
    }
  }

  Widget _buildDateInfo(DateTime date) {
    final now = DateTime.now();
    String info = '';
    Color color = ConsultaFormStyles.textSecondaryColor;
    IconData icon = Icons.info_outline;

    if (ConsultaFormUtils.isToday(date)) {
      info = 'Hoje';
      color = ConsultaFormStyles.successColor;
      icon = Icons.today;
    } else if (ConsultaFormUtils.isThisWeek(date)) {
      info = ConsultaFormUtils.getDiaSemana(date.weekday);
      color = ConsultaFormStyles.primaryColor;
      icon = Icons.date_range;
    } else if (ConsultaFormUtils.isThisMonth(date)) {
      final daysDiff = date.difference(now).inDays.abs();
      info = daysDiff == 1
          ? (date.isBefore(now) ? 'Ontem' : 'Amanhã')
          : '$daysDiff dias ${date.isBefore(now) ? 'atrás' : 'à frente'}';
      color = ConsultaFormStyles.secondaryColor;
      icon = Icons.calendar_month;
    } else if (ConsultaFormUtils.isThisYear(date)) {
      info = '${ConsultaFormUtils.getMes(date.month)} de ${date.year}';
      color = ConsultaFormStyles.textSecondaryColor;
      icon = Icons.calendar_today;
    } else {
      final yearsDiff = date.year - now.year;
      info = yearsDiff.abs() == 1
          ? (yearsDiff < 0 ? 'Ano passado' : 'Próximo ano')
          : '${yearsDiff.abs()} anos ${yearsDiff < 0 ? 'atrás' : 'à frente'}';
      color = ConsultaFormStyles.warningColor;
      icon = Icons.history;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            info,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
