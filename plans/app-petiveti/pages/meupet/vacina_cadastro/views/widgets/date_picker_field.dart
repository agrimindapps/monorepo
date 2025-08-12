// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/common_date_utils.dart' as vaccine_date_utils;
import '../styles/form_colors.dart';
import '../styles/form_constants.dart';
import '../styles/form_styles.dart';

/// Date picker field widget for vaccine dates
class DatePickerField extends StatefulWidget {
  final String label;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final FocusNode? focusNode;
  final ValueChanged<DateTime>? onDateSelected;
  final String? Function(DateTime?)? validator;
  final bool enabled;
  final String? helpText;

  const DatePickerField({
    super.key,
    required this.label,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.focusNode,
    this.onDateSelected,
    this.validator,
    this.enabled = true,
    this.helpText,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  DateTime? _selectedDate;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _controller = TextEditingController(
      text: _selectedDate != null
          ? vaccine_date_utils.CommonDateUtils.formatDateTime(_selectedDate!)
          : '',
    );
  }

  @override
  void didUpdateWidget(DatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      setState(() {
        _selectedDate = widget.initialDate;
        _controller.text = _selectedDate != null
            ? vaccine_date_utils.CommonDateUtils.formatDateTime(_selectedDate!)
            : '';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          readOnly: true,
          decoration: FormStyles.getFieldDecoration(
            labelText: widget.label,
            hintText: 'Selecione uma data',
            suffixIcon: Icon(
              Icons.calendar_today,
              color: widget.enabled
                  ? FormColors.iconPrimary
                  : FormColors.iconSecondary,
              size: FormConstants.iconSizeMedium,
            ),
            enabled: widget.enabled,
          ),
          style: FormStyles.fieldTextStyle,
          onTap: widget.enabled ? _showDatePicker : null,
          validator: (value) {
            if (widget.validator != null) {
              return widget.validator!(_selectedDate);
            }
            return null;
          },
        ),

        // Help text
        if (widget.helpText != null && widget.enabled)
          Padding(
            padding: const EdgeInsets.only(
              top: FormConstants.spacingXSmall,
              left: FormConstants.spacingMedium,
            ),
            child: Text(
              widget.helpText!,
              style: FormStyles.hintStyle.copyWith(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showDatePicker() async {
    final now = DateTime.now();
    final firstDate = widget.firstDate ?? DateTime(1900);
    final lastDate = widget.lastDate ?? DateTime(now.year + 10);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: FormColors.datePickerPrimary,
                ),
            // dialogTheme: FormStyles.getDialogTheme(),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && selectedDate != _selectedDate) {
      setState(() {
        _selectedDate = selectedDate;
        _controller.text =
            vaccine_date_utils.CommonDateUtils.formatDateTime(selectedDate);
      });

      widget.onDateSelected?.call(selectedDate);
    }
  }
}
