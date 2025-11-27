import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/water_custom_cup_entity.dart';
import '../providers/water_tracker_providers.dart';

/// Quick add buttons widget for rapid water intake logging
class QuickAddButtons extends ConsumerWidget {
  final VoidCallback? onRecordAdded;

  const QuickAddButtons({
    super.key,
    this.onRecordAdded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cupsAsync = ref.watch(customCupsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '💧 Adicionar Água',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showCustomCupDialog(context, ref),
                  tooltip: 'Personalizar copos',
                ),
              ],
            ),
            const SizedBox(height: 16),
            cupsAsync.when(
              data: (cups) => _buildCupGrid(context, ref, cups),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Erro ao carregar copos'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupGrid(
    BuildContext context,
    WidgetRef ref,
    List<WaterCustomCupEntity> cups,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cups.map((cup) => _QuickAddButton(
        cup: cup,
        onTap: () => _addWater(context, ref, cup.amountMl),
      )).toList(),
    );
  }

  Future<void> _addWater(
    BuildContext context,
    WidgetRef ref,
    int amountMl,
  ) async {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    try {
      await ref.read(todayRecordsProvider.notifier).addRecord(amountMl);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('+$amountMl ml adicionado'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      onRecordAdded?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showCustomCupDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _AddCustomCupDialog(),
    );

    if (result != null) {
      await ref.read(customCupsProvider.notifier).addCup(
        name: result['name'],
        amountMl: result['amount'],
        iconName: result['icon'],
      );
    }
  }
}

class _QuickAddButton extends StatefulWidget {
  final WaterCustomCupEntity cup;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.cup,
    required this.onTap,
  });

  @override
  State<_QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<_QuickAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    switch (widget.cup.iconName) {
      case 'water_bottle':
        return Icons.water;
      case 'local_drink':
      default:
        return Icons.local_drink;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.cup.isDefault
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '+${widget.cup.amountMl}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
              ),
              Text(
                'ml',
                style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCustomCupDialog extends StatefulWidget {
  const _AddCustomCupDialog();

  @override
  State<_AddCustomCupDialog> createState() => _AddCustomCupDialogState();
}

class _AddCustomCupDialogState extends State<_AddCustomCupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedIcon = 'local_drink';

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Recipiente'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Ex: Squeeze',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Quantidade (ml)',
                hintText: 'Ex: 600',
                suffixText: 'ml',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a quantidade';
                }
                final amount = int.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Quantidade inválida';
                }
                if (amount > 5000) {
                  return 'Máximo 5000ml';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Ícone:'),
                const SizedBox(width: 16),
                _IconOption(
                  icon: Icons.local_drink,
                  isSelected: _selectedIcon == 'local_drink',
                  onTap: () => setState(() => _selectedIcon = 'local_drink'),
                ),
                const SizedBox(width: 8),
                _IconOption(
                  icon: Icons.water,
                  isSelected: _selectedIcon == 'water_bottle',
                  onTap: () => setState(() => _selectedIcon = 'water_bottle'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameController.text.trim(),
        'amount': int.parse(_amountController.text),
        'icon': _selectedIcon,
      });
    }
  }
}

class _IconOption extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconOption({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? theme.colorScheme.primary : Colors.grey[600],
        ),
      ),
    );
  }
}
