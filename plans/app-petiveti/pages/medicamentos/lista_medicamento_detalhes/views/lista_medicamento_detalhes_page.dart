// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/lista_medicamento_detalhes_controller.dart';
import '../utils/medicamento_constants.dart';
import 'widgets/dosage_calculator_widget.dart';
import 'widgets/info_card_widget.dart';
import 'widgets/medicamento_app_bar.dart';
import 'widgets/section_header_widget.dart';
import 'widgets/warning_card_widget.dart';

class ListaMedicamentoDetalhesPage extends StatefulWidget {
  const ListaMedicamentoDetalhesPage({super.key});

  @override
  State<ListaMedicamentoDetalhesPage> createState() =>
      _ListaMedicamentoDetalhesPageState();
}

class _ListaMedicamentoDetalhesPageState
    extends State<ListaMedicamentoDetalhesPage> {
  late final ListaMedicamentoDetalhesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ListaMedicamentoDetalhesController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    _controller.inicializarMedicamento(args);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: MedicamentoAppBar(
            controller: _controller,
            medicamento: _controller.medicamento,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildInformacoesBasicas(),
                const SizedBox(height: 16),
                _buildAdministracao(),
                const SizedBox(height: 16),
                _buildPrecaucoes(),
                if (_controller.medicamento?.temCalculadoraDosagem == true)
                  _buildCalculadoraDosagem(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        _controller.medicamento?.nome ?? 'Medicamento',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        textScaler: TextScaler.linear(_controller.textScaleFactor),
      ),
    );
  }

  Widget _buildInformacoesBasicas() {
    return Column(
      children: [
        SectionHeaderWidget(
          title: 'Informações Básicas',
          textScaleFactor: _controller.textScaleFactor,
        ),
        InfoCardWidget(
          title: 'Tipo',
          content: _controller.medicamento?.tipo ?? 'Não informado',
          textScaleFactor: _controller.textScaleFactor,
        ),
        InfoCardWidget(
          title: 'Indicação',
          content: _controller.medicamento?.indicacao ?? 'Não informado',
          textScaleFactor: _controller.textScaleFactor,
        ),
      ],
    );
  }

  Widget _buildAdministracao() {
    final medicamento = _controller.medicamento;
    return Column(
      children: [
        SectionHeaderWidget(
          title: 'Administração',
          textScaleFactor: _controller.textScaleFactor,
        ),
        InfoCardWidget(
          title: 'Recomendações',
          content: MedicamentoConstants.recomendacoesGerais,
          textScaleFactor: _controller.textScaleFactor,
        ),
        if (medicamento != null && medicamento.administracaoTipica.isNotEmpty)
          InfoCardWidget(
            title: 'Administração Típica',
            content: medicamento.administracaoTipica,
            textScaleFactor: _controller.textScaleFactor,
          ),
      ],
    );
  }

  Widget _buildPrecaucoes() {
    return Column(
      children: [
        SectionHeaderWidget(
          title: 'Precauções',
          textScaleFactor: _controller.textScaleFactor,
        ),
        WarningCardWidget(
          title: 'Atenção',
          content: MedicamentoConstants.avisoImportante,
          textScaleFactor: _controller.textScaleFactor,
        ),
      ],
    );
  }

  Widget _buildCalculadoraDosagem() {
    return Column(
      children: [
        const SizedBox(height: 16),
        DosageCalculatorWidget(
          controller: _controller,
          textScaleFactor: _controller.textScaleFactor,
        ),
      ],
    );
  }
}
