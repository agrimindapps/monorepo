import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';

import '../../domain/entities/vaccine.dart';
import '../providers/vaccines_provider.dart';
import 'vaccine_advanced_options.dart';
import 'vaccine_basic_info_form.dart';
import 'vaccine_reminders_form.dart';
import 'vaccine_scheduling_form.dart';

/// Refactored vaccine scheduling interface following SOLID principles
/// 
/// This is the main coordinator widget that composes all extracted components
/// following SRP, OCP, and DIP principles.
class VaccineSchedulingInterfaceRefactored extends ConsumerStatefulWidget {
  final Vaccine? existingVaccine;
  final String? animalId;
  final VoidCallback? onScheduled;

  const VaccineSchedulingInterfaceRefactored({
    super.key,
    this.existingVaccine,
    this.animalId,
    this.onScheduled,
  });

  @override
  ConsumerState<VaccineSchedulingInterfaceRefactored> createState() => _VaccineSchedulingInterfaceRefactoredState();
}

class _VaccineSchedulingInterfaceRefactoredState extends ConsumerState<VaccineSchedulingInterfaceRefactored>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _batchController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _scheduledDate = DateTime.now();
  DateTime? _nextDueDate;
  DateTime? _reminderDate;
  VaccineStatus _status = VaccineStatus.scheduled;
  bool _isRequired = true;
  bool _isSeriesVaccine = false;
  int _seriesCount = 1;
  int _seriesIntervalDays = 30;
  bool _enableSmartReminders = true;
  bool _enableSeasonalReminders = false;
  String? _selectedSeason;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.existingVaccine != null) {
      final vaccine = widget.existingVaccine!;
      _nameController.text = vaccine.name;
      _veterinarianController.text = vaccine.veterinarian;
      _batchController.text = vaccine.batch ?? '';
      _manufacturerController.text = vaccine.manufacturer ?? '';
      _dosageController.text = vaccine.dosage ?? '';
      _notesController.text = vaccine.notes ?? '';
      _scheduledDate = vaccine.date;
      _nextDueDate = vaccine.nextDueDate;
      _reminderDate = vaccine.reminderDate;
      _isRequired = vaccine.isRequired;
      _status = vaccine.status;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _veterinarianController.dispose();
    _batchController.dispose();
    _manufacturerController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingVaccine == null ? 'Agendar Vacina' : 'Editar Vacina'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'Básico'),
            Tab(icon: Icon(Icons.schedule), text: 'Agendamento'),
            Tab(icon: Icon(Icons.notifications), text: 'Lembretes'),
            Tab(icon: Icon(Icons.analytics), text: 'Avançado'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: _saveVaccine,
            child: const Text('Salvar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildSchedulingTab(),
            _buildRemindersTab(),
            _buildAdvancedTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      child: VaccineBasicInfoForm(
        nameController: _nameController,
        veterinarianController: _veterinarianController,
        batchController: _batchController,
        manufacturerController: _manufacturerController,
        dosageController: _dosageController,
        notesController: _notesController,
        status: _status,
        isRequired: _isRequired,
        onStatusChanged: (status) => setState(() => _status = status),
        onRequiredChanged: (required) => setState(() => _isRequired = required),
      ),
    );
  }

  Widget _buildSchedulingTab() {
    return SingleChildScrollView(
      child: VaccineSchedulingForm(
        scheduledDate: _scheduledDate,
        nextDueDate: _nextDueDate,
        isSeriesVaccine: _isSeriesVaccine,
        seriesCount: _seriesCount,
        seriesIntervalDays: _seriesIntervalDays,
        onScheduledDateChanged: (date) => setState(() => _scheduledDate = date),
        onNextDueDateChanged: (date) => setState(() => _nextDueDate = date),
        onIsSeriesChanged: (isSeries) => setState(() => _isSeriesVaccine = isSeries),
        onSeriesCountChanged: (count) => setState(() => _seriesCount = count),
        onSeriesIntervalChanged: (interval) => setState(() => _seriesIntervalDays = interval),
      ),
    );
  }

  Widget _buildRemindersTab() {
    return SingleChildScrollView(
      child: VaccineRemindersForm(
        reminderDate: _reminderDate,
        enableSmartReminders: _enableSmartReminders,
        enableSeasonalReminders: _enableSeasonalReminders,
        selectedSeason: _selectedSeason,
        onReminderDateChanged: (date) => setState(() => _reminderDate = date),
        onSmartRemindersChanged: (enabled) => setState(() => _enableSmartReminders = enabled),
        onSeasonalRemindersChanged: (enabled) => setState(() => _enableSeasonalReminders = enabled),
        onSeasonChanged: (season) => setState(() => _selectedSeason = season),
      ),
    );
  }

  Widget _buildAdvancedTab() {
    return SingleChildScrollView(
      child: VaccineAdvancedOptions(
        onTemplateSelected: _applyVaccineTemplate,
      ),
    );
  }

  void _applyVaccineTemplate(Map<String, dynamic> template) {
    setState(() {
      _nameController.text = template['name'] as String;
      _isSeriesVaccine = (template['series'] as int) > 1;
      _seriesCount = template['series'] as int;
      
      if (template['interval'] != null) {
        _nextDueDate = _scheduledDate.add(Duration(days: template['interval'] as int));
      }
    });
  }

  Future<void> _saveVaccine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vaccine = Vaccine(
      id: widget.existingVaccine?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      animalId: widget.animalId ?? widget.existingVaccine!.animalId,
      name: _nameController.text.trim(),
      veterinarian: _veterinarianController.text.trim(),
      date: _scheduledDate,
      nextDueDate: _nextDueDate,
      batch: _batchController.text.trim().isEmpty ? null : _batchController.text.trim(),
      manufacturer: _manufacturerController.text.trim().isEmpty ? null : _manufacturerController.text.trim(),
      dosage: _dosageController.text.trim().isEmpty ? null : _dosageController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      isRequired: _isRequired,
      reminderDate: _reminderDate,
      status: _status,
      createdAt: widget.existingVaccine?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.existingVaccine == null) {
        await ref.read(vaccinesProvider.notifier).addVaccine(vaccine);
        if (_isSeriesVaccine && _seriesCount > 1) {
          await _createSeriesVaccines(vaccine);
        }
      } else {
        await ref.read(vaccinesProvider.notifier).updateVaccine(vaccine);
      }

      if (mounted) {
        widget.onScheduled?.call();
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingVaccine == null 
                ? 'Vacina agendada com sucesso!' 
                : 'Vacina atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar vacina: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createSeriesVaccines(Vaccine baseVaccine) async {
    for (int i = 1; i < _seriesCount; i++) {
      final seriesDose = baseVaccine.copyWith(
        id: '${baseVaccine.id}_series_${i + 1}',
        date: _scheduledDate.add(Duration(days: i * _seriesIntervalDays)),
        nextDueDate: i == _seriesCount - 1 
            ? null 
            : _scheduledDate.add(Duration(days: (i + 1) * _seriesIntervalDays)),
        notes: '${baseVaccine.notes ?? ''}\nDose ${i + 1} de $_seriesCount da série'.trim(),
      );
      await ref.read(vaccinesProvider.notifier).addVaccine(seriesDose);
    }
  }
}