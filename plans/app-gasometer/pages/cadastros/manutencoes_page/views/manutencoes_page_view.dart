// Flutter imports:
// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../database/25_manutencao_model.dart';
import '../../../../widgets/appbar_widget.dart';
import '../../../../widgets/months_navigation_widget.dart';
import '../../../../widgets/no_veiculo_selecionado_widget.dart';
import '../../../../widgets/veiculosSelect_widget.dart';
import '../../manutencoes_cadastro/widgets/manutencoes_cadastro_widget.dart';
import '../controller/manutencoes_page_controller.dart';

class ManutencoesPageView extends GetView<ManutencoesPageController> {
  const ManutencoesPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 1020,
              child: Column(
                children: [
                  _buildVeiculoDropdown(),
                  _buildMainContent(context),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: MediaQuery.of(context).size.width < 1024
          ? const Size.fromHeight(72)
          : const Size.fromHeight(72),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: PageHeaderWidget(
          title: 'Manutenções',
          icon: Icons.build,
          iconColor: Colors.black,
          iconBackgroundColor: Colors.grey.shade100,
          iconBorderColor: Colors.grey.shade300,
          showBackButton: false,
          actions: [
            Obx(() => controller.hasManutencoes
                ? IconButton(
                    icon: Icon(
                      controller.showHeader.value
                          ? Icons.analytics
                          : Icons.analytics_outlined,
                      size: 20,
                      color: Colors.black,
                    ),
                    onPressed: () => controller.toggleHeader(),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildVeiculoDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: VeiculoDropdownWidget(
        onVeiculoSelected: (value, animal) {
          controller.loadData();
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Obx(() {
      if (!controller.hasSelectedVehicle) {
        return const NoVeiculoSelecionadoWidget();
      } else if (controller.manutencoes.isEmpty) {
        return _buildNoHasData(context);
      } else {
        return _buildHasData(context);
      }
    });
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Obx(() => FloatingActionButton(
          onPressed: () async {
            final created = await manutencaoCadastro(context, null);
            if (created == true) {
              controller.onManutencaoChanged();
            }
          },
          backgroundColor: controller.hasSelectedVehicle
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          child: Icon(
            Icons.add,
            color:
                controller.hasSelectedVehicle ? Colors.white : Colors.grey[500],
          ),
        ));
  }

  Widget _buildNoHasData(BuildContext context) {
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.formatDateHeader(now),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width - 0,
            height: MediaQuery.of(context).size.height - 215,
            child: const Center(
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.build_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Nenhuma manutenção cadastrada neste período.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
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

  Widget _buildHasData(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Column(
          children: [
            _buildMonthsHeader(context),
            _buildCarouselContent(context),
          ],
        ),
      );
    });
  }

  Widget _buildMonthsHeader(BuildContext context) {
    return Obx(() => MonthsNavigationWidget(
          monthsList: controller.monthsList,
          currentIndex: controller.currentCarouselIndex.value,
          onMonthTap: (index) => controller.animateToPage(index),
        ));
  }

  Widget _buildCarouselContent(BuildContext context) {
    return Obx(() => CarouselSlider(
          carouselController: controller.carouselController,
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height - 220,
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
                  child: Column(
                    children: [
                      Obx(() => controller.showHeader.value
                          ? _buildDateHeader(date, manutencoesMes)
                          : const SizedBox.shrink()),
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Container(
        decoration: BoxDecoration(
          color: ShadcnStyle.backgroundColor,
          borderRadius: ShadcnStyle.borderRadius,
          border: Border.all(color: ShadcnStyle.borderColor),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildHeaderInfo(
                icon: Icons.attach_money,
                label: 'Total Gasto',
                value: controller.formatCurrency(totalGasto),
                color: ShadcnStyle.textColor,
              ),
            ),
            Expanded(
              child: _buildHeaderInfo(
                icon: Icons.pending_actions,
                label: 'Pendentes',
                value: pendentes.toString(),
                color: ShadcnStyle.textColor,
              ),
            ),
            Expanded(
              child: _buildHeaderInfo(
                icon: Icons.check_circle,
                label: 'Concluídas',
                value: concluidas.toString(),
                color: ShadcnStyle.textColor,
              ),
            ),
            Expanded(
              child: _buildHeaderInfo(
                icon: Icons.speed,
                label: 'Total',
                value: total.toString(),
                color: ShadcnStyle.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataForMonth() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.build_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma manutenção registrada neste mês',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
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

    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () async {
          final updated = await manutencaoCadastro(context, manutencao);
          if (updated == true) {
            controller.onManutencaoChanged();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekday,
                    style: TextStyle(
                      fontSize: 12,
                      color: ShadcnStyle.mutedTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayOfMonth,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 40,
                color: ShadcnStyle.borderColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoItem(
                          icon: controller.getTipoIcon(manutencao.tipo),
                          value: manutencao.tipo,
                          label: 'Tipo',
                        ),
                        _buildInfoItem(
                          icon: Icons.attach_money,
                          value: controller.formatCurrency(manutencao.valor),
                          label: 'Valor',
                          isHighlighted: true,
                        ),
                      ],
                    ),
                    if (manutencao.descricao.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        manutencao.descricao,
                        style: TextStyle(
                          fontSize: 12,
                          color: ShadcnStyle.mutedTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
    bool isHighlighted = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isHighlighted
                ? ShadcnStyle.textColor.withValues(alpha: 0.1)
                : ShadcnStyle.borderColor.withValues(alpha: 0.3),
            borderRadius: ShadcnStyle.borderRadius,
          ),
          child: Icon(
            icon,
            size: 16,
            color: isHighlighted
                ? ShadcnStyle.textColor
                : ShadcnStyle.mutedTextColor,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isHighlighted
                    ? ShadcnStyle.textColor
                    : ShadcnStyle.mutedTextColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: ShadcnStyle.mutedTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
