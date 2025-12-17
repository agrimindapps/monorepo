import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../animals/presentation/providers/animals_providers.dart';
import '../../domain/entities/appointment.dart';
import '../providers/appointments_providers.dart';
import '../widgets/add_appointment_form.dart';

/// Página de detalhes de uma consulta veterinária
///
/// Exibe todas as informações da consulta incluindo:
/// - Data e horário
/// - Veterinário
/// - Animal
/// - Motivo e diagnóstico
/// - Status e custo
/// - Notas
///
/// Permite editar e deletar a consulta
class AppointmentDetailsPage extends ConsumerWidget {
  final String appointmentId;

  const AppointmentDetailsPage({
    super.key,
    required this.appointmentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsState = ref.watch(appointmentsProvider);
    
    // Busca appointment pelo ID
    final appointment = appointmentsState.appointments.firstWhere(
      (app) => app.id == appointmentId,
      orElse: () => throw Exception('Appointment not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Consulta'),
        actions: [
          // Botão de editar
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar consulta',
            onPressed: () => _editAppointment(context, ref, appointment),
          ),
          // Botão de deletar
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Excluir consulta',
            onPressed: () => _deleteAppointment(context, ref, appointment),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context, appointment),
            const SizedBox(height: 16),
            _buildDateTimeCard(context, appointment),
            const SizedBox(height: 16),
            _buildVeterinarianCard(context, appointment),
            const SizedBox(height: 16),
            _buildAnimalCard(context, ref, appointment),
            const SizedBox(height: 16),
            _buildReasonCard(context, appointment),
            if (appointment.diagnosis != null) ...[
              const SizedBox(height: 16),
              _buildDiagnosisCard(context, appointment),
            ],
            if (appointment.notes != null) ...[
              const SizedBox(height: 16),
              _buildNotesCard(context, appointment),
            ],
            if (appointment.cost != null && appointment.cost! > 0) ...[
              const SizedBox(height: 16),
              _buildCostCard(context, appointment),
            ],
            const SizedBox(height: 16),
            _buildMetadataCard(context, appointment),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, Appointment appointment) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color statusColor;
    Color statusTextColor;
    
    switch (appointment.status) {
      case AppointmentStatus.scheduled:
        statusColor = colorScheme.primaryContainer;
        statusTextColor = colorScheme.onPrimaryContainer;
        break;
      case AppointmentStatus.completed:
        statusColor = colorScheme.tertiaryContainer;
        statusTextColor = colorScheme.onTertiaryContainer;
        break;
      case AppointmentStatus.cancelled:
        statusColor = colorScheme.errorContainer;
        statusTextColor = colorScheme.onErrorContainer;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                appointment.displayStatus,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: statusTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            if (appointment.isUpcoming)
              const Icon(Icons.schedule, color: Colors.blue)
            else if (appointment.isPast)
              const Icon(Icons.check_circle, color: Colors.green)
            else
              const Icon(Icons.today, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeCard(BuildContext context, Appointment appointment) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('EEEE, dd \'de\' MMMM \'de\' yyyy', 'pt_BR')
        .format(appointment.date);
    final formattedTime = DateFormat('HH:mm').format(appointment.date);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today, size: 32),
        title: Text(
          formattedDate,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          'Horário: $formattedTime',
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildVeterinarianCard(BuildContext context, Appointment appointment) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.medical_services, size: 32),
        title: const Text('Veterinário(a)'),
        subtitle: Text(
          appointment.veterinarianName,
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }

  Widget _buildAnimalCard(
    BuildContext context,
    WidgetRef ref,
    Appointment appointment,
  ) {
    final theme = Theme.of(context);
    
    // Busca informações do animal
    final animalAsync = ref.watch(animalByIdProvider(appointment.animalId));

    return animalAsync.when(
      data: (animal) {
        if (animal == null) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.pets, size: 32),
              title: const Text('Animal'),
              subtitle: Text('ID: ${appointment.animalId}'),
            ),
          );
        }

        return Card(
          child: ListTile(
            leading: const Icon(Icons.pets, size: 32),
            title: const Text('Animal'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.name,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '${animal.species} - ${animal.breed}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Carregando informações do animal...'),
        ),
      ),
      error: (_, __) => Card(
        child: ListTile(
          leading: const Icon(Icons.pets, size: 32),
          title: const Text('Animal'),
          subtitle: Text('ID: ${appointment.animalId}'),
        ),
      ),
    );
  }

  Widget _buildReasonCard(BuildContext context, Appointment appointment) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description),
                const SizedBox(width: 8),
                Text(
                  'Motivo da Consulta',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appointment.reason,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisCard(BuildContext context, Appointment appointment) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Diagnóstico',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appointment.diagnosis!,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, Appointment appointment) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note),
                const SizedBox(width: 8),
                Text(
                  'Observações',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appointment.notes!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostCard(BuildContext context, Appointment appointment) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
      child: ListTile(
        leading: Icon(Icons.attach_money, color: theme.colorScheme.tertiary, size: 32),
        title: const Text('Custo'),
        subtitle: Text(
          appointment.formattedCost,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.tertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataCard(BuildContext context, Appointment appointment) {
    final theme = Theme.of(context);
    final createdDate = DateFormat('dd/MM/yyyy HH:mm').format(appointment.createdAt);
    final updatedDate = DateFormat('dd/MM/yyyy HH:mm').format(appointment.updatedAt);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Registro',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Criado em: $createdDate',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Atualizado em: $updatedDate',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editAppointment(
    BuildContext context,
    WidgetRef ref,
    Appointment appointment,
  ) {
    // Navega para o form de edição
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => AddAppointmentForm(
          initialAppointment: appointment,
          isEditing: true,
        ),
        fullscreenDialog: true,
      ),
    ).then((_) {
      // Recarrega appointments após edição
      ref.read(appointmentsProvider.notifier).loadAppointments();
    });
  }

  void _deleteAppointment(
    BuildContext context,
    WidgetRef ref,
    Appointment appointment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Consulta'),
        content: const Text(
          'Tem certeza que deseja excluir esta consulta? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(appointmentsProvider.notifier).deleteAppointment(appointment.id);
      
      if (context.mounted) {
        // Volta para a lista
        context.pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consulta excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
