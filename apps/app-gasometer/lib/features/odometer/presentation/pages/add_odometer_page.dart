import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/form_section_widget.dart';

class AddOdometerPage extends StatefulWidget {
  final Map<String, dynamic>? odometer;

  const AddOdometerPage({super.key, this.odometer});

  @override
  State<AddOdometerPage> createState() => _AddOdometerPageState();
}

class _AddOdometerPageState extends State<AddOdometerPage> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.odometer != null) {
      _populateFields();
    }
    
    // Add listener para atualizar contador de caracteres
    _descriptionController.addListener(_updateUI);
  }

  void _populateFields() {
    final odometer = widget.odometer!;
    _odometerController.text = odometer['odometer']?.toString() ?? '';
    _descriptionController.text = odometer['description'] ?? '';
    
    if (odometer['date'] != null) {
      _selectedDate = odometer['date'] as DateTime;
      _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
    }
  }

  void _updateUI() {
    setState(() {});
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_updateUI);
    _odometerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.odometer != null;
    
    return FormDialog(
      title: 'Odômetro',
      subtitle: 'Gerencie seus registros de quilometr...',
      headerIcon: Icons.speed,
      isLoading: _isLoading,
      confirmButtonText: 'Salvar',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: _submitForm,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormTitle(isEditing),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildAdditionalInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTitle(bool isEditing) {
    return Center(
      child: Text(
        'Cadastrar Odômetro',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return FormSectionWidget(
      title: 'Informações Básicas',
      icon: Icons.event_note,
      children: [
        _buildTextField(
          controller: _odometerController,
          label: 'Odômetro',
          hint: '',
          textAlign: TextAlign.start,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: _getOdometroFormatters(),
          validator: _validateOdometro,
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 12),
        _buildDateTimeField(),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return FormSectionWidget(
      title: 'Adicionais',
      icon: Icons.more_horiz,
      children: [
        _buildTextField(
          controller: _descriptionController,
          label: 'Descrição',
          hint: '',
          maxLines: 3,
          maxLength: 255,
          showCounter: true,
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    int? maxLength,
    int? maxLines,
    String? suffixText,
    String? Function(String?)? validator,
    bool showCounter = false,
    TextAlign? textAlign,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          maxLength: showCounter ? null : maxLength,
          maxLines: maxLines ?? 1,
          textAlign: textAlign ?? TextAlign.start,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            suffixText: suffixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            counterText: '',
            alignLabelWithHint: maxLines != null && maxLines > 1,
          ),
        ),
        if (showCounter && maxLength != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${controller.text.length}/$maxLength',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateTimeField() {
    return InkWell(
      onTap: _selectDateTime,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Data e Hora',
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                DateFormat('dd/MM/yyyy').format(_selectedDate),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              height: 20,
              width: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _selectedTime.format(context),
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Formatadores de entrada
  List<TextInputFormatter> _getOdometroFormatters() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
      TextInputFormatter.withFunction((oldValue, newValue) {
        var text = newValue.text.replaceAll('.', ',');
        if (text.contains(',')) {
          final parts = text.split(',');
          if (parts.length == 2 && parts[1].length > 2) {
            text = '${parts[0]},${parts[1].substring(0, 2)}';
          }
        }
        return TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }),
    ];
  }

  // Validadores
  String? _validateOdometro(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    final cleanValue = value.replaceAll(',', '.');
    final number = double.tryParse(cleanValue);
    
    if (number == null || number < 0) {
      return 'Valor inválido';
    }
    
    return null;
  }

  Future<void> _selectDateTime() async {
    // Select date first
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      // Then select time
      if (mounted) {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (time != null) {
          setState(() {
            _selectedDate = date;
            _selectedTime = time;
          });
        }
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if date is not in the future
    final selectedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (selectedDateTime.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('A data de registro não pode ser futura'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        final result = {
          'odometer': double.tryParse(_odometerController.text.replaceAll(',', '.')) ?? 0.0,
          'date': selectedDateTime,
          'description': _descriptionController.text,
        };
        
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar registro: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}