import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/plant_form_provider.dart';
import '../../../../core/theme/colors.dart';

class PlantFormCareConfig extends StatefulWidget {
  const PlantFormCareConfig({super.key});

  @override
  State<PlantFormCareConfig> createState() => _PlantFormCareConfigState();
}

class _PlantFormCareConfigState extends State<PlantFormCareConfig> {
  final List<String> _intervalOptions = [
    '1 dia',
    '2 dias', 
    '3 dias',
    '1 semana',
    '2 semanas',
    '1 mês',
    '2 meses',
    '3 meses',
    '6 meses',
    '1 ano'
  ];

  int _getIntervalDays(String interval) {
    switch (interval) {
      case '1 dia': return 1;
      case '2 dias': return 2;
      case '3 dias': return 3;
      case '1 semana': return 7;
      case '2 semanas': return 14;
      case '1 mês': return 30;
      case '2 meses': return 60;
      case '3 meses': return 90;
      case '6 meses': return 180;
      case '1 ano': return 365;
      default: return 7;
    }
  }

  String _getIntervalText(int? days) {
    if (days == null) return _intervalOptions[3]; // Default: 1 semana
    switch (days) {
      case 1: return '1 dia';
      case 2: return '2 dias';
      case 3: return '3 dias';
      case 7: return '1 semana';
      case 14: return '2 semanas';
      case 30: return '1 mês';
      case 60: return '2 meses';
      case 90: return '3 meses';
      case 180: return '6 meses';
      case 365: return '1 ano';
      default: return '1 semana';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantFormProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Sunlight Care Section
            _buildCareSection(
              title: 'Luz solar',
              icon: Icons.wb_sunny,
              iconColor: Colors.orange,
              isEnabled: provider.enableSunlightCare ?? false,
              onToggle: (value) => provider.setEnableSunlightCare(value),
              interval: _getIntervalText(provider.sunlightIntervalDays),
              onIntervalChanged: (interval) {
                provider.setSunlightInterval(_getIntervalDays(interval));
              },
              lastDate: provider.lastSunlightDate,
              onDateChanged: (date) => provider.setLastSunlightDate(date),
            ),
            
            const SizedBox(height: 20),
            
            // Pest Inspection Section
            _buildCareSection(
              title: 'Verificação de pragas',
              icon: Icons.bug_report,
              iconColor: Colors.red,
              isEnabled: provider.enablePestInspection ?? false,
              onToggle: (value) => provider.setEnablePestInspection(value),
              interval: _getIntervalText(provider.pestInspectionIntervalDays),
              onIntervalChanged: (interval) {
                provider.setPestInspectionInterval(_getIntervalDays(interval));
              },
              lastDate: provider.lastPestInspectionDate,
              onDateChanged: (date) => provider.setLastPestInspectionDate(date),
            ),
            
            const SizedBox(height: 20),
            
            // Pruning Section
            _buildCareSection(
              title: 'Poda',
              icon: Icons.content_cut,
              iconColor: Colors.brown,
              isEnabled: provider.enablePruning ?? false,
              onToggle: (value) => provider.setEnablePruning(value),
              interval: _getIntervalText(provider.pruningIntervalDays),
              onIntervalChanged: (interval) {
                provider.setPruningInterval(_getIntervalDays(interval));
              },
              lastDate: provider.lastPruningDate,
              onDateChanged: (date) => provider.setLastPruningDate(date),
            ),
            
            const SizedBox(height: 20),
            
            // Replanting Section
            _buildCareSection(
              title: 'Replantio',
              icon: Icons.grass,
              iconColor: PlantisColors.primary,
              isEnabled: provider.enableReplanting ?? false,
              onToggle: (value) => provider.setEnableReplanting(value),
              interval: _getIntervalText(provider.replantingIntervalDays),
              onIntervalChanged: (interval) {
                provider.setReplantingInterval(_getIntervalDays(interval));
              },
              lastDate: provider.lastReplantingDate,
              onDateChanged: (date) => provider.setLastReplantingDate(date),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCareSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
    required String interval,
    required ValueChanged<String> onIntervalChanged,
    required DateTime? lastDate,
    required ValueChanged<DateTime?> onDateChanged,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled ? iconColor.withValues(alpha: 0.3) : Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with toggle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeColor: iconColor,
                activeTrackColor: iconColor.withValues(alpha: 0.3),
              ),
            ],
          ),
          
          // Configuration options (only visible when enabled)
          if (isEnabled) ...[
            const SizedBox(height: 16),
            
            // Interval selector
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Intervalo',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: interval,
                            items: _intervalOptions.map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                onIntervalChanged(value);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Last date selector
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Última vez',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context, lastDate, onDateChanged),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lastDate != null
                                    ? DateFormat('dd/MM/yyyy').format(lastDate)
                                    : 'Selecionar',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: lastDate != null 
                                      ? theme.colorScheme.onSurface
                                      : Colors.grey[600],
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, 
    DateTime? currentDate, 
    ValueChanged<DateTime?> onChanged
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: PlantisColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (selectedDate != null) {
      onChanged(selectedDate);
    }
  }
}