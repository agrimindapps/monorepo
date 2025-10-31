import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/expense.dart';
import '../providers/expenses_provider.dart';

/// Enhanced form for adding and editing expenses with real-time validation
class ExpenseAddForm extends ConsumerStatefulWidget {
  final Expense? expense;
  final String? initialAnimalId;
  final ExpenseCategory? initialCategory;
  
  const ExpenseAddForm({
    super.key,
    this.expense,
    this.initialAnimalId,
    this.initialCategory,
  });

  @override
  ConsumerState<ExpenseAddForm> createState() => _ExpenseAddFormState();
}

class _ExpenseAddFormState extends ConsumerState<ExpenseAddForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _receiptNumberController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  ExpenseCategory? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String? _selectedAnimalId;
  bool _isRecurring = false;
  RecurrenceType _recurrenceType = RecurrenceType.monthly;
  bool _hasReceipt = false;
  bool _isPaid = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
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

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _veterinarianController.dispose();
    _receiptNumberController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Nova Despesa' : 'Editar Despesa'),
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _submitForm,
              child: Text(widget.expense == null ? 'SALVAR' : 'ATUALIZAR'),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategorySelector(theme),
                  const SizedBox(height: 20),
                  _buildBasicInfoSection(theme),
                  const SizedBox(height: 20),
                  _buildAmountSection(theme),
                  const SizedBox(height: 20),
                  _buildDateSection(theme),
                  const SizedBox(height: 20),
                  _buildReceiptSection(theme),
                  const SizedBox(height: 20),
                  _buildRecurrenceSection(theme),
                  const SizedBox(height: 20),
                  _buildNotesSection(theme),
                  const SizedBox(height: 32),
                  _buildActionButtons(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categoria',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
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
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
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
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Básicas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição*',
                hintText: 'Ex: Consulta veterinária, vacina antirrábica...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
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
              decoration: const InputDecoration(
                labelText: 'Veterinário/Local',
                hintText: 'Nome do veterinário ou clínica',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Valor',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Valor*',
                hintText: '0,00',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'R\$',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Valor é obrigatório';
                }
                
                final amount = double.tryParse(value.replaceAll(',', '.'));
                if (amount == null || amount <= 0) {
                  return 'Digite um valor válido maior que zero';
                }
                
                if (amount > 999999.99) {
                  return 'Valor muito alto';
                }
                
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Despesa Paga'),
              subtitle: Text(_isPaid ? 'Pago' : 'Pendente'),
              value: _isPaid,
              onChanged: (value) {
                setState(() {
                  _isPaid = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Data da Despesa'),
              subtitle: Text(_formatDate(_selectedDate)),
              onTap: _selectDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: theme.dividerColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recibo/Nota',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Possui recibo'),
              subtitle: const Text('Possui comprovante da despesa'),
              value: _hasReceipt,
              onChanged: (value) {
                setState(() {
                  _hasReceipt = value;
                });
              },
            ),
            if (_hasReceipt) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _receiptNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número do Recibo',
                  hintText: 'Ex: 12345, NF-001...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recorrência',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Despesa Recorrente'),
              subtitle: const Text('Repetir esta despesa automaticamente'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value;
                });
              },
            ),
            if (_isRecurring) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<RecurrenceType>(
                initialValue: _recurrenceType,
                decoration: const InputDecoration(
                  labelText: 'Frequência',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: RecurrenceType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(_getRecurrenceTypeName(type)),
                )).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _recurrenceType = value;
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Observações',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas adicionais',
                hintText: 'Informações extras sobre a despesa...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton(
            onPressed: _isSubmitting ? null : _submitForm,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.expense == null ? 'Salvar' : 'Atualizar'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma categoria'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      
      final expense = Expense(
        id: widget.expense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
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
        receiptNumber: _hasReceipt && _receiptNumberController.text.trim().isNotEmpty
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Despesa adicionada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await ref.read(expensesProvider.notifier).updateExpense(expense);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Despesa atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
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
        setState(() {
          _isSubmitting = false;
        });
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

