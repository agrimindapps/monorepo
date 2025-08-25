// Flutter imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../database/25_manutencao_model.dart';
import '../../../../widgets/gasometer_header_widget.dart';
import '../../../../widgets/months_navigation_widget.dart';
import '../../../../widgets/no_veiculo_selecionado_widget.dart';
import '../../../../widgets/skeleton_loading_widget.dart';
import '../../../../widgets/veiculosSelect_widget.dart';
import '../../manutencoes_cadastro/widgets/manutencoes_cadastro_widget.dart';
import '../controller/manutencoes_page_controller.dart';

class ManutencoesPageView extends GetView<ManutencoesPageController> {
  const ManutencoesPageView({super.key});

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
      title: 'Manutenções',
      subtitle: 'Controle e acompanhe as manutenções do veículo',
      icon: Icons.build,
      showBackButton: false,
      actions: [
        Obx(() => controller.hasManutencoes
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

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final offset = notification.metrics.pixels;
      controller.updateScrollOffset(offset);
    }
  }

  Widget _buildCollapsibleHeader(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Column(
        children: [
          _buildVeiculoDropdown(),
          Obx(() => controller.showHeader.value &&
                  controller.hasSelectedVehicle &&
                  controller.hasManutencoes
              ? _buildMetricsHeader()
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildMetricsHeader() {
    return Obx(() {
      final manutencoesMes = controller.currentMonthManutencoes;
      final estatisticas = controller.calcularEstatisticasMensais(manutencoesMes);
      
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: _buildDateHeader(
          controller.monthsList.isNotEmpty
              ? controller.monthsList[controller.currentCarouselIndex.value]
              : DateTime.now(),
          manutencoesMes,
        ),
      );
    });
  }

  Widget _buildVeiculoDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: VeiculoDropdownWidget(
        onVeiculoSelected: (value, animal) {
          controller.loadData();
        },
      ),
    );
  }

  Widget _buildMainContentSliver(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Obx(() {
            if (controller.isLoading.value) {
              return _buildLoadingState();
            } else if (!controller.hasSelectedVehicle) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: NoVeiculoSelecionadoWidget(),
              );
            } else if (controller.manutencoes.isEmpty) {
              return _buildNoHasData(context);
            } else {
              return _buildHasData(context);
            }
          }),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          SkeletonLoadingWidget(height: 100),
          SizedBox(height: 16),
          SkeletonLoadingWidget(height: 200),
          SizedBox(height: 16),
          SkeletonLoadingWidget(height: 150),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Obx(() => AnimatedScale(
          scale: controller.hasSelectedVehicle ? 1.0 : 0.8,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton.extended(
            onPressed: controller.hasSelectedVehicle
                ? () async {
                    final created = await manutencaoCadastro(context, null);
                    if (created == true) {
                      controller.onManutencaoChanged();
                    }
                  }
                : null,
            backgroundColor: controller.hasSelectedVehicle
                ? ShadcnStyle.primaryColor
                : Colors.grey[300],
            icon: Icon(
              Icons.add,
              color: controller.hasSelectedVehicle
                  ? Colors.white
                  : Colors.grey[500],
            ),
            label: Text(
              'Nova Manutenção',
              style: TextStyle(
                color: controller.hasSelectedVehicle
                    ? Colors.white
                    : Colors.grey[500],
              ),
            ),
            elevation: controller.hasSelectedVehicle ? 6 : 2,
          ),
        ));
  }

  Widget _buildNoHasData(BuildContext context) {
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header do mês atual
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ShadcnStyle.primaryColor.withValues(alpha: 0.1),
                  ShadcnStyle.primaryColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ShadcnStyle.borderColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: ShadcnStyle.primaryColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: ShadcnStyle.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    controller.formatDateHeader(now),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Empty state
          Container(
            height: 400,
            decoration: BoxDecoration(
              color: ThemeManager().isDark.value
                  ? Colors.grey.shade900
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ShadcnStyle.borderColor.withValues(alpha: 0.2),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ShadcnStyle.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.build_outlined,
                      size: 48,
                      color: ShadcnStyle.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nenhuma manutenção registrada',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: ThemeManager().isDark.value
                          ? Colors.white
                          : ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione sua primeira manutenção',
                    style: TextStyle(
                      fontSize: 14,
                      color: ShadcnStyle.mutedTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHasData(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMonthsNavigation(),
            const SizedBox(height: 16),
            _buildCarouselContent(context),
          ],
        ),
      );
    });
  }

  Widget _buildMonthsNavigation() {
    return Obx(() => DecoratedBox(
          decoration: BoxDecoration(
            color: ThemeManager().isDark.value
                ? Colors.grey.shade900
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ShadcnStyle.borderColor.withValues(alpha: 0.2),
            ),
          ),
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
            height: MediaQuery.of(context).size.height * 0.6,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            autoPlay: false,
            onPageChanged: (index, reason) {
              controller.setCarouselIndex(index);
            },
          ),
          items: controller.monthsList.map((date) {
            final manutencoesMes = controller.filterManutencoesByMonth(date);
            return Builder(
              builder: (BuildContext context) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    children: [
                      if (manutencoesMes.isEmpty)
                        _buildNoDataForMonth()
                      else
                        _buildManutencoesList(manutencoesMes),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ));
  }

  Widget _buildDateHeader(DateTime date, List<ManutencaoCar> manutencoes) {
    final estatisticas = controller.calcularEstatisticasMensais(manutencoes);
    final totalGasto = estatisticas['totalGasto'] as double;
    final pendentes = estatisticas['pendentes'] as int;
    final concluidas = estatisticas['concluidas'] as int;
    final total = estatisticas['total'] as int;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ShadcnStyle.primaryColor.withValues(alpha: 0.05),
            ShadcnStyle.primaryColor.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ShadcnStyle.borderColor.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              icon: Icons.attach_money,
              label: 'Total Gasto',
              value: controller.formatCurrency(totalGasto),
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              icon: Icons.pending_actions,
              label: 'Pendentes',
              value: pendentes.toString(),
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              icon: Icons.check_circle,
              label: 'Concluídas',
              value: concluidas.toString(),
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              icon: Icons.build,
              label: 'Total',
              value: total.toString(),
              color: ShadcnStyle.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: ThemeManager().isDark.value
            ? Colors.grey.shade900
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: ThemeManager().isDark.value
                  ? Colors.white
                  : ShadcnStyle.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: ShadcnStyle.mutedTextColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataForMonth() {
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: ThemeManager().isDark.value
            ? Colors.grey.shade900.withValues(alpha: 0.5)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ShadcnStyle.borderColor.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ShadcnStyle.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.build_outlined,
                size: 32,
                color: ShadcnStyle.primaryColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma manutenção neste mês',
              style: TextStyle(
                color: ShadcnStyle.mutedTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManutencoesList(List<ManutencaoCar> manutencoes) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: manutencoes.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
          child: _buildManutencaoItem(context, manutencoes[index]),
        );
      },
    );
  }

  Widget _buildManutencaoItem(BuildContext context, ManutencaoCar manutencao) {
    final date = DateTime.fromMillisecondsSinceEpoch(manutencao.data);
    final dayOfMonth = controller.formatDay(date);
    final weekday = controller.formatWeekday(date);
    final isCompleted = manutencao.status == 'concluida';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ThemeManager().isDark.value
            ? Colors.grey.shade900
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.3)
              : ShadcnStyle.borderColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final updated = await manutencaoCadastro(context, manutencao);
            if (updated == true) {
              controller.onManutencaoChanged();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Data
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: ShadcnStyle.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekday,
                        style: TextStyle(
                          fontSize: 11,
                          color: ShadcnStyle.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayOfMonth,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: ShadcnStyle.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Divider
                Container(
                  width: 1,
                  height: 50,
                  color: ShadcnStyle.borderColor.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 20),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoTag(
                            icon: controller.getTipoIcon(manutencao.tipo),
                            value: manutencao.tipo,
                            color: _getTypeColor(manutencao.tipo),
                          ),
                          _buildValueTag(
                            value: controller.formatCurrency(manutencao.valor),
                          ),
                        ],
                      ),
                      if (manutencao.descricao.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ShadcnStyle.borderColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.description,
                                size: 14,
                                color: ShadcnStyle.mutedTextColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  manutencao.descricao,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ShadcnStyle.mutedTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (isCompleted) ...[
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Colors.green,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Concluída',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'preventiva':
        return Colors.blue;
      case 'corretiva':
        return Colors.orange;
      case 'preditiva':
        return Colors.purple;
      default:
        return ShadcnStyle.primaryColor;
    }
  }

  Widget _buildInfoTag({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueTag({required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.1),
            Colors.green.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.attach_money,
            size: 14,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

}
