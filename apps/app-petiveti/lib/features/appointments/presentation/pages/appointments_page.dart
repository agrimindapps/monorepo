import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../shared/widgets/enhanced_animal_selector.dart';
import '../../../../shared/widgets/petiveti_page_header.dart';
import '../../domain/entities/appointment.dart';
import '../providers/appointments_providers.dart';
import '../widgets/appointment_card.dart';
import '../widgets/empty_appointments_state.dart';

class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({super.key});

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage>
    with TickerProviderStateMixin {
  bool _isDeleting = false;
  final Map<String, AnimationController> _slideAnimations = {};
  final Map<String, AnimationController> _fadeAnimations = {};
  String? _itemBeingDeleted;
  String? _selectedAnimalId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (final controller in _slideAnimations.values) {
      controller.dispose();
    }
    for (final controller in _fadeAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _loadAppointments() {
    if (_selectedAnimalId != null) {
      ref
          .read(appointmentsProvider.notifier)
          .loadAppointments(_selectedAnimalId!);
    }
  }

  AnimationController _getSlideController(String id) {
    return _slideAnimations.putIfAbsent(
      id,
      () => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      )..forward(),
    );
  }

  AnimationController _getFadeController(String id) {
    return _fadeAnimations.putIfAbsent(
      id,
      () => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      )..forward(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentsProvider);
    final appointments = ref.watch(appointmentsListProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildAnimalSelector(),
            Expanded(
              child: _buildContent(
                context,
                appointmentState,
                appointments,
                _selectedAnimalId,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedAnimalId != null
            ? () => context.push('/appointments/add')
            : null,
        tooltip: _selectedAnimalId != null
            ? 'Adicionar Consulta'
            : 'Selecione um pet primeiro',
        backgroundColor: _selectedAnimalId != null
            ? null
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: _selectedAnimalId != null
            ? null
            : Theme.of(context).colorScheme.onSurfaceVariant,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: PetivetiPageHeader(
        icon: Icons.calendar_month,
        title: 'Consultas',
        subtitle: 'Agendamentos veterinários',
        showBackButton: true,
        actions: [
          _buildHeaderAction(
            icon: Icons.refresh,
            onTap: _loadAppointments,
            tooltip: 'Atualizar',
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: EnhancedAnimalSelector(
        selectedAnimalId: _selectedAnimalId,
        onAnimalChanged: (animalId) {
          setState(() => _selectedAnimalId = animalId);
          if (animalId != null) {
            ref.read(appointmentsProvider.notifier).loadAppointments(animalId);
          }
        },
        hintText: 'Selecione um pet',
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppointmentState state,
    List<Appointment> appointments,
    String? animalId,
  ) {
    if (animalId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Selecione um pet', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Escolha um pet acima para ver suas consultas'),
          ],
        ),
      );
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(state.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAppointments,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (appointments.isEmpty) {
      return const EmptyAppointmentsState();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadAppointments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          final slideController = _getSlideController(appointment.id);
          final fadeController = _getFadeController(appointment.id);
          final isBeingDeleted = _itemBeingDeleted == appointment.id;

          return Dismissible(
            key: ValueKey(appointment.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Excluir',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            confirmDismiss: (direction) async {
              return await _showDeleteDialogForDismiss(context, appointment);
            },
            onDismissed: (direction) {},
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: slideController,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                child: FadeTransition(
                  opacity: fadeController,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                      bottom: 12,
                      left: isBeingDeleted ? 16 : 0,
                      right: isBeingDeleted ? 16 : 0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isBeingDeleted
                          ? [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.error.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      children: [
                        AppointmentCard(
                          appointment: appointment,
                          onTap: isBeingDeleted
                              ? null
                              : () => context.push(
                                  '/appointments/${appointment.id}',
                                ),
                          onEdit: isBeingDeleted
                              ? null
                              : () => context.push(
                                  '/appointments/${appointment.id}/edit',
                                ),
                          onDelete: isBeingDeleted
                              ? null
                              : () => _showDeleteDialog(context, appointment),
                        ),
                        if (isBeingDeleted)
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surface.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Excluindo...',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
  }

  Future<bool?> _showDeleteDialogForDismiss(
    BuildContext context,
    Appointment appointment,
  ) async {
    final formattedDate = DateFormat('dd/MM/yyyy').format(appointment.date);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        title: const Text('Excluir Consulta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tem certeza que deseja excluir a consulta de $formattedDate?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta ação não pode ser desfeita.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          StatefulBuilder(
            builder: (context, setState) => ElevatedButton(
              onPressed: _isDeleting
                  ? null
                  : () async {
                      setState(() => _isDeleting = true);

                      try {
                        this.setState(() => _itemBeingDeleted = appointment.id);

                        final success = await ref
                            .read(appointmentsProvider.notifier)
                            .deleteAppointment(appointment.id);

                        if (context.mounted) {
                          Navigator.of(context).pop(success);
                          if (success) {
                            _showResultSnackBar(
                              context,
                              success,
                              'consulta excluída',
                            );
                            final fadeController =
                                _fadeAnimations[appointment.id];
                            if (fadeController != null) {
                              await fadeController.reverse();
                            }
                          } else {
                            _showResultSnackBar(
                              context,
                              success,
                              'consulta excluída',
                            );
                          }
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isDeleting = false);
                          this.setState(() => _itemBeingDeleted = null);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: _isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Excluir'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Appointment appointment) async {
    await _showDeleteDialogForDismiss(context, appointment);
  }

  void _showResultSnackBar(BuildContext context, bool success, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${action[0].toUpperCase()}${action.substring(1)} com sucesso'
              : 'Erro ao ${action.split(' ').join(' ')}',
        ),
        backgroundColor: success
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error,
        action: success
            ? null
            : SnackBarAction(
                label: 'Tentar Novamente',
                onPressed: _loadAppointments,
              ),
      ),
    );
  }
}
