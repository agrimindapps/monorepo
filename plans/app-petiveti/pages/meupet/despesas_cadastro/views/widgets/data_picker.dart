// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controllers/despesa_form_controller.dart';
import '../../utils/despesa_form_utils.dart';
import '../styles/despesa_form_styles.dart';

class DataPicker extends StatelessWidget {
  final DespesaFormController controller;

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
          style: DespesaFormStyles.labelStyle,
        ),
        const SizedBox(height: 8),
        Obx(() {
          final hasError = controller.formState.value.getFieldError('dataDespesa') != null;
          final currentDate = controller.formModel.value.dataDateTime;

          return GestureDetector(
            onTap: () => _selectDate(context),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasError 
                      ? DespesaFormStyles.errorColor
                      : DespesaFormStyles.dividerColor,
                  width: DespesaFormStyles.inputBorderWidth,
                ),
                borderRadius: BorderRadius.circular(DespesaFormStyles.borderRadius),
                color: Colors.white,
              ),
              child: InputDecorator(
                decoration: DespesaFormStyles.getInputDecoration(
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
                  DespesaFormUtils.formatData(currentDate),
                  style: DespesaFormStyles.inputStyle,
                ),
              ),
            ),
          );
        }),
        
        Obx(() {
          final error = controller.formState.value.getFieldError('dataDespesa');
          if (error != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                error,
                style: DespesaFormStyles.errorStyle,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        
        const SizedBox(height: 8),
        
        Obx(() {
          final currentDate = controller.formModel.value.dataDateTime;
          return _buildDateInfo(currentDate);
        }),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final currentDate = controller.formModel.value.dataDateTime;
    final now = DateTime.now();
    final firstDate = now.subtract(const Duration(days: 365));
    final lastDate = now.add(const Duration(days: 365));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecionar data da despesa',
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
              primary: DespesaFormStyles.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: DespesaFormStyles.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      controller.updateDataDespesa(selectedDate);
    }
  }


  Widget _buildDateInfo(DateTime date) {
    final now = DateTime.now();
    String info = '';
    Color color = DespesaFormStyles.textSecondaryColor;
    IconData icon = Icons.info_outline;

    if (DespesaFormUtils.isToday(date)) {
      info = 'Hoje';
      color = DespesaFormStyles.successColor;
      icon = Icons.today;
    } else if (DespesaFormUtils.isThisWeek(date)) {
      info = DespesaFormUtils.getDiaSemana(date.weekday);
      color = DespesaFormStyles.primaryColor;
      icon = Icons.date_range;
    } else if (DespesaFormUtils.isThisMonth(date)) {
      final daysDiff = date.difference(now).inDays.abs();
      info = daysDiff == 1 
          ? (date.isBefore(now) ? 'Ontem' : 'Amanhã')
          : '$daysDiff dias ${date.isBefore(now) ? 'atrás' : 'à frente'}';
      color = DespesaFormStyles.secondaryColor;
      icon = Icons.calendar_month;
    } else if (DespesaFormUtils.isThisYear(date)) {
      info = '${DespesaFormUtils.getMes(date.month)} de ${date.year}';
      color = DespesaFormStyles.textSecondaryColor;
      icon = Icons.calendar_today;
    } else {
      final yearsDiff = date.year - now.year;
      info = yearsDiff.abs() == 1
          ? (yearsDiff < 0 ? 'Ano passado' : 'Próximo ano')
          : '${yearsDiff.abs()} anos ${yearsDiff < 0 ? 'atrás' : 'à frente'}';
      color = DespesaFormStyles.warningColor;
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
