// Flutter imports:
// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../../../../models/medicoes_models.dart';
import '../../../../models/pluviometros_models.dart';
import '../../../../widgets/page_header_widget.dart';
import '../../../../widgets/pluviometro_select_widget.dart';
import '../../medicoes_cadastro/widgets/medicoes_form_widget.dart';
import '../controller/medicoes_page_controller.dart';
import 'widgets/carousel_month_selector.dart';
import 'widgets/daily_list_widget.dart';
import 'widgets/month_header_widget.dart';
import 'widgets/no_data_widget.dart';

class MedicoesPageView extends StatefulWidget {
  const MedicoesPageView({super.key});

  @override
  MedicoesPageViewState createState() => MedicoesPageViewState();
}

class MedicoesPageViewState extends State<MedicoesPageView> {
  final _controller = MedicoesPageController();
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final List<Pluviometro> pluviometros = [];
  final List<Medicoes> medicoes = [];
  final List<dynamic> daysOfMonth = [];
  bool isLoading = false;
  int _currentCarouselIndex = 0;

  void _showMedicoesForm(Medicoes? medicao) {
    medicoesCadastro(context, medicao).then((value) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final days = _controller.generateDaysOfMonthList();
    setState(() {
      daysOfMonth.clear();
      daysOfMonth.addAll(days);
    });
    await _carregarPluviometros();
    await _carregarMedicoes();
  }

  Future<void> _carregarPluviometros() async {
    final pluviometrosList = await _controller.getPluviometros();
    setState(() {
      pluviometros.clear();
      pluviometros.addAll(pluviometrosList);
    });
  }

  Future<void> _carregarMedicoes() async {
    setState(() => isLoading = true);
    try {
      String pluviometroId = _controller.selectedPluviometroId;

      // Verificar se há um pluviômetro selecionado
      if (pluviometroId.isEmpty) {
        setState(() {
          medicoes.clear();
        });
        return;
      }

      final medicoesList = await _controller.getMeasurements(pluviometroId);
      setState(() {
        medicoes.clear();
        medicoes.addAll(medicoesList);
      });
    } catch (e) {
      // Em caso de erro, limpar a lista
      setState(() {
        medicoes.clear();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: PageHeaderWidget(
                title: 'Medições',
                subtitle: 'Gestão de Medições Pluviométricas',
                icon: Icons.water_drop_outlined,
                showBackButton: true,
              ),
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 1020,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                    child: Column(
                      children: [
                        PluvioSelect(
                          onPluviometroSelected: (id) {
                            _carregarMedicoes();
                          },
                        ),
                        Expanded(
                          child: medicoes.isEmpty
                              ? NoDataWidget(
                                  onTap: () => _showMedicoesForm(null))
                              : _hasData(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showMedicoesForm(null),
      ),
    );
  }

  Widget _hasData() {
    final allMonths = _controller.getMonthsList(medicoes);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CarouselMonthSelector(
          months: allMonths,
          currentIndex: _currentCarouselIndex,
          onMonthTap: (index) {
            _carouselController.animateToPage(index);
          },
        ),
        Expanded(
          child: CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              autoPlay: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentCarouselIndex = index;
                });
              },
            ),
            items: allMonths.map((date) {
              final medicoesDoMes =
                  _controller.getMonthMeasurements(medicoes, date);
              final hasData = medicoesDoMes.isNotEmpty;

              return Builder(
                builder: (BuildContext context) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                          child: MonthHeaderWidget(
                            date: date,
                            medicoes: medicoesDoMes,
                            statistics: _controller.calculateMonthStatistics(
                                date, medicoesDoMes),
                          ),
                        ),
                        if (!hasData)
                          NoDataWidget(
                            onTap: () => _showMedicoesForm(null),
                            isMonthView: true,
                          )
                        else
                          DailyListWidget(
                            month: date,
                            medicoes: medicoesDoMes,
                            onMedicaoTap: _showMedicoesForm,
                            controller: _controller,
                          ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
