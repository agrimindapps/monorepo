import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/ui_constants.dart';
import '../../features/vehicles/domain/entities/vehicle_entity.dart';
import '../../features/vehicles/presentation/providers/vehicles_provider.dart';

/// Seletor de veículos aprimorado com dropdown e persistência
class EnhancedVehicleSelector extends StatefulWidget {
  final String? selectedVehicleId;
  final void Function(String?) onVehicleChanged;
  final String? hintText;
  final bool enabled;

  const EnhancedVehicleSelector({
    super.key,
    required this.selectedVehicleId,
    required this.onVehicleChanged,
    this.hintText = 'Selecione um veículo',
    this.enabled = true,
  });

  @override
  State<EnhancedVehicleSelector> createState() => _EnhancedVehicleSelectorState();
}

class _EnhancedVehicleSelectorState extends State<EnhancedVehicleSelector> {
  static const String _selectedVehicleKey = 'selected_vehicle_id';
  String? _currentSelectedVehicleId;

  @override
  void initState() {
    super.initState();
    _currentSelectedVehicleId = widget.selectedVehicleId;
    _loadSelectedVehicle();
  }

  /// Carrega o veículo selecionado do SharedPreferences
  Future<void> _loadSelectedVehicle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVehicleId = prefs.getString(_selectedVehicleKey);
      debugPrint('🚗 Carregando veículo salvo: $savedVehicleId');
      
      if (savedVehicleId != null && mounted) {
        final vehiclesProvider = Provider.of<VehiclesProvider>(context, listen: false);
        
        // Aguarda a inicialização do provider se necessário
        if (!vehiclesProvider.isInitialized) {
          debugPrint('⏳ Provider não inicializado, aguardando...');
          await vehiclesProvider.initialize();
        }
        
        // Verifica se o veículo ainda exists
        final vehicleExists = vehiclesProvider.vehicles.any((v) => v.id == savedVehicleId);
        debugPrint('🚗 Veículo existe na lista: $vehicleExists (${vehiclesProvider.vehicles.length} veículos)');
        
        if (vehicleExists) {
          setState(() {
            _currentSelectedVehicleId = savedVehicleId;
          });
          widget.onVehicleChanged(savedVehicleId);
          debugPrint('✅ Veículo restaurado com sucesso: $savedVehicleId');
        } else {
          // Remove a preferência se o veículo não existe mais
          await prefs.remove(_selectedVehicleKey);
          debugPrint('🗑️ Veículo removido das preferências: $savedVehicleId');
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar veículo selecionado: $e');
    }
  }

  /// Salva o veículo selecionado no SharedPreferences
  Future<void> _saveSelectedVehicle(String? vehicleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (vehicleId != null) {
        await prefs.setString(_selectedVehicleKey, vehicleId);
        debugPrint('💾 Veículo salvo: $vehicleId');
      } else {
        await prefs.remove(_selectedVehicleKey);
        debugPrint('🗑️ Preferência de veículo removida');
      }
    } catch (e) {
      debugPrint('❌ Erro ao salvar veículo selecionado: $e');
    }
  }

  void _onVehicleSelected(String? vehicleId) {
    setState(() {
      _currentSelectedVehicleId = vehicleId;
    });
    widget.onVehicleChanged(vehicleId);
    _saveSelectedVehicle(vehicleId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VehiclesProvider>(
      builder: (context, vehiclesProvider, _) {
        debugPrint('🔄 VehicleSelector rebuild - isLoading: ${vehiclesProvider.isLoading}, isInitialized: ${vehiclesProvider.isInitialized}, vehicles: ${vehiclesProvider.vehicles.length}');
        
        if (vehiclesProvider.isLoading) {
          return _buildLoadingState(context);
        }

        if (!vehiclesProvider.isInitialized && vehiclesProvider.vehicles.isEmpty) {
          // Provider ainda não foi inicializado, força a inicialização
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              vehiclesProvider.initialize();
            }
          });
          return _buildLoadingState(context);
        }

        if (vehiclesProvider.vehicles.isEmpty) {
          return _buildEmptyState(context);
        }

        // Se há apenas um veículo, seleciona automaticamente
        if (vehiclesProvider.vehicles.length == 1 && _currentSelectedVehicleId == null) {
          final singleVehicle = vehiclesProvider.vehicles.first;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _onVehicleSelected(singleVehicle.id);
          });
        }

        return _buildDropdown(context, vehiclesProvider);
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large, vertical: AppSpacing.xlarge),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(AppRadius.large),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.iconXS,
            height: AppSizes.iconXS,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Text(
            'Carregando veículos...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppOpacity.medium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large, vertical: AppSpacing.xlarge),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(AppRadius.large),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: [
          Icon(
            Icons.directions_car_outlined,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            size: AppSizes.iconS,
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Text(
              'Nenhum veículo cadastrado',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppOpacity.medium),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, VehiclesProvider vehiclesProvider) {
    final selectedVehicle = _currentSelectedVehicleId != null
        ? vehiclesProvider.vehicles.firstWhere(
            (v) => v.id == _currentSelectedVehicleId,
            orElse: () => vehiclesProvider.vehicles.first,
          )
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(AppRadius.large),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: DropdownButtonFormField<String>(
        value: _currentSelectedVehicleId,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.large, vertical: AppSpacing.large),
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            Icons.directions_car,
            color: selectedVehicle != null 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: AppOpacity.subtle),
          ),
        ),
        items: vehiclesProvider.vehicles.map<DropdownMenuItem<String>>((VehicleEntity vehicle) {
          return DropdownMenuItem<String>(
            value: vehicle.id,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${vehicle.brand} ${vehicle.model}',
                        style: const TextStyle(
                          fontWeight: AppFontWeights.medium,
                          fontSize: AppFontSizes.medium,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacingXS),
                      Text(
                        'Placa: ${vehicle.licensePlate} • ${vehicle.currentOdometer.toStringAsFixed(0)} km',
                        style: TextStyle(
                          fontSize: AppFontSizes.small,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppOpacity.medium),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: widget.enabled ? _onVehicleSelected : null,
        isExpanded: true,
        icon: Icon(
          Icons.arrow_drop_down,
          color: widget.enabled 
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: AppOpacity.prominent)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: AppOpacity.disabled),
        ),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: AppFontSizes.medium,
        ),
        dropdownColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

}