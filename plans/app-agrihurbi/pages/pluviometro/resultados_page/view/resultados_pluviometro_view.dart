// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../widgets/page_header_widget.dart';
import '../controller/resultados_pluviometro_controller.dart';
import '../widgets/controles_widget.dart';
import '../widgets/estatisticas_widget.dart';
import '../widgets/grafico_anual_widget.dart';
import '../widgets/grafico_comparativo_widget.dart';
import '../widgets/grafico_mensal_widget.dart';

class ResultadosPluviometroView extends StatefulWidget {
  const ResultadosPluviometroView({super.key});

  @override
  State<ResultadosPluviometroView> createState() =>
      _ResultadosPluviometroViewState();
}

class _ResultadosPluviometroViewState extends State<ResultadosPluviometroView> {
  late final ResultadosPluviometroController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ResultadosPluviometroController();
    _controller.addListener(_onStateChanged);
    _controller.carregarDadosIniciais();
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {
        // Estado atualizado pelo controller
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 700;
    _controller.updateScreenSize(isSmallScreen);

    return SafeArea(
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(72),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: PageHeaderWidget(
              title: 'Resultados',
              subtitle: 'Visualize relatórios e gráficos',
              icon: Icons.bar_chart_outlined,
              showBackButton: true,
            ),
          ),
        ),
        body: _buildBody(isSmallScreen),
      ),
    );
  }

  Widget _buildBody(bool isSmallScreen) {
    final state = _controller.state;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return _buildErrorView(state.errorMessage!);
    }

    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: isSmallScreen ? double.infinity : 1020,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildControles(),
                const SizedBox(height: 24),
                _buildConteudoPrincipal(isSmallScreen),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar dados',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _controller.clearError();
              _controller.carregarDadosIniciais();
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildControles() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;
        return ControlesWidget(
          pluviometros: state.pluviometros,
          pluviometroSelecionado: state.pluviometroSelecionado,
          tipoVisualizacao: state.tipoVisualizacao,
          anoSelecionado: state.anoSelecionado,
          mesSelecionado: state.mesSelecionado,
          onPluviometroChanged: _controller.selecionarPluviometro,
          onTipoVisualizacaoChanged: _controller.alterarTipoVisualizacao,
          onAnoChanged: _controller.alterarAno,
          onMesChanged: _controller.alterarMes,
        );
      },
    );
  }

  Widget _buildConteudoPrincipal(bool isSmallScreen) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTituloResultados(state.tituloAnalise),
                const SizedBox(height: 16),
                EstatisticasWidget(estatisticas: state.estatisticas),
                const SizedBox(height: 24),
                _buildTituloGrafico(),
                const SizedBox(height: 16),
                _buildGraficoPrincipal(state),
                const SizedBox(height: 16),
                GraficoComparativoWidget(
                  dados: state.dadosComparativos,
                  anoSelecionado: state.anoSelecionado,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTituloResultados(String titulo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTituloGrafico() {
    return const Text(
      'Gráfico de Precipitação',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildGraficoPrincipal(state) {
    return state.tipoVisualizacao == 'Ano'
        ? GraficoAnualWidget(dados: state.dadosPorPeriodo)
        : GraficoMensalWidget(dados: state.dadosPorPeriodo);
  }
}
