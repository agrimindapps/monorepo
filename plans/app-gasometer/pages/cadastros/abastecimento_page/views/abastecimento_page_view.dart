// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../widgets/gasometer_header_widget.dart';
import '../../../../widgets/no_veiculo_selecionado_widget.dart';
import '../../../../widgets/skeleton_loading_widget.dart';
import '../../../../widgets/veiculosSelect_widget.dart';
import '../../abastecimento_cadastro/widgets/abastecimento_cadastro.dart';
import '../constants/abastecimento_strings.dart';
import '../controller/abastecimento_page_controller.dart';
import '../widgets/abastecimento_carousel_widget.dart';
import '../widgets/abastecimento_metrics_widget.dart';
import '../widgets/abastecimento_months_navigation_widget.dart';

class AbastecimentoPageView extends GetView<AbastecimentoPageController> {
  const AbastecimentoPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: ThemeManager().isDark.value
              ? const Color(0xFF1A1A2E)
              : Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                // Header fixo principal
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1120,
                    ),
                    child: _buildHeader(context),
                  ),
                ),

                // Conteúdo com CustomScrollView para o efeito collapsing
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 1120,
                      child: _buildScrollableContent(context),
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
    return GasometerHeaderWidget(
      title: 'Abastecimentos',
      subtitle: 'Gerencie seus registros de combustível',
      icon: Icons.local_gas_station,
      showBackButton: false,
      actions: [
        Obx(() => controller.abastecimentosAgrupados.isNotEmpty
            ? IconButton(
                icon: Icon(
                  controller.showHeader.value
                      ? Icons.assessment
                      : Icons.assessment_outlined,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: () => controller.toggleHeader(),
                tooltip: controller.showHeader.value
                    ? 'Ocultar estatísticas'
                    : 'Mostrar estatísticas',
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
    return Column(
      children: [
        // Header com controles que vai colapsar
        _buildCollapsibleHeader(context),

        // Conteúdo principal com NotificationListener para detectar scroll
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              _handleScrollNotification(notification);
              return false;
            },
            child: _buildMainContentSliver(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsibleHeader(BuildContext context) {
    return Obx(() {
      final isDark = ThemeManager().isDark.value;
      final progress = controller.scrollProgress.value;
      final isCollapsed = controller.isHeaderCollapsed.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.grey.shade50,
          boxShadow: progress > 0.1
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1 * progress),
                    blurRadius: 4 * progress,
                    offset: Offset(0, 2 * progress),
                  ),
                ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -0.3),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: isCollapsed
              ? SizedBox(
                  key: const ValueKey('collapsed'),
                  height: 64.0,
                  child: _buildCollapsedControls(context),
                )
              : SizedBox(
                  key: const ValueKey('expanded'),
                  child: IntrinsicHeight(
                    child: _buildExpandedControls(context),
                  ),
                ),
        ),
      );
    });
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final scrollOffset = notification.metrics.pixels;
      controller.updateScrollProgress(scrollOffset);
    }
  }

  Widget _buildExpandedControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dropdown de veículo
          _buildVeiculoDropdown(),
          // Navegação de meses
          _buildMonthsNavigation(),
          // Totalizador (métricas do mês)
          // _buildMetricsSection(),
        ],
      ),
    );
  }

  Widget _buildCollapsedControls(BuildContext context) {
    return Obx(() {
      final isDark = ThemeManager().isDark.value;

      if (!controller.hasSelectedVehicle) {
        return Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text(
              'Selecione um veículo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ),
        );
      }

      return Container(
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey.shade800.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Ícone do veículo
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey.shade700.withValues(alpha: 0.5)
                    : Colors.grey.shade200.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.directions_car,
                size: 18,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),

            // Nome do veículo
            Expanded(
              child: Obx(() => Text(
                    controller.getSelectedVehicleName(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.grey.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )),
            ),

            // Separador
            Container(
              width: 1,
              height: 20,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),

            // Mês atual
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey.shade700.withValues(alpha: 0.5)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                controller.getCurrentMonthName(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
            ),

            // Opcional: Valor total resumido (muito discreto)
            // Você pode descomentar se quiser mostrar algo no modo colapsado
            /*
            const SizedBox(width: 8),
            if (controller.hasSelectedVehicle && 
                controller.selectedMonth.value != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getQuickTotal(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.green.shade600,
                  ),
                ),
              ),
            */
          ],
        ),
      );
    });
  }

  Widget _buildMainContentSliver(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const AbastecimentoSkeletonWidget();
      } else if (!controller.hasSelectedVehicle) {
        return const NoVeiculoSelecionadoWidget();
      } else if (controller.abastecimentosAgrupados.isEmpty) {
        return _buildNoHasData(context);
      } else {
        return AbastecimentoCarouselWidget(
          allMonths:
              controller.generateMonthsList(controller.abastecimentosAgrupados),
        );
      }
    });
  }

  Widget _buildMetricsSection() {
    // Só mostra se tiver veículo selecionado e dados
    if (!controller.hasSelectedVehicle ||
        controller.abastecimentosAgrupados.isEmpty ||
        controller.selectedMonth.value == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: AbastecimentoMetricsWidget(
        date: controller.selectedMonth.value!,
      ),
    );
  }

  Widget _buildVeiculoDropdown() {
    return VeiculoDropdownWidget(
      onVeiculoSelected: (value, animal) {
        controller.onVeiculoSelected();
      },
    );
  }

  Widget _buildMonthsNavigation() {
    if (!controller.hasSelectedVehicle ||
        controller.abastecimentosAgrupados.isEmpty) {
      return const SizedBox.shrink();
    }

    return const Padding(
      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: AbastecimentoMonthsNavigationWidget(),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Obx(() {
      final hasSelectedVehicle = controller.hasSelectedVehicle;

      return FloatingActionButton(
        onPressed: hasSelectedVehicle && !controller.isLoading.value
            ? () async {
                final created =
                    await showAbastecimentoCadastroDialog(context, null);
                if (created == true) {
                  controller.carregarAbastecimentos();
                }
              }
            : null,
        backgroundColor: hasSelectedVehicle && !controller.isLoading.value
            ? Theme.of(context).floatingActionButtonTheme.backgroundColor
            : Colors.grey[400],
        child: controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
      );
    });
  }

  Widget _buildNoHasData(BuildContext context) {
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration: BoxDecoration(
              color:
                  ThemeManager().isDark.value ? Colors.grey[900] : Colors.white,
              borderRadius: ShadcnStyle.borderRadius,
              border: Border.all(color: ShadcnStyle.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeManager().isDark.value
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.formatDateHeader(now),
                    style: TextStyle(
                      color: ShadcnStyle.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_gas_station_outlined,
                      size: 64,
                      color: ShadcnStyle.mutedTextColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AbastecimentoStrings.noRecordsFound,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: ShadcnStyle.mutedTextColor,
                        fontWeight: FontWeight.w500,
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
}
