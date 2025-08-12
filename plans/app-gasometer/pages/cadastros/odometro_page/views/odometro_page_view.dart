// Flutter imports:
// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../database/20_odometro_model.dart';
import '../../../../widgets/gasometer_header_widget.dart';
import '../../../../widgets/months_navigation_widget.dart';
import '../../../../widgets/no_veiculo_selecionado_widget.dart';
import '../../../../widgets/skeleton_loading_widget.dart';
import '../../../../widgets/veiculosSelect_widget.dart';
import '../../odometro_cadastro/widgets/odometro_cadastro_widget.dart';
import '../controller/odometro_page_controller.dart';
import '../models/odometro_page_constants.dart';
import '../widgets/monthly_stats_header.dart';
import '../widgets/no_data_month_widget.dart';
import '../widgets/odometro_item_widget.dart';

class OdometroPageView extends GetView<OdometroPageController> {
  const OdometroPageView({super.key});

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
                      maxWidth: OdometroPageConstants.maxWidth,
                    ),
                    child: _buildHeader(context),
                  ),
                ),

                // Conteúdo com header colapsável
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: OdometroPageConstants.maxWidth,
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
      title: OdometroPageConstants.pageTitles['title']!,
      subtitle: 'Gerencie seus registros de quilometragem',
      icon: OdometroPageConstants.icons['speed']!,
      showBackButton: false,
      actions: [
        Obx(() {
          if (controller.shouldShowAnalyticsButton()) {
            return IconButton(
              icon: Icon(
                controller.showHeader.value
                    ? Icons.assessment
                    : Icons.assessment_outlined,
                size: 20,
                color: Colors.white,
              ),
              onPressed: controller.toggleHeader,
              tooltip: controller.showHeader.value
                  ? 'Ocultar estatísticas'
                  : 'Mostrar estatísticas',
            );
          }
          return const SizedBox.shrink();
        }),
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
            child: _buildMainContent(context),
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

  Widget _buildExpandedControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildVeiculoDropdown(),
          if (controller.hasData) _buildMonthsNavigationBar(context),
        ],
      ),
    );
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final scrollOffset = notification.metrics.pixels;
      controller.updateScrollProgress(scrollOffset);
    }
  }

  Widget _buildCollapsedControls(BuildContext context) {
    return Obx(() {
      final isDark = ThemeManager().isDark.value;

      if (!controller.hasSelectedVehicle.value) {
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
          ],
        ),
      );
    });
  }

  Widget _buildVeiculoDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        0,
        0,
        0,
        4,
      ),
      child: VeiculoDropdownWidget(
        onVeiculoSelected: (value, veiculo) {
          controller.onVeiculoSelected();
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const OdometroSkeletonWidget();
      } else if (!controller.hasSelectedVehicle.value) {
        return const NoVeiculoSelecionadoWidget();
      } else if (!controller.hasData) {
        return _buildNoDataContent(context);
      } else {
        return _buildHasDataContent(context);
      }
    });
  }

  Widget _buildNoDataContent(BuildContext context) {
    final now = DateTime.now();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        OdometroPageConstants.dimensions['padding']!,
        OdometroPageConstants.dimensions['smallPadding']!,
        OdometroPageConstants.dimensions['padding']!,
        OdometroPageConstants.dimensions['smallPadding']!,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: OdometroPageConstants.getContentPadding(),
            decoration: OdometroPageConstants.getMonthContainerDecoration(
              controller.getBackgroundColor(context),
              controller.getBorderColor(context),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        OdometroPageConstants.dimensions['monthPadding']!,
                    vertical: OdometroPageConstants
                        .dimensions['monthVerticalPadding']!,
                  ),
                  decoration: OdometroPageConstants.getSelectedMonthDecoration(
                    controller.getSelectedMonthColor(context),
                  ),
                  child: Text(
                    controller.formatDateHeader(now),
                    style: OdometroPageConstants.monthTextStyle.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: OdometroPageConstants.dimensions['padding']!),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: controller.getNoDataHeight(context),
            child: Center(
              child: SizedBox(
                width:
                    OdometroPageConstants.dimensions['noDataContainerWidth']!,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      OdometroPageConstants.icons['speedOutlined']!,
                      size: OdometroPageConstants.dimensions['noDataIconSize']!,
                      color: ShadcnStyle.mutedTextColor,
                    ),
                    SizedBox(
                        height: OdometroPageConstants
                            .dimensions['contentSpacing']!),
                    Text(
                      'Nenhum registro de odômetro encontrado neste período.',
                      textAlign: TextAlign.center,
                      style: OdometroPageConstants.noDataTextStyle,
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

  Widget _buildHasDataContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            OdometroPageConstants.dimensions['padding']!,
            0,
            OdometroPageConstants.dimensions['padding']!,
            0,
          ),
          child: Column(
            children: [
              // MonthlyStatsHeader no início do scroll
              if (controller.showHeader.value) ...[
                Builder(
                  builder: (context) {
                    final currentMonth =
                        controller.selectedMonth.value ?? DateTime.now();
                    final statistics =
                        controller.getStatisticsForMonth(currentMonth);

                    // Converte as estatísticas para o formato esperado pelo MonthlyStatsHeader
                    final convertedStats = <String, double>{
                      'kmInicial': statistics['initialKm'] ?? 0.0,
                      'kmFinal': statistics['finalKm'] ?? 0.0,
                      'distanciaTotal': statistics['totalKm'] ?? 0.0,
                      'mediaKmDia': statistics['averagePerDay'] ?? 0.0,
                    };

                    return MonthlyStatsHeader(statistics: convertedStats);
                  },
                ),
                SizedBox(height: OdometroPageConstants.dimensions['padding']!),
              ],
              // Conteúdo do carousel
              _buildCarouselContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthsNavigationBar(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
          child: MonthsNavigationWidget(
            monthsList: controller.monthsList,
            currentIndex: controller.currentCarouselIndex.value,
            onMonthTap: (index) => controller.animateToPage(index),
          ),
        ));
  }

  Widget _buildCarouselContent(BuildContext context) {
    return Obx(() => CarouselSlider(
          carouselController: controller.carouselController,
          options: CarouselOptions(
            height: controller.getCarouselHeight(context),
            viewportFraction: OdometroPageConstants.carouselViewportFraction,
            enableInfiniteScroll:
                OdometroPageConstants.carouselEnableInfiniteScroll,
            autoPlay: OdometroPageConstants.carouselAutoPlay,
            onPageChanged: (index, reason) {
              controller.setCarouselIndex(index);
            },
          ),
          items: controller.monthsList.map((date) {
            final hasData = controller.hasDataForMonth(date);
            final odometrosDoMes = controller.getOdometrosForMonth(date);

            return Builder(
              builder: (BuildContext context) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        if (!hasData)
                          const NoDataForMonthWidget()
                        else
                          _buildOdometrosList(odometrosDoMes),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ));
  }

  Widget _buildOdometrosList(List<OdometroCar> odometros) {
    return Column(
      children: List.generate(
        odometros.length,
        (index) {
          final odometro = odometros[index];
          final difference = controller.calculateDifference(odometros, index);

          return Padding(
            padding: EdgeInsets.fromLTRB(
              0,
              OdometroPageConstants.dimensions['carouselSpacing']!,
              0,
              OdometroPageConstants.dimensions['carouselSpacing']!,
            ),
            child: OdometroItemWidget(
              odometro: odometro,
              difference: difference,
              onTap: () async {
                await controller.handleOdometroTap(
                  odometro,
                  onEdit: () => odometroCadastro(Get.context!, odometro),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Obx(() {
      final hasSelectedVehicle = controller.hasSelectedVehicle.value;

      return FloatingActionButton(
        onPressed: hasSelectedVehicle
            ? () async {
                await controller.handleAddOdometro(
                  onCreate: () => odometroCadastro(context, null),
                );
              }
            : null,
        backgroundColor: hasSelectedVehicle
            ? Theme.of(context).floatingActionButtonTheme.backgroundColor
            : Colors.grey[400],
        child: const Icon(Icons.add),
      );
    });
  }
}
