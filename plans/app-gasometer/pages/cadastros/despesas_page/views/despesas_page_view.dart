// Flutter imports:
// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../database/22_despesas_model.dart';
import '../../../../widgets/appbar_widget.dart';
import '../../../../widgets/months_navigation_widget.dart';
import '../../../../widgets/no_veiculo_selecionado_widget.dart';
import '../../../../widgets/veiculosSelect_widget.dart';
import '../../despesas_cadastro/widgets/despesas_cadastro_widget.dart';
import '../controller/despesas_page_controller.dart';

class DespesasPageView extends GetView<DespesasPageController> {
  const DespesasPageView({super.key});

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
                mainAxisAlignment: MainAxisAlignment.center,
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
          title: 'Despesas',
          icon: Icons.receipt,
          iconColor: Colors.black,
          iconBackgroundColor: Colors.grey.shade100,
          iconBorderColor: Colors.grey.shade300,
          showBackButton: false,
          actions: [
            Obx(() => controller.hasDespesas
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
          controller.carregarDespesas();
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Obx(() {
      if (!controller.hasSelectedVehicle) {
        return const NoVeiculoSelecionadoWidget();
      } else if (controller.despesasPorMes.isEmpty) {
        return _buildNoHasData(context);
      } else {
        return _buildHasData(context);
      }
    });
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Obx(() => FloatingActionButton(
          onPressed: () async {
            final created = await despesaCadastro(context, null);
            if (created == true) {
              controller.onDespesaChanged();
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                      Icons.receipt_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Nenhuma despesa cadastrada neste período.',
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
      final allMonths = controller.generateMonthsList();

      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Column(
          children: [
            _buildMonthsHeader(context, allMonths),
            _buildCarouselContent(context, allMonths),
          ],
        ),
      );
    });
  }

  Widget _buildMonthsHeader(BuildContext context, List<DateTime> allMonths) {
    return Obx(() => MonthsNavigationWidget(
          monthsList: allMonths,
          currentIndex: controller.currentCarouselIndex.value,
          onMonthTap: (index) => controller.animateToPage(index),
        ));
  }

  Widget _buildCarouselContent(BuildContext context, List<DateTime> allMonths) {
    return CarouselSlider(
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
      items: allMonths.map((date) {
        final despesasDoMes = controller.getDespesasForMonth(date);
        return Builder(
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Obx(() => controller.showHeader.value
                      ? _buildMonthHeader(date, despesasDoMes)
                      : const SizedBox.shrink()),
                  const SizedBox(height: 4),
                  if (despesasDoMes.isEmpty)
                    _buildNoDataForMonth()
                  else
                    _buildDespesasList(despesasDoMes),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildMonthHeader(DateTime date, List<DespesaCar> despesasDoMes) {
    final estatisticas = controller.calcularEstatisticasMensais(despesasDoMes);
    final totalMes = estatisticas['totalMes'] as double;
    final quantidade = estatisticas['quantidade'] as int;
    final mediaPorDespesa = estatisticas['mediaPorDespesa'] as double;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShadcnStyle.backgroundColor,
        borderRadius: ShadcnStyle.borderRadius,
        border: Border.all(color: ShadcnStyle.borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHeaderInfo(
                icon: Icons.attach_money,
                label: 'Total do Mês',
                value: controller.formatCurrency(totalMes),
                color: ShadcnStyle.textColor,
              ),
              _buildHeaderInfo(
                icon: Icons.receipt_long,
                label: 'Quantidade',
                value: '$quantidade',
                color: ShadcnStyle.textColor,
              ),
              _buildHeaderInfo(
                icon: Icons.analytics,
                label: 'Média/Despesa',
                value: quantidade == 0
                    ? 'N/A'
                    : controller.formatCurrency(mediaPorDespesa),
                color: ShadcnStyle.textColor,
              ),
            ],
          ),
        ],
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ShadcnStyle.textColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: ShadcnStyle.textColor, size: 16),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: ShadcnStyle.textColor,
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
    );
  }

  Widget _buildNoDataForMonth() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma despesa registrada neste mês',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDespesasList(List<DespesaCar> despesas) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: despesas.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
          child: _buildDespesaItem(context, despesas[index]),
        );
      },
    );
  }

  Widget _buildDespesaItem(BuildContext context, DespesaCar despesa) {
    final date = DateTime.fromMillisecondsSinceEpoch(despesa.data);
    final dayOfMonth = controller.formatDay(date);
    final weekday = controller.formatWeekday(date);

    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () async {
          final updated = await despesaCadastro(context, despesa);
          if (updated == true) {
            controller.onDespesaChanged();
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
              Container(width: 1, height: 40, color: ShadcnStyle.borderColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoItem(
                          icon: controller.getTipoIcon(despesa.tipo),
                          value: despesa.descricao,
                          label: despesa.tipo,
                        ),
                        _buildInfoItem(
                          icon: Icons.attach_money,
                          value: controller.formatCurrency(despesa.valor),
                          label: 'Valor',
                          isHighlighted: true,
                        ),
                      ],
                    ),
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
