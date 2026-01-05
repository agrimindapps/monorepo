import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/timeline_item.dart';

/// Widget para exibir um item individual na timeline
class TimelineItemCard extends StatelessWidget {
  const TimelineItemCard({
    required this.item,
    required this.isFirst,
    required this.isLast,
    this.onTap,
    super.key,
  });

  final TimelineItem item;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = item.getTypeColor(context);
    final dateFormat = DateFormat('HH:mm');
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline connector
              _buildTimelineConnector(context, accentColor),
              
              const SizedBox(width: 16),
              
              // Content card
              Expanded(
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: accentColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Type badge + Time
                        Row(
                          children: [
                            // Type badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 12,
                                    color: accentColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.typeLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Time
                            Text(
                              dateFormat.format(item.date),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Title
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Conteúdo específico por tipo
                        _buildTypeSpecificContent(context, accentColor),
                        
                        // Animal name (if showing all animals)
                        if (item.animalName != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.pets,
                                size: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.animalName!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSpecificContent(BuildContext context, Color accentColor) {
    switch (item.type) {
      case TimelineEventType.vaccine:
        return _buildVaccineContent(context);
      case TimelineEventType.medication:
        return _buildMedicationContent(context);
      case TimelineEventType.appointment:
        return _buildAppointmentContent(context);
      case TimelineEventType.weight:
        return _buildWeightContent(context);
      case TimelineEventType.expense:
        return _buildExpenseContent(context);
    }
  }

  Widget _buildVaccineContent(BuildContext context) {
    final items = <Widget>[];
    
    if (item.veterinarian != null && item.veterinarian!.isNotEmpty) {
      items.add(_buildInfoRow(context, Icons.person, 'Vet: ${item.veterinarian}'));
    }
    if (item.dosage != null && item.dosage!.isNotEmpty) {
      items.add(_buildInfoRow(context, Icons.local_pharmacy, 'Dose: ${item.dosage}'));
    }
    if (item.batch != null && item.batch!.isNotEmpty) {
      items.add(_buildInfoRow(context, Icons.inventory, 'Lote: ${item.batch}'));
    }
    if (item.nextDueDate != null) {
      final nextDate = DateFormat('dd/MM/yyyy').format(item.nextDueDate!);
      items.add(_buildInfoRow(context, Icons.event, 'Próxima: $nextDate', highlight: true));
    }
    
    if (items.isEmpty && item.notes != null) {
      items.add(_buildInfoRow(context, Icons.notes, item.notes!));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.isEmpty 
          ? [_buildInfoRow(context, Icons.check_circle, 'Vacina aplicada')]
          : items,
    );
  }

  Widget _buildMedicationContent(BuildContext context) {
    final items = <Widget>[];
    
    if (item.dosage != null && item.dosage!.isNotEmpty) {
      items.add(_buildInfoRow(context, Icons.medication_liquid, 'Dosagem: ${item.dosage}'));
    }
    if (item.frequency != null && item.frequency!.isNotEmpty) {
      items.add(_buildInfoRow(context, Icons.schedule, 'Frequência: ${item.frequency}'));
    }
    if (item.duration != null && item.duration!.isNotEmpty) {
      items.add(_buildInfoRow(context, Icons.timelapse, 'Duração: ${item.duration}'));
    }
    if (item.isActive == true) {
      items.add(_buildInfoRow(context, Icons.play_circle, 'Em andamento', highlight: true));
    } else if (item.endDate != null) {
      final endDate = DateFormat('dd/MM/yyyy').format(item.endDate!);
      items.add(_buildInfoRow(context, Icons.stop_circle, 'Finalizado em: $endDate'));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.isEmpty 
          ? [_buildInfoRow(context, Icons.medication, 'Medicamento registrado')]
          : items,
    );
  }

  Widget _buildAppointmentContent(BuildContext context) {
    final items = <Widget>[];
    
    if (item.description != null && item.description!.isNotEmpty) {
      items.add(_buildInfoRow(context, Icons.description, item.description!));
    }
    if (item.location != null && item.location!.isNotEmpty) {
      items.add(_buildInfoRow(context, Icons.location_on, item.location!));
    }
    if (item.status != null && item.status!.isNotEmpty) {
      final statusIcon = _getStatusIcon(item.status!);
      final statusLabel = _getStatusLabel(item.status!);
      items.add(_buildInfoRow(context, statusIcon, statusLabel, highlight: item.status == 'scheduled'));
    }
    if (item.cost != null && item.cost! > 0) {
      items.add(_buildInfoRow(context, Icons.attach_money, 'R\$ ${item.cost!.toStringAsFixed(2)}'));
    }
    if (item.notes != null && item.notes!.isNotEmpty) {
      items.add(_buildInfoRow(context, Icons.medical_information, 'Diagnóstico: ${item.notes}'));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.isEmpty 
          ? [_buildInfoRow(context, Icons.calendar_today, 'Consulta agendada')]
          : items,
    );
  }

  Widget _buildWeightContent(BuildContext context) {
    final items = <Widget>[];
    
    if (item.weight != null) {
      final unit = item.weightUnit ?? 'kg';
      items.add(_buildInfoRow(
        context, 
        Icons.monitor_weight, 
        '${item.weight!.toStringAsFixed(2)} $unit',
        large: true,
      ));
    }
    if (item.bodyConditionScore != null) {
      final score = item.bodyConditionScore!;
      final label = _getBodyConditionLabel(score);
      items.add(_buildInfoRow(context, Icons.fitness_center, 'Condição corporal: $score/9 ($label)'));
    }
    if (item.notes != null && item.notes!.isNotEmpty) {
      items.add(_buildInfoRow(context, Icons.notes, item.notes!));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  Widget _buildExpenseContent(BuildContext context) {
    final items = <Widget>[];
    
    if (item.amount != null) {
      items.add(_buildInfoRow(
        context, 
        Icons.attach_money, 
        'R\$ ${item.amount!.toStringAsFixed(2)}',
        large: true,
      ));
    }
    if (item.category != null && item.category!.isNotEmpty) {
      items.add(_buildInfoRow(context, Icons.category, _getCategoryLabel(item.category!)));
    }
    if (item.paymentMethod != null && item.paymentMethod!.isNotEmpty) {
      items.add(_buildInfoRow(context, Icons.payment, item.paymentMethod!));
    }
    if (item.isPaid == false) {
      items.add(_buildInfoRow(context, Icons.warning, 'Pendente', highlight: true));
    }
    if (item.description != null && item.description!.isNotEmpty) {
      items.add(_buildInfoRow(context, Icons.description, item.description!));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text, {bool highlight = false, bool large = false}) {
    final color = highlight 
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: large ? 16 : 12, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: highlight || large ? FontWeight.w600 : FontWeight.normal,
                fontSize: large ? 14 : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'inprogress':
        return Icons.play_circle;
      default:
        return Icons.help;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Agendada';
      case 'completed':
        return 'Concluída';
      case 'cancelled':
        return 'Cancelada';
      case 'inprogress':
        return 'Em andamento';
      default:
        return status;
    }
  }

  String _getBodyConditionLabel(int score) {
    if (score <= 3) return 'Abaixo do peso';
    if (score <= 5) return 'Ideal';
    if (score <= 7) return 'Acima do peso';
    return 'Obeso';
  }

  String _getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'consultation':
        return 'Consulta';
      case 'medication':
        return 'Medicamento';
      case 'vaccine':
        return 'Vacina';
      case 'surgery':
        return 'Cirurgia';
      case 'food':
        return 'Alimentação';
      case 'accessories':
        return 'Acessórios';
      case 'grooming':
        return 'Banho/Tosa';
      case 'emergency':
        return 'Emergência';
      case 'exam':
        return 'Exame';
      case 'other':
        return 'Outros';
      default:
        return category;
    }
  }

  Widget _buildTimelineConnector(BuildContext context, Color accentColor) {
    return SizedBox(
      width: 24,
      child: Column(
        children: [
          // Top line
          if (!isFirst)
            Expanded(
              child: Container(
                width: 2,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            )
          else
            const Spacer(),
          
          // Dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          
          // Bottom line
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }
}
