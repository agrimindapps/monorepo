import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/ui_constants.dart';
import '../../features/vehicles/domain/entities/vehicle_entity.dart';
import '../../features/vehicles/presentation/providers/vehicles_provider.dart';

/// Seletor de veículos aprimorado com dropdown, persistência e melhorias visuais
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
  State<EnhancedVehicleSelector> createState() =>
      _EnhancedVehicleSelectorState();
}

class _EnhancedVehicleSelectorState extends State<EnhancedVehicleSelector>
    with TickerProviderStateMixin {
  static const String _selectedVehicleKey = 'selected_vehicle_id';
  String? _currentSelectedVehicleId;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentSelectedVehicleId = widget.selectedVehicleId;

    // Initialize animations
    _animationController = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _loadSelectedVehicle();
    _animationController.forward();
  }

  /// Carrega o veículo selecionado do SharedPreferences
  Future<void> _loadSelectedVehicle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVehicleId = prefs.getString(_selectedVehicleKey);
      // Removed verbose vehicle loading log

      if (mounted) {
        final vehiclesProvider =
            Provider.of<VehiclesProvider>(context, listen: false);

        // Aguarda a inicialização do provider se necessário
        if (!vehiclesProvider.isInitialized) {
          debugPrint('⏳ Provider não inicializado, aguardando...');
          await vehiclesProvider.initialize();
        }

        // Se há um veículo salvo, verifica se ele ainda existe
        if (savedVehicleId != null) {
          final vehicleExists =
              vehiclesProvider.vehicles.any((v) => v.id == savedVehicleId);
          // Removed verbose vehicle existence log

          if (vehicleExists) {
            setState(() {
              _currentSelectedVehicleId = savedVehicleId;
            });
            widget.onVehicleChanged(savedVehicleId);
            // Removed verbose vehicle restoration log
            return; // Sai da função se encontrou o veículo salvo
          } else {
            // Remove a preferência se o veículo não existe mais
            await prefs.remove(_selectedVehicleKey);
            debugPrint(
                '🗑️ Veículo removido das preferências: $savedVehicleId');
          }
        }

        // Auto-seleção: se não há veículo selecionado mas há veículos disponíveis
        if (_currentSelectedVehicleId == null &&
            vehiclesProvider.vehicles.isNotEmpty) {
          final vehicleToSelect = _selectBestVehicle(vehiclesProvider.vehicles);
          if (vehicleToSelect != null) {
            setState(() {
              _currentSelectedVehicleId = vehicleToSelect.id;
            });
            widget.onVehicleChanged(vehicleToSelect.id);
            await _saveSelectedVehicle(vehicleToSelect.id);
            debugPrint(
                '🎯 Auto-seleção realizada: ${vehicleToSelect.brand} ${vehicleToSelect.model} (${vehicleToSelect.id})');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar veículo selecionado: $e');
    }
  }

  /// Seleciona o melhor veículo disponível para auto-seleção
  /// Prioriza veículos ativos e ordena por data de criação (mais recente primeiro)
  VehicleEntity? _selectBestVehicle(List<VehicleEntity> vehicles) {
    if (vehicles.isEmpty) return null;

    // Separa veículos ativos e inativos
    final activeVehicles = vehicles.where((v) => v.isActive).toList();
    final inactiveVehicles = vehicles.where((v) => !v.isActive).toList();

    // Ordena por data de criação (mais recente primeiro)
    activeVehicles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    inactiveVehicles.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Prioriza veículos ativos, senão pega o primeiro inativo
    if (activeVehicles.isNotEmpty) {
      // Removed verbose active vehicle selection log
      return activeVehicles.first;
    } else if (inactiveVehicles.isNotEmpty) {
      // Removed verbose inactive vehicle selection log
      return inactiveVehicles.first;
    }

    return null;
  }

  /// Salva o veículo selecionado no SharedPreferences
  Future<void> _saveSelectedVehicle(String? vehicleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (vehicleId != null) {
        await prefs.setString(_selectedVehicleKey, vehicleId);
        // Removed verbose vehicle save log
      } else {
        await prefs.remove(_selectedVehicleKey);
        // Removed verbose preference removal log
      }
    } catch (e) {
      debugPrint('❌ Erro ao salvar veículo selecionado: $e');
    }
  }

  void _onVehicleSelected(String? vehicleId) {
    // Haptic feedback for better UX
    HapticFeedback.selectionClick();

    // Animate the selection change
    _animationController.reverse().then((_) {
      setState(() {
        _currentSelectedVehicleId = vehicleId;
        _isExpanded = false;
      });
      widget.onVehicleChanged(vehicleId);
      _saveSelectedVehicle(vehicleId);
      _animationController.forward();
    });
  }

  void _onDropdownTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VehiclesProvider>(
      builder: (context, vehiclesProvider, _) {
        // Removed verbose VehicleSelector rebuild log

        if (vehiclesProvider.isLoading) {
          return _buildLoadingState(context);
        }

        if (!vehiclesProvider.isInitialized &&
            vehiclesProvider.vehicles.isEmpty) {
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

        // Auto-seleção quando há veículos disponíveis mas nenhum selecionado
        if (vehiclesProvider.vehicles.isNotEmpty &&
            _currentSelectedVehicleId == null) {
          final vehicleToSelect = _selectBestVehicle(vehiclesProvider.vehicles);
          if (vehicleToSelect != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _onVehicleSelected(vehicleToSelect.id);
            });
          }
        }

        return _buildDropdown(context, vehiclesProvider);
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Semantics(
      label: 'Carregando lista de veículos',
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.large, vertical: AppSpacing.xlarge),
        decoration: BoxDecoration(
          border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(AppRadius.large),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: AppSizes.iconS,
              height: AppSizes.iconS,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(width: AppSpacing.large),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Carregando veículos...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: AppFontWeights.medium,
                      fontSize: AppFontSizes.medium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Preparando sua lista personalizada',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: AppOpacity.medium),
                      fontSize: AppFontSizes.small,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Semantics(
      label: 'Nenhum veículo cadastrado. Adicione um veículo para continuar',
      button: false,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxlarge),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppRadius.large),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.medium),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: Icon(
                Icons.directions_car_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: AppSizes.iconL,
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            Text(
              'Nenhum veículo cadastrado',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppFontWeights.semiBold,
                fontSize: AppFontSizes.large,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'Adicione seu primeiro veículo para começar\na gerenciar combustível e despesas',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: AppOpacity.medium),
                fontSize: AppFontSizes.body,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
      BuildContext context, VehiclesProvider vehiclesProvider) {
    final selectedVehicle = _currentSelectedVehicleId != null
        ? vehiclesProvider.vehicles.firstWhere(
            (v) => v.id == _currentSelectedVehicleId,
            orElse: () => vehiclesProvider.vehicles.first,
          )
        : null;

    return Semantics(
      label: selectedVehicle != null
          ? 'Veículo selecionado: ${selectedVehicle.brand} ${selectedVehicle.model}, ${selectedVehicle.licensePlate}'
          : 'Selecionar veículo',
      button: true,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedVehicle != null
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.5)
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                    width: selectedVehicle != null ? 2.0 : 1.5,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: selectedVehicle != null
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1)
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.05),
                      blurRadius: selectedVehicle != null ? 12 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 64),
                    child: DropdownButtonFormField<String>(
                      value: _currentSelectedVehicleId,
                      isDense: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.medium,
                          vertical: AppSpacing.xxlarge,
                        ),
                        border: InputBorder.none,
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: AppOpacity.medium),
                          fontSize: AppFontSizes.medium,
                          fontWeight: AppFontWeights.regular,
                        ),
                        prefixIcon: Container(
                          margin:
                              const EdgeInsets.only(left: AppSpacing.medium),
                          child: Icon(
                            Icons.directions_car,
                            color: selectedVehicle != null
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: AppOpacity.subtle),
                            size: AppSizes.iconM,
                          ),
                        ),
                      ),
                      selectedItemBuilder: (BuildContext context) {
                        return vehiclesProvider.vehicles
                            .map<Widget>((VehicleEntity vehicle) {
                          final isSelected =
                              vehicle.id == _currentSelectedVehicleId;
                          if (!isSelected) {
                            return Container(
                              alignment: Alignment.centerLeft,
                              child: const SizedBox.shrink(),
                            );
                          }
                          return Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${vehicle.brand} ${vehicle.model}',
                                        style: TextStyle(
                                          fontWeight: AppFontWeights.semiBold,
                                          fontSize: AppFontSizes.large,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.small),
                                            ),
                                            child: Text(
                                              vehicle.licensePlate,
                                              style: TextStyle(
                                                fontSize: AppFontSizes.small,
                                                fontWeight:
                                                    AppFontWeights.medium,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                              width: AppSpacing.small),
                                          Icon(
                                            Icons.speed,
                                            size: AppSizes.iconXS,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(
                                                    alpha: AppOpacity.medium),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${vehicle.currentOdometer.toStringAsFixed(0)} km',
                                            style: TextStyle(
                                              fontSize: AppFontSizes.small,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(
                                                      alpha: AppOpacity.medium),
                                              fontWeight: AppFontWeights.medium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (!vehicle.isActive) ...[
                                  const SizedBox(width: AppSpacing.small),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.small),
                                    ),
                                    child: Icon(
                                      Icons.pause_circle_outline,
                                      size: AppSizes.iconXS,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList();
                      },
                      items: vehiclesProvider.vehicles
                          .map<DropdownMenuItem<String>>(
                              (VehicleEntity vehicle) {
                        final isCurrentlySelected =
                            vehicle.id == _currentSelectedVehicleId;

                        return DropdownMenuItem<String>(
                          value: vehicle.id,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.medium,
                              horizontal: AppSpacing.small,
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.medium),
                              color: isCurrentlySelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.all(AppSpacing.small),
                                  decoration: BoxDecoration(
                                    color: vehicle.isActive
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.1)
                                        : Theme.of(context)
                                            .colorScheme
                                            .error
                                            .withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.medium),
                                  ),
                                  child: Icon(
                                    vehicle.isActive
                                        ? Icons.directions_car
                                        : Icons.directions_car_outlined,
                                    size: AppSizes.iconS,
                                    color: vehicle.isActive
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.medium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${vehicle.brand} ${vehicle.model}',
                                              style: TextStyle(
                                                fontWeight: isCurrentlySelected
                                                    ? AppFontWeights.semiBold
                                                    : AppFontWeights.medium,
                                                fontSize: AppFontSizes.medium,
                                                color: isCurrentlySelected
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          if (!vehicle.isActive)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: AppSpacing.small),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error
                                                    .withValues(alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppRadius.small),
                                              ),
                                              child: Text(
                                                'INATIVO',
                                                style: TextStyle(
                                                  fontSize: AppFontSizes.xs,
                                                  fontWeight:
                                                      AppFontWeights.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.small),
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Text(
                                              vehicle.licensePlate,
                                              style: TextStyle(
                                                fontSize: AppFontSizes.small,
                                                fontWeight:
                                                    AppFontWeights.medium,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                              width: AppSpacing.medium),
                                          Icon(
                                            Icons.speed,
                                            size: AppSizes.iconXS,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(
                                                    alpha: AppOpacity.medium),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${vehicle.currentOdometer.toStringAsFixed(0)} km',
                                            style: TextStyle(
                                              fontSize: AppFontSizes.small,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(
                                                      alpha: AppOpacity.medium),
                                              fontWeight: AppFontWeights.medium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCurrentlySelected)
                                  Icon(
                                    Icons.check_circle,
                                    size: AppSizes.iconS,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: widget.enabled ? _onVehicleSelected : null,
                      onTap: _onDropdownTap,
                      isExpanded: true,
                      icon: AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: AppDurations.fast,
                        child: Icon(
                          Icons.expand_more,
                          color: widget.enabled
                              ? (selectedVehicle != null
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: AppOpacity.prominent))
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: AppOpacity.disabled),
                          size: AppSizes.iconM,
                        ),
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: AppFontSizes.medium,
                      ),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.large),
                      elevation: 8,
                      itemHeight: 80,
                      menuMaxHeight: 400,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
