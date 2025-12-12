import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/ui_constants.dart';
import '../../features/vehicles/domain/entities/vehicle_entity.dart';
import '../../features/vehicles/presentation/providers/vehicles_notifier.dart';
import 'vehicle_selector/vehicle_selector_dropdown.dart';
import 'vehicle_selector/vehicle_selector_empty.dart';
import 'vehicle_selector/vehicle_selector_loading.dart';

/// Seletor de veículos aprimorado com dropdown, persistência e melhorias visuais
class EnhancedVehicleSelector extends ConsumerStatefulWidget {
  const EnhancedVehicleSelector({
    super.key,
    required this.selectedVehicleId,
    required this.onVehicleChanged,
    this.hintText = 'Selecione um veículo',
    this.enabled = true,
  });

  final String? selectedVehicleId;
  final void Function(String?) onVehicleChanged;
  final String? hintText;
  final bool enabled;

  @override
  ConsumerState<EnhancedVehicleSelector> createState() =>
      _EnhancedVehicleSelectorState();
}

class _EnhancedVehicleSelectorState
    extends ConsumerState<EnhancedVehicleSelector>
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
    _animationController = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _loadSelectedVehicle();
    _animationController.forward();
  }

  /// Carrega o veículo selecionado do SharedPreferences
  Future<void> _loadSelectedVehicle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVehicleId = prefs.getString(_selectedVehicleKey);

      if (mounted) {
        final vehiclesAsync = ref.read(vehiclesProvider);
        final vehicles = await vehiclesAsync.when<Future<List<VehicleEntity>>>(
          data: (data) async => data,
          loading: () async {
            debugPrint('⏳ Aguardando carregamento de veículos...');
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return ref.read(vehiclesProvider).value ?? [];
          },
          error: (_, __) async => <VehicleEntity>[],
        );
        if (savedVehicleId != null) {
          final vehicleExists = vehicles.any((v) => v.id == savedVehicleId);

          if (vehicleExists) {
            setState(() {
              _currentSelectedVehicleId = savedVehicleId;
            });
            widget.onVehicleChanged(savedVehicleId);
            return;
          } else {
            await prefs.remove(_selectedVehicleKey);
            debugPrint(
              '🗑️ Veículo removido das preferências: $savedVehicleId',
            );
          }
        }
        if (_currentSelectedVehicleId == null && vehicles.isNotEmpty) {
          final vehicleToSelect = _selectBestVehicle(vehicles);
          if (vehicleToSelect != null) {
            setState(() {
              _currentSelectedVehicleId = vehicleToSelect.id;
            });
            widget.onVehicleChanged(vehicleToSelect.id);
            await _saveSelectedVehicle(vehicleToSelect.id);
            debugPrint(
              '🎯 Auto-seleção realizada: ${vehicleToSelect.brand} ${vehicleToSelect.model} (${vehicleToSelect.id})',
            );
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
    final activeVehicles = vehicles.where((v) => v.isActive).toList();
    final inactiveVehicles = vehicles.where((v) => !v.isActive).toList();
    activeVehicles.sort(
      (a, b) => (b.createdAt ?? DateTime(1900)).compareTo(
        a.createdAt ?? DateTime(1900),
      ),
    );
    inactiveVehicles.sort(
      (a, b) => (b.createdAt ?? DateTime(1900)).compareTo(
        a.createdAt ?? DateTime(1900),
      ),
    );
    if (activeVehicles.isNotEmpty) {
      return activeVehicles.first;
    } else if (inactiveVehicles.isNotEmpty) {
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
      } else {
        await prefs.remove(_selectedVehicleKey);
      }
    } catch (e) {
      debugPrint('❌ Erro ao salvar veículo selecionado: $e');
    }
  }

  void _onVehicleSelected(String? vehicleId) {
    HapticFeedback.selectionClick();
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
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return vehiclesAsync.when(
      data: (vehicles) {
        if (vehicles.isEmpty) {
          return _buildEmptyState(context);
        }
        if (vehicles.isNotEmpty && _currentSelectedVehicleId == null) {
          final vehicleToSelect = _selectBestVehicle(vehicles);
          if (vehicleToSelect != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _onVehicleSelected(vehicleToSelect.id);
              }
            });
          }
        }

        return _buildDropdown(context, vehicles);
      },
      loading: () => _buildLoadingState(context),
      error: (error, _) => _buildEmptyState(context),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const VehicleSelectorLoading();
  }

  Widget _buildEmptyState(BuildContext context) {
    return VehicleSelectorEmpty(
      hintText: widget.hintText,
      scaleAnimation: _scaleAnimation,
      fadeAnimation: _fadeAnimation,
    );
  }

  Widget _buildDropdown(BuildContext context, List<VehicleEntity> vehicles) {
    return VehicleSelectorDropdown(
      vehicles: vehicles,
      currentSelectedVehicleId: _currentSelectedVehicleId,
      hintText: widget.hintText,
      enabled: widget.enabled,
      fadeAnimation: _fadeAnimation,
      isExpanded: _isExpanded,
      onVehicleSelected: _onVehicleSelected,
      onDropdownTap: _onDropdownTap,
    );
  }
}
