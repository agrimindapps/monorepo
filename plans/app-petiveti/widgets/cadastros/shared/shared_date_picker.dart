// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../constants/form_constants.dart';
import '../constants/form_styles.dart';

/// Configuração de data para o picker
class DatePickerConfig {
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String helpText;
  final String fieldLabelText;
  final bool allowFuture;
  final bool allowPast;
  final int yearsBack;
  final int yearsForward;

  const DatePickerConfig({
    this.firstDate,
    this.lastDate,
    this.helpText = 'Selecionar data',
    this.fieldLabelText = 'Digite a data',
    this.allowFuture = true,
    this.allowPast = true,
    this.yearsBack = 2,
    this.yearsForward = 1,
  });

  /// Config para consulta veterinária
  static const DatePickerConfig consulta = DatePickerConfig(
    helpText: 'Selecionar data da consulta',
    yearsBack: 2,
    yearsForward: 1,
  );

  /// Config para despesa
  static const DatePickerConfig despesa = DatePickerConfig(
    helpText: 'Selecionar data da despesa',
    yearsBack: 1,
    yearsForward: 1,
  );

  /// Config para lembrete
  static const DatePickerConfig lembrete = DatePickerConfig(
    helpText: 'Selecionar data do lembrete',
    yearsBack: 0,
    yearsForward: 2,
    allowPast: false,
  );

  /// Config para medicamento
  static const DatePickerConfig medicamento = DatePickerConfig(
    helpText: 'Selecionar data do medicamento',
    yearsBack: 1,
    yearsForward: 2,
  );

  /// Config para peso
  static const DatePickerConfig peso = DatePickerConfig(
    helpText: 'Selecionar data da pesagem',
    yearsBack: 5,
    yearsForward: 0,
    allowFuture: false,
  );

  /// Config para vacina
  static const DatePickerConfig vacina = DatePickerConfig(
    helpText: 'Selecionar data da vacina',
    yearsBack: 2,
    yearsForward: 1,
  );
}

/// Widget de seleção de data unificado para todos os formulários de cadastro
class SharedDatePicker extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final String? errorText;
  final bool isRequired;
  final bool showDateInfo;
  final DatePickerConfig config;
  final EdgeInsets? padding;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;

  const SharedDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateChanged,
    this.errorText,
    this.isRequired = false,
    this.showDateInfo = true,
    this.config = const DatePickerConfig(),
    this.padding,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
  });

  /// Factory para consulta
  factory SharedDatePicker.consulta({
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateChanged,
    String? errorText,
    bool isRequired = true,
    bool showDateInfo = true,
  }) {
    return SharedDatePicker(
      label: 'Data da Consulta',
      selectedDate: selectedDate,
      onDateChanged: onDateChanged,
      errorText: errorText,
      isRequired: isRequired,
      showDateInfo: showDateInfo,
      config: DatePickerConfig.consulta,
      prefixIcon: const Icon(Icons.event),
    );
  }

  /// Factory para despesa
  factory SharedDatePicker.despesa({
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateChanged,
    String? errorText,
    bool isRequired = true,
    bool showDateInfo = true,
  }) {
    return SharedDatePicker(
      label: 'Data da Despesa',
      selectedDate: selectedDate,
      onDateChanged: onDateChanged,
      errorText: errorText,
      isRequired: isRequired,
      showDateInfo: showDateInfo,
      config: DatePickerConfig.despesa,
      prefixIcon: const Icon(Icons.payment),
    );
  }

  /// Factory para lembrete
  factory SharedDatePicker.lembrete({
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateChanged,
    String? errorText,
    bool isRequired = true,
    bool showDateInfo = true,
  }) {
    return SharedDatePicker(
      label: 'Data do Lembrete',
      selectedDate: selectedDate,
      onDateChanged: onDateChanged,
      errorText: errorText,
      isRequired: isRequired,
      showDateInfo: showDateInfo,
      config: DatePickerConfig.lembrete,
      prefixIcon: const Icon(Icons.notification_important),
    );
  }

  /// Factory para medicamento
  factory SharedDatePicker.medicamento({
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateChanged,
    String? errorText,
    bool isRequired = true,
    bool showDateInfo = true,
  }) {
    return SharedDatePicker(
      label: 'Data do Medicamento',
      selectedDate: selectedDate,
      onDateChanged: onDateChanged,
      errorText: errorText,
      isRequired: isRequired,
      showDateInfo: showDateInfo,
      config: DatePickerConfig.medicamento,
      prefixIcon: const Icon(Icons.medication),
    );
  }

  /// Factory para peso
  factory SharedDatePicker.peso({
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateChanged,
    String? errorText,
    bool isRequired = true,
    bool showDateInfo = true,
  }) {
    return SharedDatePicker(
      label: 'Data da Pesagem',
      selectedDate: selectedDate,
      onDateChanged: onDateChanged,
      errorText: errorText,
      isRequired: isRequired,
      showDateInfo: showDateInfo,
      config: DatePickerConfig.peso,
      prefixIcon: const Icon(Icons.monitor_weight),
    );
  }

  /// Factory para vacina
  factory SharedDatePicker.vacina({
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateChanged,
    String? errorText,
    bool isRequired = true,
    bool showDateInfo = true,
  }) {
    return SharedDatePicker(
      label: 'Data da Vacina',
      selectedDate: selectedDate,
      onDateChanged: onDateChanged,
      errorText: errorText,
      isRequired: isRequired,
      showDateInfo: showDateInfo,
      config: DatePickerConfig.vacina,
      prefixIcon: const Icon(Icons.vaccines),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(),
          const SizedBox(height: FormStyles.smallSpacing),
          _buildDateField(context),
          if (errorText != null) ...[
            const SizedBox(height: FormStyles.smallSpacing),
            _buildErrorText(),
          ],
          if (showDateInfo) ...[
            const SizedBox(height: FormStyles.smallSpacing),
            _buildDateInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return Text(
      isRequired ? '$label *' : label,
      style: FormStyles.subtitleTextStyle.copyWith(
        fontSize: FormStyles.bodyFontSize,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    final hasError = errorText != null;
    
    return GestureDetector(
      onTap: enabled ? () => _selectDate(context) : null,
      child: Container(
        height: FormStyles.inputHeight,
        decoration: BoxDecoration(
          border: Border.all(
            color: hasError ? FormStyles.errorColor : FormStyles.borderColor,
            width: FormStyles.borderWidth,
          ),
          borderRadius: BorderRadius.circular(FormStyles.borderRadius),
          color: enabled ? FormStyles.surfaceColor : FormStyles.backgroundColor,
        ),
        child: InputDecorator(
          decoration: FormStyles.getInputDecoration(
            labelText: hintText ?? FormConstants.selectDatePlaceholder,
            errorText: null, // Handled separately
            enabled: enabled,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon ?? const Icon(Icons.calendar_month),
          ).copyWith(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          child: Text(
            _formatDate(selectedDate),
            style: FormStyles.bodyTextStyle.copyWith(
              color: enabled ? Colors.black87 : FormStyles.disabledColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorText() {
    return Text(
      errorText!,
      style: FormStyles.errorTextStyle,
    );
  }

  Widget _buildDateInfo() {
    final info = _getDateInfo(selectedDate);
    if (info == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FormStyles.smallSpacing + 4,
        vertical: FormStyles.tinySpacing + 2,
      ),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(FormStyles.tinySpacing + 2),
        border: Border.all(
          color: info.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            info.icon,
            size: 16,
            color: info.color,
          ),
          const SizedBox(width: FormStyles.tinySpacing + 2),
          Text(
            info.text,
            style: TextStyle(
              color: info.color,
              fontWeight: FontWeight.w500,
              fontSize: FormStyles.captionFontSize,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = config.firstDate ?? 
        (config.allowPast ? now.subtract(Duration(days: 365 * config.yearsBack)) : now);
    final lastDate = config.lastDate ?? 
        (config.allowFuture ? now.add(Duration(days: 365 * config.yearsForward)) : now);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: this.selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('pt', 'BR'),
      helpText: config.helpText,
      cancelText: FormConstants.cancelLabel,
      confirmText: FormConstants.confirmLabel,
      fieldLabelText: config.fieldLabelText,
      fieldHintText: FormConstants.dateFormat.toLowerCase(),
      errorFormatText: 'Formato inválido',
      errorInvalidText: 'Data inválida',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: FormStyles.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      onDateChanged(selectedDate);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }

  _DateInfo? _getDateInfo(DateTime date) {
    final now = DateTime.now();
    
    if (_isToday(date)) {
      return const _DateInfo(
        text: 'Hoje',
        color: FormStyles.successColor,
        icon: Icons.today,
      );
    } else if (_isThisWeek(date)) {
      return _DateInfo(
        text: _getDiaSemana(date.weekday),
        color: FormStyles.primaryColor,
        icon: Icons.date_range,
      );
    } else if (_isThisMonth(date)) {
      final daysDiff = date.difference(now).inDays.abs();
      final text = daysDiff == 1
          ? (date.isBefore(now) ? 'Ontem' : 'Amanhã')
          : '$daysDiff dias ${date.isBefore(now) ? 'atrás' : 'à frente'}';
      return _DateInfo(
        text: text,
        color: FormStyles.primaryColor.withValues(alpha: 0.7),
        icon: Icons.calendar_month,
      );
    } else if (_isThisYear(date)) {
      return _DateInfo(
        text: '${_getMes(date.month)} de ${date.year}',
        color: FormStyles.disabledColor,
        icon: Icons.calendar_today,
      );
    } else {
      final yearsDiff = date.year - now.year;
      final text = yearsDiff.abs() == 1
          ? (yearsDiff < 0 ? 'Ano passado' : 'Próximo ano')
          : '${yearsDiff.abs()} anos ${yearsDiff < 0 ? 'atrás' : 'à frente'}';
      return _DateInfo(
        text: text,
        color: FormStyles.warningColor,
        icon: Icons.history,
      );
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  bool _isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  bool _isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  String _getDiaSemana(int weekday) {
    const diasSemana = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo'
    ];
    
    if (weekday >= 1 && weekday <= 7) {
      return diasSemana[weekday - 1];
    }
    return 'Dia inválido';
  }

  String _getMes(int month) {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    
    if (month >= 1 && month <= 12) {
      return meses[month - 1];
    }
    return 'Mês inválido';
  }
}

/// Classe helper para informações de data
class _DateInfo {
  final String text;
  final Color color;
  final IconData icon;

  const _DateInfo({
    required this.text,
    required this.color,
    required this.icon,
  });
}
