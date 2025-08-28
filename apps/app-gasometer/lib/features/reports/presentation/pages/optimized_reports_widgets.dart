import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/standard_loading_view.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../providers/reports_provider.dart';

/// ✅ PERFORMANCE FIX: Single Consumer with optimized sections
class OptimizedReportsContent extends StatelessWidget {
  final String? selectedVehicleId;
  final void Function(String?) onVehicleChanged;

  const OptimizedReportsContent({
    super.key,
    required this.selectedVehicleId,
    required this.onVehicleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportsProvider>(
      builder: (context, reportsProvider, child) {
        return Column(
          children: [
            EnhancedVehicleSelector(
              selectedVehicleId: selectedVehicleId,
              onVehicleChanged: (String? vehicleId) {
                onVehicleChanged(vehicleId);
                
                // Load new reports data when vehicle changes
                if (vehicleId != null) {
                  reportsProvider.loadAllReportsForVehicle(vehicleId);
                }
              },
            ),
            const SizedBox(height: 24),
            
            if (reportsProvider.isLoading)
              StandardLoadingView.initial(
                message: 'Carregando estatísticas...',
                height: 400,
              )
            else if (reportsProvider.hasError)
              _buildErrorState(
                context,
                reportsProvider.errorMessage!,
                () => reportsProvider.loadAllReportsForVehicle(selectedVehicleId!),
              )
            else ...[
              OptimizedFuelSection(provider: reportsProvider),
              const SizedBox(height: 24),
              OptimizedConsumptionSection(provider: reportsProvider),
              const SizedBox(height: 24),
              OptimizedDistanceSection(provider: reportsProvider),
            ],
          ],
        );
      },
    );
  }
  
  Widget _buildErrorState(BuildContext context, String message, VoidCallback onRetry) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                'Erro ao carregar dados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ PERFORMANCE FIX: Optimized fuel section without Consumer
class OptimizedFuelSection extends StatelessWidget {
  final ReportsProvider provider;
  
  const OptimizedFuelSection({super.key, required this.provider});
  
  @override
  Widget build(BuildContext context) {
    final currentMonthStats = provider.getCurrentMonthStats();
    final currentYearStats = provider.getCurrentYearStats();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_gas_station, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Combustível',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Este Mês',
                  value: currentMonthStats['fuel_spent'] ?? 'R\$ 0,00',
                  subtitle: currentMonthStats['fuel_liters'] ?? '0,0L',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Este Ano',
                  value: currentYearStats['fuel_spent'] ?? 'R\$ 0,00',
                  subtitle: currentYearStats['fuel_liters'] ?? '0,0L',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ✅ PERFORMANCE FIX: Optimized consumption section without Consumer
class OptimizedConsumptionSection extends StatelessWidget {
  final ReportsProvider provider;
  
  const OptimizedConsumptionSection({super.key, required this.provider});
  
  @override
  Widget build(BuildContext context) {
    final currentMonthStats = provider.getCurrentMonthStats();
    final currentYearStats = provider.getCurrentYearStats();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Consumo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Média Mensal',
                  value: currentMonthStats['consumption'] ?? '0,0 km/L',
                  subtitle: 'Este mês',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Média Anual',
                  value: currentYearStats['consumption'] ?? '0,0 km/L',
                  subtitle: 'Este ano',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ✅ PERFORMANCE FIX: Optimized distance section without Consumer
class OptimizedDistanceSection extends StatelessWidget {
  final ReportsProvider provider;
  
  const OptimizedDistanceSection({super.key, required this.provider});
  
  @override
  Widget build(BuildContext context) {
    final currentMonthStats = provider.getCurrentMonthStats();
    final currentYearStats = provider.getCurrentYearStats();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.straighten, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Distância',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Este Mês',
                  value: currentMonthStats['distance'] ?? '0 km',
                  subtitle: 'Distância percorrida',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Este Ano',
                  value: currentYearStats['distance'] ?? '0 km',
                  subtitle: 'Distância percorrida',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helper widget for statistics cards
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}