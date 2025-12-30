import 'package:core/core.dart' hide Column, FormState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/dialogs/pet_form_dialog.dart';
import '../../../../shared/widgets/form_components/form_components.dart';
import '../../../../shared/widgets/sections/form_section_widget.dart';
import '../../domain/entities/expense.dart';
import '../providers/expenses_provider.dart';

class AddExpenseDialog extends ConsumerStatefulWidget {
  final Expense? expense;
  final String? initialAnimalId;
  final ExpenseCategory? initialCategory;

  const AddExpenseDialog({
    super.key,
    this.expense,
    this.initialAnimalId,
    this.initialCategory,
  });

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _receiptNumberController = TextEditingController();

  ExpenseCategory? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String? _selectedAnimalId;
  bool _isRecurring = false;
  RecurrenceType _recurrenceType = RecurrenceType.monthly;
  bool _hasReceipt = false;
  bool _isPaid = true;
  bool _isSubmitting = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.expense != null) {
      final expense = widget.expense!;
      _descriptionController.text = expense.description;
      _amountController.text = expense.amount.toStringAsFixed(2);
      _notesController.text = expense.notes ?? '';
      _veterinarianController.text = expense.veterinarian ?? '';
      _receiptNumberController.text = expense.receiptNumber ?? '';
      _selectedCategory = expense.category;
      _selectedDate = expense.expenseDate;
      _selectedAnimalId = expense.animalId;
      _hasReceipt = expense.receiptNumber != null;
      _isPaid = expense.isPaid;
    } else {
      _selectedCategory = widget.initialCategory;
      _selectedAnimalId = widget.initialAnimalId;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _veterinarianController.dispose();
    _receiptNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PetFormDialog(
      title: 'Despesas',
      subtitle: 'Registre os gastos com seu pet',
      headerIcon: Icons.attach_money,
      isLoading: _isSubmitting,
      confirmButtonText: _isEditing ? 'Salvar' : 'Cadastrar',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: null,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormTitle(),
            const SizedBox(height: 16),
            _buildCategorySection(),
            _buildBasicInfoSection(),
            _buildAmountSection(),
            _buildDateSection(),
            _buildReceiptSection(),
            _buildRecurrenceSection(),
            _buildNotesSection(),
            _buildSubmitSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTitle() {
    return Center(
      child: Text(
        _isEditing ? 'Editar Despesa' : 'Nova Despesa',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return FormSectionWidget(
      title: 'Categoria',
      icon: Icons.category,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ExpenseCategory.values.map((category) {
            final isSelected = category == _selectedCategory;
            return FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : _getCategoryColor(category),
                  ),
                  const SizedBox(width: 6),
                  Text(_getCategoryName(category)),
                ],
              ),
              onSelected: (selected) {
                setState(() => _selectedCategory = selected ? category : null);
              },
            );
          }).toList(),
        ),
        if (_selectedCategory == null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red[600], size: 16),
                const SizedBox(width: 8),
                Text(
                  'Selecione uma categoria',
                  style: TextStyle(color: Colors.red[600], fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return FormSectionWidget(
      title: 'Informações Básicas',
      icon: Icons.info_outline,
      children: [
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Descrição *',
            hintText: 'Ex: Consulta veterinária, vacina antirrábica...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Descrição é obrigatória';
            }
            if (value.length < 3) {
              return 'Descrição deve ter pelo menos 3 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _veterinarianController,
          decoration: InputDecoration(
            labelText: 'Veterinário/Local',
            hintText: 'Nome do veterinário ou clínica',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return FormSectionWidget(
      title: 'Valor',
      icon: Icons.attach_money,
      children: [
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            labelText: 'Valor *',
            hintText: '0,00',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixText: 'R\$',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Valor é obrigatório';
            final amount = double.tryParse(value.replaceAll(',', '.'));
            if (amount == null || amount <= 0) {
              return 'Digite um valor válido maior que zero';
            }
            if (amount > 999999.99) return 'Valor muito alto';
            return null;
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Despesa Paga'),
          subtitle: Text(_isPaid ? 'Pago' : 'Pendente'),
          value: _isPaid,
          onChanged: (value) => setState(() => _isPaid = value),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return FormSectionWidget(
      title: 'Data',
      icon: Icons.calendar_today,
      children: [
        DateTimePickerField.date(
          value: _selectedDate,
          label: 'Data da Despesa',
          onChanged: (date) {
            if (date != null) setState(() => _selectedDate = date);
          },
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        ),
      ],
    );
  }

  Widget _buildReceiptSection() {
    return FormSectionWidget(
      title: 'Recibo/Nota',
      icon: Icons.receipt,
      children: [
        SwitchListTile(
          title: const Text('Possui recibo'),
          subtitle: const Text('Possui comprovante da despesa'),
          value: _hasReceipt,
          onChanged: (value) => setState(() => _hasReceipt = value),
        ),
        if (_hasReceipt) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _receiptNumberController,
            decoration: InputDecoration(
              labelText: 'Número do Recibo',
              hintText: 'Ex: 12345, NF-001...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecurrenceSection() {
    return FormSectionWidget(
      title: 'Recorrência',
      icon: Icons.repeat,
      children: [
        SwitchListTile(
          title: const Text('Despesa Recorrente'),
          subtitle: const Text('Repetir esta despesa automaticamente'),
          value: _isRecurring,
          onChanged: (value) => setState(() => _isRecurring = value),
        ),
        if (_isRecurring) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<RecurrenceType>(
            initialValue: _recurrenceType,
            decoration: InputDecoration(
              labelText: 'Frequência',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: RecurrenceType.values
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(_getRecurrenceTypeName(type)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _recurrenceType = value);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildNotesSection() {
    return FormSectionWidget(
      title: 'Observações',
      icon: Icons.notes,
      children: [
        PetiVetiFormComponents.notesGeneral(
          controller: _notesController,
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildSubmitSection() {
    return _isEditing
        ? PetiVetiFormComponents.submitUpdate(
            onSubmit: _submitForm,
            onCancel: () => Navigator.of(context).pop(),
            isLoading: _isSubmitting,
          )
        : PetiVetiFormComponents.submitCreate(
            onSubmit: _submitForm,
            onCancel: () => Navigator.of(context).pop(),
            isLoading: _isSubmitting,
            itemName: 'Despesa',
          );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma categoria'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));

      final expense = Expense(
        id: widget.expense?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        animalId: _selectedAnimalId ?? 'default_animal',
        userId: widget.expense?.userId ?? 'temp_user_id',
        title: _descriptionController.text.trim(),
        category: _selectedCategory!,
        paymentMethod: PaymentMethod.cash,
        description: _descriptionController.text.trim(),
        amount: amount,
        expenseDate: _selectedDate,
        veterinarian: _veterinarianController.text.trim().isEmpty
            ? null
            : _veterinarianController.text.trim(),
        receiptNumber:
            _hasReceipt && _receiptNumberController.text.trim().isNotEmpty
                ? _receiptNumberController.text.trim()
                : null,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isPaid: _isPaid,
        isRecurring: _isRecurring,
        recurrenceType: _isRecurring ? _recurrenceType : null,
        createdAt: widget.expense?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
      );

      if (widget.expense == null) {
        await ref.read(expensesProvider.notifier).addExpense(expense);
      } else {
        await ref.read(expensesProvider.notifier).updateExpense(expense);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.expense == null
                  ? 'Despesa adicionada com sucesso!'
                  : 'Despesa atualizada com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar despesa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    const categoryColors = {
      ExpenseCategory.consultation: Colors.blue,
      ExpenseCategory.medication: Colors.green,
      ExpenseCategory.vaccine: Colors.purple,
      ExpenseCategory.surgery: Colors.red,
      ExpenseCategory.exam: Colors.orange,
      ExpenseCategory.food: Colors.brown,
      ExpenseCategory.accessory: Colors.pink,
      ExpenseCategory.grooming: Colors.cyan,
      ExpenseCategory.insurance: Colors.indigo,
      ExpenseCategory.emergency: Colors.deepOrange,
      ExpenseCategory.other: Colors.grey,
    };
    return categoryColors[category] ?? Colors.grey;
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    const categoryIcons = {
      ExpenseCategory.consultation: Icons.medical_services,
      ExpenseCategory.medication: Icons.medication,
      ExpenseCategory.vaccine: Icons.vaccines,
      ExpenseCategory.surgery: Icons.healing,
      ExpenseCategory.exam: Icons.biotech,
      ExpenseCategory.food: Icons.pets,
      ExpenseCategory.accessory: Icons.shopping_bag,
      ExpenseCategory.grooming: Icons.content_cut,
      ExpenseCategory.insurance: Icons.shield,
      ExpenseCategory.emergency: Icons.emergency,
      ExpenseCategory.other: Icons.more_horiz,
    };
    return categoryIcons[category] ?? Icons.more_horiz;
  }

  String _getCategoryName(ExpenseCategory category) {
    const categoryNames = {
      ExpenseCategory.consultation: 'Consultas',
      ExpenseCategory.medication: 'Medicamentos',
      ExpenseCategory.vaccine: 'Vacinas',
      ExpenseCategory.surgery: 'Cirurgias',
      ExpenseCategory.exam: 'Exames',
      ExpenseCategory.food: 'Ração',
      ExpenseCategory.accessory: 'Acessórios',
      ExpenseCategory.grooming: 'Banho/Tosa',
      ExpenseCategory.insurance: 'Seguro',
      ExpenseCategory.emergency: 'Emergência',
      ExpenseCategory.other: 'Outros',
    };
    return categoryNames[category] ?? 'Outros';
  }

  String _getRecurrenceTypeName(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.weekly:
        return 'Semanal';
      case RecurrenceType.monthly:
        return 'Mensal';
      case RecurrenceType.yearly:
        return 'Anual';
    }
  }
}
