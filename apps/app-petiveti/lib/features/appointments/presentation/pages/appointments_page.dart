import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/appointment.dart';
import '../providers/appointments_provider.dart';
import '../widgets/appointment_card.dart';
import '../widgets/appointments_auto_reload_manager.dart';
import '../widgets/empty_appointments_state.dart';
final selectedAnimalIdProvider = StateProvider<String?>((ref) => null);

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
    final selectedAnimalId = ref.read(selectedAnimalIdProvider);
    if (selectedAnimalId != null) {
      ref.read(appointmentsProvider.notifier).loadAppointments(selectedAnimalId);
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
    final selectedAnimalId = ref.watch(selectedAnimalIdProvider);
    final appointments = ref.watch(appointmentsListProvider);

    return AppointmentsAutoReloadManager(
      selectedAnimalId: selectedAnimalId,
      onReloadStart: () {
      },
      onReloadComplete: () {
      },
      onReloadError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar consultas: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Consultas'),
        actions: [
          Semantics(
            label: 'Atualizar lista de consultas',
            hint: 'Toque para recarregar as consultas',
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAppointments,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (selectedAnimalId != null)
            Semantics(
              label: 'Animal selecionado para consultas',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Semantics(
                      label: 'Avatar do animal selecionado',
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          'A',  // Simplified - could get from animal data if needed
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Animal Selecionado',  // Simplified - could get from animal data
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ID: $selectedAnimalId',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _buildContent(context, appointmentState, appointments, selectedAnimalId),
          ),
        ],
      ),
      floatingActionButton: selectedAnimalId != null
          ? Semantics(
              label: 'Adicionar nova consulta',
              hint: 'Toque para agendar uma nova consulta para o animal selecionado',
              child: FloatingActionButton(
                onPressed: () => context.push('/appointments/add'),
                child: const Icon(Icons.add),
              ),
            )
          : null,
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
      return Semantics(
        label: 'Nenhum animal selecionado',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Selecione um animal primeiro',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Acesse a página de animais para selecionar um pet',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isLoading) {
      return Semantics(
        label: 'Carregando consultas',
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null) {
      return Semantics(
        label: 'Erro ao carregar consultas',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar consultas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Tentar carregar consultas novamente',
                child: ElevatedButton(
                  onPressed: _loadAppointments,
                  child: const Text('Tentar Novamente'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (appointments.isEmpty) {
      return const EmptyAppointmentsState();
    }

    return Semantics(
      label: 'Lista de consultas do animal',
      child: RefreshIndicator(
        onRefresh: () async => _loadAppointments(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemExtent: 120, // Fixed height for better performance
          cacheExtent: 1000, // Cache more items for smoother scrolling
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
                color: Theme.of(context).colorScheme.error,
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
              onDismissed: (direction) {
              },
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: slideController,
                  curve: Curves.easeOutCubic,
                )),
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
                                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
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
                              : () => context.push('/appointments/${appointment.id}'),
                          onEdit: isBeingDeleted 
                              ? null 
                              : () => context.push('/appointments/${appointment.id}/edit'),
                          onDelete: isBeingDeleted 
                              ? null 
                              : () => _showDeleteDialog(context, appointment),
                        ),
                        if (isBeingDeleted)
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Excluindo...',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.error,
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
      ),
    );
  }

  Future<bool?> _showDeleteDialogForDismiss(BuildContext context, Appointment appointment) async {
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
              onPressed: _isDeleting ? null : () async {
                setState(() => _isDeleting = true);
                
                try {
                  this.setState(() => _itemBeingDeleted = appointment.id);
                  
                  final success = await ref
                      .read(appointmentsProvider.notifier)
                      .deleteAppointment(appointment.id);
                  
                  if (context.mounted) {
                    Navigator.of(context).pop(success);
                    if (success) {
                      _showResultSnackBar(context, success, 'consulta excluída');
                      final fadeController = _fadeAnimations[appointment.id];
                      if (fadeController != null) {
                        await fadeController.reverse();
                      }
                    } else {
                      _showResultSnackBar(context, success, 'consulta excluída');
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
        action: success ? null : SnackBarAction(
          label: 'Tentar Novamente',
          onPressed: _loadAppointments,
        ),
      ),
    );
  }
}