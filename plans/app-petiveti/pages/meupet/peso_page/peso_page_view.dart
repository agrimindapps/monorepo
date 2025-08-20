// Flutter imports:
// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../models/17_peso_model.dart';
import '../../../widgets/animalSelect_widget.dart';
import '../../../widgets/bottombar_widget.dart';
import '../../../widgets/months_navigation_widget.dart';
import '../../../widgets/no_animal_selecionado_widget.dart';
import '../../../widgets/page_header_widget.dart';
import '../animal_page/controllers/animal_page_controller.dart';
import '../peso_cadastro/index.dart';

class PesoPageView extends StatefulWidget {
  const PesoPageView({super.key});

  @override
  State<PesoPageView> createState() => _PesoPageViewState();
}

class _PesoPageViewState extends State<PesoPageView> {
  late AnimalPageController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AnimalPageController>();
  }

  Future<void> _loadPesos() async {
    await controller.loadPesos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Body content
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: const VetBottomBarWidget(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return GetBuilder<AnimalPageController>(
      builder: (controller) => PageHeaderWidget(
        title: 'Pesos',
        subtitle: controller.getSubtitle(),
        icon: Icons.monitor_weight,
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildBody() {
    return Center(
      child: SizedBox(
        width: 1020,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnimalSelector(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalSelector() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: AnimalDropdownWidget(
        onAnimalSelected: (animalId, animal) {
          if (animalId != null && animalId.isNotEmpty) {
            controller.setSelectedAnimalId(animalId);
          } else {
            controller.setSelectedAnimalId('');
          }
        },
        showRefreshButton: false,
      ),
    );
  }

  Widget _buildContent() {
    return GetBuilder<AnimalPageController>(
      builder: (controller) {
        if (controller.shouldShowNoAnimalSelected()) {
          return const NoAnimalSelecionadoWidget();
        } else if (controller.shouldShowLoading()) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.shouldShowError()) {
          return const Center(child: Text('Erro ao carregar dados'));
        } else if (controller.shouldShowNoData()) {
          return SingleChildScrollView(child: _buildNoDataContent());
        } else if (controller.shouldShowPesos()) {
          return SingleChildScrollView(child: _buildPesosContent());
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildNoDataContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        children: [
          MonthsNavigationWidget(
            monthsList: controller.getMonthsList(),
            currentIndex: controller.getCurrentMonthIndex(),
            onMonthTap: (index) => controller.setCurrentMonthIndex(index),
          ),
          const SizedBox(height: 8),
          _buildNoDataMessage(),
        ],
      ),
    );
  }


  Widget _buildNoDataMessage() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 0,
      height: MediaQuery.of(context).size.height - 215,
      child: const Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.scale_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Nenhum registro de peso encontrado neste período.',
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
    );
  }

  Widget _buildPesosContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: MonthsNavigationWidget(
            monthsList: controller.getMonthsList(),
            currentIndex: controller.getCurrentMonthIndex(),
            onMonthTap: (index) => controller.setCurrentMonthIndex(index),
          ),
        ),
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: _buildChart(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Column(
              children: [
                _buildSummaryCard(),
                _buildPesoList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return GetBuilder<AnimalPageController>(
      builder: (controller) {
        final variacao = controller.calcularVariacaoPeso();
        final percentual = controller.calcularPercentualVariacao();
        final isPositiveVariation = variacao > 0;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoCard('Peso Atual', '${controller.pesoAtual}kg'),
              _infoCard(
                  'Média', '${controller.mediaPesos.toStringAsFixed(1)}kg'),
              _infoCard(
                'Variação',
                '${variacao > 0 ? '+' : ''}${variacao.toStringAsFixed(1)}kg (${percentual.toStringAsFixed(1)}%)',
                color:
                    isPositiveVariation ? Colors.green[700] : Colors.red[700],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoCard(String title, String value, {Color? color}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Card(
          elevation: 2,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.7)
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChart() {
    return GetBuilder<AnimalPageController>(
      builder: (controller) {
        if (controller.pesos.isEmpty) {
          return const Center(child: Text('Sem dados para exibir'));
        }

        final graphData = controller.getGraphData();

        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 &&
                        value.toInt() < graphData.length) {
                      final date = DateTime.fromMillisecondsSinceEpoch(
                          graphData[value.toInt()]['data'] as int);
                      return RotatedBox(
                        quarterTurns: 1,
                        child: Text(
                          DateFormat('dd/MM').format(date),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toStringAsFixed(1)}kg',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: graphData
                    .asMap()
                    .entries
                    .map((e) =>
                        FlSpot(e.key.toDouble(), (e.value['peso'] as double)))
                    .toList(),
                isCurved: true,
                color: Colors.blue,
                dotData: const FlDotData(show: true),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPesoList() {
    return GetBuilder<AnimalPageController>(
      builder: (controller) => ListView.separated(
        separatorBuilder: (_, __) => const Divider(),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.pesos.length,
        itemBuilder: (context, index) {
          final peso = controller.pesos[index];
          final formattedDate = controller.formatDateToString(peso.dataPesagem);

          return ListTile(
            title: Text('${peso.peso}kg'),
            subtitle: Text('Data: $formattedDate'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editPeso(peso),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deletePeso(peso),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Obx(() => FloatingActionButton(
          onPressed: controller.canAddPeso() ? _addPeso : null,
          backgroundColor: controller.canAddPeso()
              ? Theme.of(context).floatingActionButtonTheme.backgroundColor
              : Colors.grey[400],
          child: const Icon(Icons.add),
        ));
  }

  Future<void> _addPeso() async {
    await pesoCadastro(
      context,
      null,
      onPesoSaved: (peso) => _loadPesos(),
    );
  }

  Future<void> _editPeso(PesoAnimal peso) async {
    await pesoCadastro(
      context,
      peso,
      onPesoSaved: (peso) => _loadPesos(),
    );
  }

  Future<void> _deletePeso(PesoAnimal peso) async {
    final confirm = await _showDeleteConfirmationDialog();

    if (confirm == true) {
      try {
        await controller.deletePeso(peso);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro excluído com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir registro: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja excluir este registro de peso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // AnimalPageController é global, não deve ser deletado aqui
    super.dispose();
  }
}
