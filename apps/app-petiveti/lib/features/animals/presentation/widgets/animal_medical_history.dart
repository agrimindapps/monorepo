import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../vaccines/domain/entities/vaccine.dart';
import '../../../vaccines/presentation/providers/vaccines_provider.dart';
import '../../../medications/domain/entities/medication.dart';
import '../../../medications/presentation/providers/medications_provider.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/presentation/providers/appointments_providers.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../domain/entities/animal.dart';

/// Widget que exibe o histórico médico consolidado de um animal
/// Agrupa vacinas, medicamentos, consultas e despesas em uma timeline
class AnimalMedicalHistoryWidget extends ConsumerWidget {
  final Animal animal;

  const AnimalMedicalHistoryWidget({
    super.key,
    required this.animal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaccinesState = ref.watch(vaccinesProvider);
    final medicationsState = ref.watch(medicationsProvider);
    final appointmentsState = ref.watch(appointmentsProvider);
    final expensesState = ref.watch(expensesProvider);

    // Filtrar por animal
    final vaccines = vaccinesState.vaccines
        .where((v) => v.animalId == animal.id)
        .toList();
    final medications = medicationsState.medications
        .where((m) => m.animalId == animal.id)
        .toList();
    final appointments = appointmentsState.appointments
        .where((Appointment a) => a.animalId == animal.id)
        .toList();
    final expenses = expensesState.expenses
        .where((e) => e.animalId == animal.id)
        .toList();

    // Criar lista unificada de eventos
    final events = _buildEventsList(
      vaccines: vaccines,
      medications: medications,
      appointments: appointments,
      expenses: expenses,
    );

    // Ordenar por data (mais recente primeiro)
    events.sort((a, b) => b.date.compareTo(a.date));

    if (events.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, events.length),
        const SizedBox(height: 16),
        _buildSummaryCards(
          context,
          vaccinesCount: vaccines.length,
          medicationsCount: medications.length,
          appointmentsCount: appointments.length,
          totalExpenses: expenses.fold<double>(0.0, (double total, e) => total + e.amount),
        ),
        const SizedBox(height: 24),
        _buildTimeline(context, events),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, int eventCount) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.history,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Histórico Médico',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '$eventCount registros',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(
    BuildContext context, {
    required int vaccinesCount,
    required int medicationsCount,
    required int appointmentsCount,
    required double totalExpenses,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SummaryCard(
            icon: Icons.vaccines,
            label: 'Vacinas',
            value: vaccinesCount.toString(),
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            icon: Icons.medication,
            label: 'Medicamentos',
            value: medicationsCount.toString(),
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            icon: Icons.calendar_today,
            label: 'Consultas',
            value: appointmentsCount.toString(),
            color: Colors.purple,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            icon: Icons.attach_money,
            label: 'Gastos',
            value: 'R\$ ${totalExpenses.toStringAsFixed(0)}',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, List<_MedicalEvent> events) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isLast = index == events.length - 1;

        return _TimelineItem(
          event: event,
          isLast: isLast,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum registro médico',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione vacinas, medicamentos ou consultas\npara começar o histórico',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  List<_MedicalEvent> _buildEventsList({
    required List<Vaccine> vaccines,
    required List<Medication> medications,
    required List<Appointment> appointments,
    required List<Expense> expenses,
  }) {
    final events = <_MedicalEvent>[];

    // Adicionar vacinas
    for (final vaccine in vaccines) {
      events.add(_MedicalEvent(
        type: _EventType.vaccine,
        title: vaccine.name,
        subtitle: 'Veterinário: ${vaccine.veterinarian}',
        date: vaccine.date,
        icon: Icons.vaccines,
        color: Colors.green,
        status: vaccine.status.name,
      ));
    }

    // Adicionar medicamentos
    for (final medication in medications) {
      events.add(_MedicalEvent(
        type: _EventType.medication,
        title: medication.name,
        subtitle: '${medication.dosage} - ${medication.frequency}',
        date: medication.startDate,
        icon: Icons.medication,
        color: Colors.blue,
        status: medication.isActive ? 'Ativo' : 'Finalizado',
      ));
    }

    // Adicionar consultas
    for (final appointment in appointments) {
      events.add(_MedicalEvent(
        type: _EventType.appointment,
        title: appointment.reason,
        subtitle: 'Dr. ${appointment.veterinarianName}',
        date: appointment.date,
        icon: Icons.calendar_today,
        color: Colors.purple,
        status: appointment.displayStatus,
      ));
    }

    // Adicionar despesas médicas
    for (final expense in expenses) {
      if (expense.category == ExpenseCategory.consultation ||
          expense.category == ExpenseCategory.medication ||
          expense.category == ExpenseCategory.exam ||
          expense.category == ExpenseCategory.vaccine ||
          expense.category == ExpenseCategory.surgery) {
        events.add(_MedicalEvent(
          type: _EventType.expense,
          title: expense.description,
          subtitle: 'R\$ ${expense.amount.toStringAsFixed(2)}',
          date: expense.expenseDate,
          icon: Icons.receipt_long,
          color: Colors.orange,
          status: expense.isPaid ? 'Pago' : 'Pendente',
        ));
      }
    }

    return events;
  }
}

/// Card de resumo
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// Item da timeline
class _TimelineItem extends StatelessWidget {
  final _MedicalEvent event;
  final bool isLast;

  const _TimelineItem({
    required this.event,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: event.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: event.color,
                    width: 2,
                  ),
                ),
                child: Icon(
                  event.icon,
                  color: event.color,
                  size: 20,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: event.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            event.status,
                            style: TextStyle(
                              fontSize: 11,
                              color: event.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(event.date),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'semana' : 'semanas'} atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'mês' : 'meses'} atrás';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'ano' : 'anos'} atrás';
    }
  }
}

/// Tipos de eventos
enum _EventType { vaccine, medication, appointment, expense }

/// Modelo de evento médico
class _MedicalEvent {
  final _EventType type;
  final String title;
  final String subtitle;
  final DateTime date;
  final IconData icon;
  final Color color;
  final String status;

  _MedicalEvent({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
    required this.status,
  });
}
