import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../animals/presentation/providers/animals_provider.dart';
import '../../domain/entities/appointment.dart';
import '../providers/appointments_provider.dart';
import '../widgets/appointment_card.dart';
import '../widgets/empty_appointments_state.dart';

class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({super.key});

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  void _loadAppointments() {
    final selectedAnimal = ref.read(selectedAnimalProvider);
    if (selectedAnimal != null) {
      ref.read(appointmentsProvider.notifier).loadAppointments(selectedAnimal.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentsProvider);
    final selectedAnimal = ref.watch(selectedAnimalProvider);
    final appointments = ref.watch(appointmentsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: Column(
        children: [
          // Animal selector info
          if (selectedAnimal != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      selectedAnimal.name.isNotEmpty ? selectedAnimal.name[0].toUpperCase() : 'A',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedAnimal.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${selectedAnimal.species} • ${selectedAnimal.breed}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: _buildContent(context, appointmentState, appointments, selectedAnimal?.id),
          ),
        ],
      ),
      floatingActionButton: selectedAnimal != null
          ? FloatingActionButton(
              onPressed: () => context.push('/appointments/add'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppointmentState state,
    List<dynamic> appointments,
    String? animalId,
  ) {
    if (animalId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Selecione um animal primeiro',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Acesse a página de animais para selecionar um pet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
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
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
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
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAppointments,
              child: const Text('Tentar Novamente'),
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
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppointmentCard(
              appointment: appointment as Appointment,
              onTap: () => context.push('/appointments/${appointment.id}'),
              onEdit: () => context.push('/appointments/${appointment.id}/edit'),
              onDelete: () => _showDeleteDialog(context, appointment),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Consulta'),
        content: Text(
          'Tem certeza que deseja excluir a consulta de ${appointment.date.day}/${appointment.date.month}/${appointment.date.year}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(appointmentsProvider.notifier)
                  .deleteAppointment(appointment.id);
              
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Consulta excluída com sucesso'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}