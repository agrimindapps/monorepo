// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/themes/manager.dart';
import '../../../../database/21_veiculos_model.dart';
import '../../../../widgets/gasometer_header_widget.dart';
import '../../veiculos_cadastro/models/veiculos_constants.dart';
import '../../veiculos_cadastro/widgets/veiculos_cadastro_widget.dart';
import '../controller/veiculos_page_controller.dart';
import '../services/veiculos_formatter_service.dart';
import '../services/veiculos_theme_service.dart';
import '../services/veiculos_ui_state_service.dart';
import '../widgets/loading_states.dart';

// Flutter

// External packages

// Internal dependencies

// Local imports

class VeiculosPageView extends GetView<VeiculosPageController> {
  // Remove const constructor since we need to add state
  const VeiculosPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: ThemeManager().isDark.value
              ? const Color(0xFF1A1A2E)
              : Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                // Header fixo
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: VeiculosConstants.larguraMaxima,
                    ),
                    child: _buildHeader(context),
                  ),
                ),

                // Conteúdo com scroll
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: SizedBox(
                        width: VeiculosConstants.larguraMaxima,
                        child: Padding(
                          padding: EdgeInsets.all(
                              VeiculosConstants.dimensoes['padding']!),
                          child: _buildContent(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(context),
        ));
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        GasometerHeaderWidget(
          title: VeiculosConstants.paginaTitulos['titulo']!,
          subtitle: 'Gerencie seus veículos cadastrados',
          icon: VeiculosConstants.icones['carro']!,
          showBackButton: false,
        ),
        // Loading overlay
        _buildHeaderLoadingOverlay(),
      ],
    );
  }

  Widget _buildHeaderLoadingOverlay() {
    return Obx(() {
      // Check for contextual loading states that affect header
      if (controller.hasContextualLoading) {
        final state = controller.loadingState;

        // Show subtle loading for operations that don't block entire UI
        if (state == LoadingState.syncingWithCloud ||
            state == LoadingState.exportingData) {
          return Positioned(
            top: 8,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: state.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: state.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(state.color),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.userMessage,
                    style: TextStyle(
                      fontSize: 12,
                      color: state.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }

      // Legacy header loading
      if (!controller.headerLoading.value) return const SizedBox.shrink();

      return Positioned.fill(
        child: Container(
          color: Colors.white.withValues(alpha: 0.7),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        // Separate loading state to reduce rebuilds
        _buildContentBody(context),
      ],
    );
  }

  Widget _buildContentBody(BuildContext context) {
    return Obx(() {
      // Check for contextual loading states first
      if (controller.hasContextualLoading) {
        return _buildContextualLoadingState();
      }

      // Fallback to legacy loading state
      if (controller.gridLoading.value) {
        return _buildLoadingState();
      }

      return _buildDataContent(context);
    });
  }

  Widget _buildDataContent(BuildContext context) {
    return Obx(() {
      try {
        if (!Get.isRegistered<VeiculosPageController>()) {
          debugPrint('VeiculosPageView: Controller não registrado');
          return _buildErrorState(context, 'Controller não inicializado');
        }

        final ctrl = Get.find<VeiculosPageController>();

        if (ctrl.hasError) {
          debugPrint(
              'VeiculosPageView: Erro no controller: ${ctrl.errorMessage}');
          return _buildErrorState(context, ctrl.errorMessage);
        }

        if (ctrl.isLoading) {
          return _buildLoadingState();
        }

        final hasData = ctrl.isNotEmpty;
        if (!hasData) {
          return _buildEmptyState(context);
        } else {
          return _buildVehicleGrid(context);
        }
      } catch (e) {
        debugPrint('VeiculosPageView: Erro ao construir dados: $e');
        return _buildErrorState(context, 'Erro ao carregar dados');
      }
    });
  }

  /// Contextual loading state with modern UX
  Widget _buildContextualLoadingState() {
    return Obx(() {
      final state = controller.loadingState;

      // Show skeleton loading for initial vehicle loading
      if (state == LoadingState.loadingVeiculos) {
        return const VeiculosSkeletonLoader(
          itemCount: 6,
          isGridView: true,
        );
      }

      // Show contextual indicator for other operations
      return SizedBox(
        height: 300,
        child: ContextualLoadingIndicator(
          state: state,
          customMessage: controller.loadingMessage.value.isNotEmpty
              ? controller.loadingMessage.value
              : null,
          showProgress: state.isLongRunning,
          progress:
              state.isLongRunning ? controller.loadingProgress.value : null,
          onCancel:
              state.isCancellable ? controller.cancelCurrentOperation : null,
        ),
      );
    });
  }

  /// Legacy loading state for backward compatibility
  Widget _buildLoadingState() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            const Text(
              'Erro ao carregar dados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => controller.loadVeiculos(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height -
            VeiculosConstants.dimensoes['alturaSemDados']!,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(
                  VeiculosConstants.dimensoes['paddingContainerSemDados']!),
              decoration: BoxDecoration(
                color: VeiculosThemeService.getNoDataBackgroundColor(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                VeiculosConstants.icones['carroOutline']!,
                color: Colors.black54,
                size: VeiculosConstants.dimensoes['tamanhoIconeSemDados']!,
              ),
            ),
            SizedBox(height: VeiculosConstants.dimensoes['espacamento']! + 8),
            Text(
              VeiculosConstants.paginaTitulos['semDadosTitulo']!,
              style: TextStyle(
                fontSize: VeiculosConstants.tamanhosFonte['tituloSemDados']!,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: VeiculosConstants.dimensoes['paddingPequeno']!),
            Text(
              VeiculosConstants.paginaTitulos['semDadosSubtitulo']!,
              style: TextStyle(
                fontSize: VeiculosConstants.tamanhosFonte['subtituloSemDados']!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleGrid(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        0,
        VeiculosConstants.dimensoes['paddingPequeno']!,
        0,
        VeiculosConstants.dimensoes['paddingPequeno']!,
      ),
      // Use GetBuilder for list changes only - more efficient than Obx
      child: GetBuilder<VeiculosPageController>(
        id: 'vehicle_list', // Specific ID for targeted updates
        builder: (controller) => _buildVehicleGridContent(context, controller),
      ),
    );
  }

  Widget _buildVehicleGridContent(
      BuildContext context, VeiculosPageController controller) {
    final vehicleCount = controller.length;
    if (vehicleCount == 0) {
      return _buildEmptyState(context);
    }

    final vehicles = controller.veiculos;
    if (vehicles.isEmpty) {
      return _buildEmptyState(context);
    }

    return AlignedGridView.count(
      crossAxisCount: VeiculosUIStateService.getGridCrossAxisCount(context),
      mainAxisSpacing: VeiculosConstants.dimensoes['espacamentoGrid']!,
      crossAxisSpacing: VeiculosConstants.dimensoes['espacamentoGrid']!,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: vehicleCount,
      itemBuilder: (context, index) {
        if (index >= vehicleCount || index < 0 || index >= vehicles.length) {
          return const SizedBox.shrink();
        }

        final veiculo = vehicles[index];
        return _buildVehicleCard(context, veiculo);
      },
    );
  }

  Widget _buildVehicleCard(BuildContext context, VeiculoCar veiculo) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            VeiculosConstants.dimensoes['borderRadiusCard']!),
        side: BorderSide(
          color: VeiculosThemeService.getCardBorderColor(context),
          width: VeiculosConstants.dimensoes['larguraBorda']!,
        ),
      ),
      child: Column(
        children: [
          _buildCardHeader(context, veiculo),
          Divider(height: VeiculosConstants.dimensoes['alturaDivisor']!),
          _buildCardContent(context, veiculo),
          _buildCardActions(context, veiculo),
        ],
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context, VeiculoCar veiculo) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top:
              Radius.circular(VeiculosConstants.dimensoes['borderRadiusCard']!),
        ),
      ),
      padding: EdgeInsets.all(VeiculosConstants.dimensoes['padding']!),
      child: Row(
        children: [
          CircleAvatar(
            radius: VeiculosConstants.dimensoes['raioAvatar']!,
            backgroundColor:
                VeiculosThemeService.getAvatarBackgroundColor(context),
            child: Icon(
              VeiculosConstants.icones['carro']!,
              color: VeiculosThemeService.getIconColor(context),
              size: VeiculosConstants.dimensoes['tamanhoIcone']!,
            ),
          ),
          SizedBox(width: VeiculosConstants.dimensoes['espacamento']!),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  VeiculosFormatterService.formatVehicleTitle(veiculo),
                  style: TextStyle(
                    fontSize: VeiculosConstants.tamanhosFonte['titulo']!,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  VeiculosFormatterService.formatVehicleSubtitle(veiculo),
                  style: TextStyle(
                    fontSize: VeiculosConstants.tamanhosFonte['subtitulo']!,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, VeiculoCar veiculo) {
    return Padding(
      padding: EdgeInsets.all(VeiculosConstants.dimensoes['padding']!),
      child: Column(
        children: [
          _buildInfoRow(
            context,
            VeiculosConstants.rotulosCampos['placa']!,
            VeiculosFormatterService.formatFieldValue(veiculo.placa),
            VeiculosConstants.icones['placa']!,
          ),
          Divider(height: VeiculosConstants.dimensoes['alturaDivisor']!),
          _buildInfoRow(
            context,
            VeiculosConstants.rotulosCampos['combustivel']!,
            VeiculosFormatterService.formatCombustivel(veiculo.combustivel),
            VeiculosConstants.icones['combustivel']!,
          ),
          Divider(height: VeiculosConstants.dimensoes['alturaDivisor']!),
          _buildInfoRow(
            context,
            VeiculosConstants.rotulosCampos['odometroInicial']!,
            VeiculosFormatterService.formatOdometer(veiculo.odometroInicial),
            VeiculosConstants.icones['odometroInicial']!,
          ),
          Divider(height: VeiculosConstants.dimensoes['alturaDivisor']!),
          _buildInfoRow(
            context,
            VeiculosConstants.rotulosCampos['odometroAtual']!,
            VeiculosFormatterService.formatOdometer(veiculo.odometroAtual),
            VeiculosConstants.icones['odometroAtual']!,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: VeiculosConstants.dimensoes['tamanhoIconePequeno']!,
          color: VeiculosThemeService.getInfoIconColor(context),
        ),
        SizedBox(width: VeiculosConstants.dimensoes['paddingPequeno']!),
        Text(
          label,
          style: TextStyle(
            fontSize: VeiculosConstants.tamanhosFonte['rotuloInfo']!,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: VeiculosConstants.tamanhosFonte['valorInfo']!,
          ),
        ),
      ],
    );
  }

  Widget _buildCardActions(BuildContext context, VeiculoCar veiculo) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom:
              Radius.circular(VeiculosConstants.dimensoes['borderRadiusCard']!),
        ),
      ),
      child: OverflowBar(
        children: [
          TextButton.icon(
            icon: Icon(VeiculosConstants.icones['editar']!),
            label: Text(VeiculosConstants.botoes['editar']!),
            onPressed: () async {
              final result = await VeiculosCadastro(context, veiculo);
              if (result == true) {
                controller.refreshVeiculos();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    // No need for Obx here as this button doesn't change based on reactive state
    return FloatingActionButton(
      tooltip: VeiculosConstants.botoes['adicionar']!,
      onPressed: () async {
        // Check vehicle limit first
        final canAdd = await controller.handleVeiculoCreation(context);
        if (!canAdd) {
          VeiculosUIStateService.showErrorMessage(
            context,
            VeiculosConstants.mensagensErro['limiteVeiculos']!,
          );
          return;
        }

        // Navigate to vehicle registration
        final result = await VeiculosCadastro(context, null);
        if (result == true) {
          controller.refreshVeiculos();
        }
        // Removido o tratamento de erro para evitar mensagem desnecessária
        // quando o usuário cancela ou há erro de validação
      },
      child: Icon(VeiculosConstants.icones['adicionar']!),
    );
  }
}
