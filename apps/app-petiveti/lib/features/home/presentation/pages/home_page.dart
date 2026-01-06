import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../shared/widgets/crud_form_dialog.dart';
import '../../../../shared/widgets/enhanced_animal_selector.dart';
import '../../../../shared/widgets/petiveti_page_header.dart';
import '../../../animals/presentation/providers/animals_providers.dart';
import '../../../appointments/presentation/providers/appointments_providers.dart';
import '../../../medications/presentation/providers/medications_providers.dart';
import '../../../vaccines/presentation/pages/vaccine_form_page.dart';
import '../../../vaccines/presentation/providers/vaccines_providers.dart';
import '../../../weight/presentation/providers/weight_providers.dart';
import '../providers/activities_providers.dart';
import '../providers/home_providers.dart';
import '../services/home_actions_service.dart';
import '../widgets/recent_records/appointment_record_item.dart';
import '../widgets/recent_records/medication_record_item.dart';
import '../widgets/recent_records/recent_records_card.dart';
import '../widgets/recent_records/vaccine_record_item.dart';
import '../widgets/recent_records/weight_record_item.dart';

/// Home Page - Activities Dashboard (Gasometer Style)
///
/// Displays recent activities from all categories with animal selector:
/// - Vaccines (last 3)
/// - Appointments (last 3)
/// - Medications (last 3)
/// - Weight records (last 3)
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final HomeActionsService _actionsService = HomeActionsService();
  String? _selectedAnimalId;

  @override
  void initState() {
    super.initState();
    _loadSavedAnimal();
  }

  Future<void> _loadSavedAnimal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAnimalId = prefs.getString('selected_animal_id');
      if (mounted && savedAnimalId != null) {
        setState(() {
          _selectedAnimalId = savedAnimalId;
        });
        _loadAllData();
      } else if (mounted) {
        _loadAllData();
      }
    } catch (e) {
      if (mounted) {
        _loadAllData();
      }
    }
  }

  void _loadAllData() {
    // Carrega dados de home
    ref.read(homeNotificationsProvider.notifier).loadNotifications();
    ref.read(homeStatsProvider.notifier).loadStats();
    ref.read(homeStatusProvider.notifier).checkStatus();
    
    // Carrega dados de atividades (vacinas e medicamentos não precisam de animalId)
    ref.read(vaccinesProvider.notifier).loadVaccines();
    ref.read(medicationsProvider.notifier).loadMedications();
    ref.read(weightsProvider.notifier).loadWeights();
    
    // Appointments precisa de animalId, será carregado quando um animal for selecionado
    if (_selectedAnimalId != null) {
      ref.read(appointmentsProvider.notifier).loadAppointments(_selectedAnimalId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final animalsState = ref.watch(animalsProvider);
    final statusState = ref.watch(homeStatusProvider);
    final notificationsState = ref.watch(homeNotificationsProvider);
    final hasUnreadNotifications = ref.watch(hasUnreadNotificationsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, statusState, notificationsState, hasUnreadNotifications),
            
            // Animal Selector
            _buildAnimalSelector(context),
            
            // Content area
            Expanded(
              child: animalsState.isLoading && animalsState.animals.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCardsContent(
                      context,
                      hasAnimals: animalsState.animals.isNotEmpty,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    HomeStatusState statusState,
    HomeNotificationsState notificationsState,
    bool hasUnreadNotifications,
  ) {
    return PetivetiPageHeader(
      icon: Icons.history,
      title: 'Atividades',
      subtitle: 'Últimas atividades dos seus pets',
      actions: [
        // Notificações
        Stack(
          children: [
            IconButton(
              icon: Icon(
                hasUnreadNotifications ? Icons.notifications_active : Icons.notifications,
                color: Colors.white,
              ),
              onPressed: _showNotifications,
            ),
            if (hasUnreadNotifications)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    '${notificationsState.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        // Status
        IconButton(
          icon: Icon(
            statusState.isOnline ? Icons.cloud_done : Icons.cloud_off,
            color: Colors.white,
          ),
          onPressed: () => _actionsService.showStatusInfo(context, statusState),
        ),
      ],
    );
  }

  Widget _buildAnimalSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 0.0),
      child: EnhancedAnimalSelector(
        selectedAnimalId: _selectedAnimalId,
        onAnimalChanged: (animalId) {
          setState(() {
            _selectedAnimalId = animalId;
          });
          // Carrega appointments para o animal selecionado
          if (animalId != null) {
            ref.read(appointmentsProvider.notifier).loadAppointments(animalId);
            ref.invalidate(recentActivitiesProvider(animalId));
          }
        },
      ),
    );
  }

  Widget _buildCardsContent(BuildContext context, {required bool hasAnimals}) {
    // Se não há animais, mostra os cards vazios com mensagem apropriada
    if (!hasAnimals) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            RecentRecordsCard(
              title: 'Vacinas',
              icon: Icons.vaccines,
              recordItems: const [],
              onViewAll: () => context.go('/vaccines'),
              onAdd: null, // Desabilitado sem animais
              isEmpty: true,
              emptyMessage: 'Nenhum pet cadastrado',
            ),
            RecentRecordsCard(
              title: 'Consultas',
              icon: Icons.calendar_today,
              recordItems: const [],
              onViewAll: () => context.go('/appointments'),
              onAdd: null, // Desabilitado sem animais
              isEmpty: true,
              emptyMessage: 'Nenhum pet cadastrado',
            ),
            RecentRecordsCard(
              title: 'Medicamentos',
              icon: Icons.medication,
              recordItems: const [],
              onViewAll: () => context.go('/medications'),
              onAdd: null, // Desabilitado sem animais
              isEmpty: true,
              emptyMessage: 'Nenhum pet cadastrado',
            ),
            RecentRecordsCard(
              title: 'Peso',
              icon: Icons.monitor_weight,
              recordItems: const [],
              onViewAll: () => context.go('/weight'),
              onAdd: null, // Desabilitado sem animais
              isEmpty: true,
              emptyMessage: 'Nenhum pet cadastrado',
            ),
          ],
        ),
      );
    }

    // Se há animais mas nenhum selecionado
    if (_selectedAnimalId == null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            RecentRecordsCard(
              title: 'Vacinas',
              icon: Icons.vaccines,
              recordItems: const [],
              onViewAll: () => context.go('/vaccines'),
              onAdd: null, // Desabilitado sem seleção
              isEmpty: true,
              emptyMessage: 'Selecione um pet acima',
            ),
            RecentRecordsCard(
              title: 'Consultas',
              icon: Icons.calendar_today,
              recordItems: const [],
              onViewAll: () => context.go('/appointments'),
              onAdd: null, // Desabilitado sem seleção
              isEmpty: true,
              emptyMessage: 'Selecione um pet acima',
            ),
            RecentRecordsCard(
              title: 'Medicamentos',
              icon: Icons.medication,
              recordItems: const [],
              onViewAll: () => context.go('/medications'),
              onAdd: null, // Desabilitado sem seleção
              isEmpty: true,
              emptyMessage: 'Selecione um pet acima',
            ),
            RecentRecordsCard(
              title: 'Peso',
              icon: Icons.monitor_weight,
              recordItems: const [],
              onViewAll: () => context.go('/weight'),
              onAdd: null, // Desabilitado sem seleção
              isEmpty: true,
              emptyMessage: 'Selecione um pet acima',
            ),
          ],
        ),
      );
    }

    // Se há um animal selecionado, busca os dados de atividades
    return _buildActivitiesCards(context);
  }

  Widget _buildActivitiesCards(BuildContext context) {
    final vaccinesState = ref.watch(vaccinesProvider);
    final appointmentsState = ref.watch(appointmentsProvider);
    final medicationsState = ref.watch(medicationsProvider);
    final weightsState = ref.watch(weightsProvider);

    // Filtra por animal selecionado
    final vaccines = vaccinesState.vaccines
        .where((v) => v.animalId == _selectedAnimalId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final appointments = appointmentsState.appointments
        .where((a) => a.animalId == _selectedAnimalId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final medications = medicationsState.medications
        .where((m) => m.animalId == _selectedAnimalId)
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    final weights = weightsState.weights
        .where((w) => w.animalId == _selectedAnimalId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return RefreshIndicator(
      onRefresh: () async => _loadAllData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            // Vaccines Card
            RecentRecordsCard(
              title: 'Vacinas',
              icon: Icons.vaccines,
              recordItems: vaccines
                  .take(3)
                  .map((vaccine) => VaccineRecordItem(
                        record: vaccine,
                        onTap: () => context.go('/vaccines'),
                      ))
                  .toList(),
              onViewAll: () => context.go('/vaccines'),
              onAdd: () => _openAddDialog('vaccines'),
              isEmpty: vaccines.isEmpty,
              emptyMessage: 'Nenhuma vacina registrada',
            ),

            // Appointments Card
            RecentRecordsCard(
              title: 'Consultas',
              icon: Icons.calendar_today,
              recordItems: appointments
                  .take(3)
                  .map((appointment) => AppointmentRecordItem(
                        record: appointment,
                        onTap: () => context.go('/appointments'),
                      ))
                  .toList(),
              onViewAll: () => context.go('/appointments'),
              onAdd: () => _openAddDialog('appointments'),
              isEmpty: appointments.isEmpty,
              emptyMessage: 'Nenhuma consulta registrada',
            ),

            // Medications Card
            RecentRecordsCard(
              title: 'Medicamentos',
              icon: Icons.medication,
              recordItems: medications
                  .take(3)
                  .map((medication) => MedicationRecordItem(
                        record: medication,
                        onTap: () => context.go('/medications'),
                      ))
                  .toList(),
              onViewAll: () => context.go('/medications'),
              onAdd: () => _openAddDialog('medications'),
              isEmpty: medications.isEmpty,
              emptyMessage: 'Nenhum medicamento registrado',
            ),

            // Weight Card
            RecentRecordsCard(
              title: 'Peso',
              icon: Icons.monitor_weight,
              recordItems: weights
                  .take(3)
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) => WeightRecordItem(
                        record: entry.value,
                        previousWeight: entry.key + 1 < weights.length
                            ? weights[entry.key + 1].weight
                            : null,
                        onTap: () => context.go('/weight'),
                      ))
                  .toList(),
              onViewAll: () => context.go('/weight'),
              onAdd: () => _openAddDialog('weight'),
              isEmpty: weights.isEmpty,
              emptyMessage: 'Nenhum registro de peso',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddDialog(String type) async {
    if (_selectedAnimalId == null) return;

    bool? result;

    // Navega para a página correspondente para adicionar
    switch (type) {
      case 'vaccines':
        result = await showDialog<bool>(
          context: context,
          builder: (context) => VaccineFormPage(
            animalId: _selectedAnimalId,
            initialMode: CrudDialogMode.create,
          ),
        );
        break;
      case 'appointments':
        context.go('/appointments');
        break;
      case 'medications':
        context.go('/medications');
        break;
      case 'weight':
        context.go('/weight');
        break;
    }

    if (result == true && mounted) {
      // Recarrega dados após salvar
      ref.invalidate(vaccinesProvider);
    }
  }

  void _showNotifications() {
    final notifications = ref.read(homeNotificationsProvider);

    _actionsService.showNotifications(
      context,
      notifications,
      onMarkAllAsRead: () {
        ref.read(homeNotificationsProvider.notifier).markAllAsRead();
      },
    );
  }
}
