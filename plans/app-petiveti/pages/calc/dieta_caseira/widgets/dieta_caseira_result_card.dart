// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../model/dieta_caseira_model.dart';

class DietaCaseiraResultCard extends StatelessWidget {
  final DietaCaseiraModel model;

  const DietaCaseiraResultCard({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasResult =
        model.necessidadeCalorica != null && model.macronutrientes != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 300),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header responsivo
                isSmallScreen
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: hasResult
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  hasResult ? Icons.check_circle : Icons.pets,
                                  color:
                                      hasResult ? Colors.green : Colors.orange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Resultados da Dieta Caseira',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (hasResult) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                onPressed: () => _shareResult(),
                                icon: const Icon(Icons.share),
                                tooltip: 'Compartilhar resultado',
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      colorScheme.primary.withValues(alpha: 0.1),
                                  foregroundColor: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: hasResult
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              hasResult ? Icons.check_circle : Icons.pets,
                              color: hasResult ? Colors.green : Colors.orange,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Resultados da Dieta Caseira',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (hasResult)
                            IconButton(
                              onPressed: () => _shareResult(),
                              icon: const Icon(Icons.share),
                              tooltip: 'Compartilhar resultado',
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    colorScheme.primary.withValues(alpha: 0.1),
                                foregroundColor: colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                if (hasResult) ...[
                  _buildNecessidadesCaloricasSection(),
                  const SizedBox(height: 16),
                  _buildMacronutrientesSection(),
                  const SizedBox(height: 16),
                  _buildAlimentosSection(),
                  const SizedBox(height: 16),
                  _buildRecomendacoesSection(),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.pets,
                          size: 48,
                          color: Colors.grey.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aguardando cálculo...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Preencha os campos acima e clique em "Calcular"',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNecessidadesCaloricasSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.blue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: Colors.blue,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Necessidades Energéticas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${model.necessidadeCalorica!.toStringAsFixed(0)} kcal/dia',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Necessidade calórica diária',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacronutrientesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: Colors.green,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Macronutrientes Recomendados (diários)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMacronutrienteRow(
            'Proteína',
            model.macronutrientes!['Proteína']!,
            Colors.green,
          ),
          const SizedBox(height: 8),
          _buildMacronutrienteRow(
            'Gordura',
            model.macronutrientes!['Gordura']!,
            Colors.orange,
          ),
          const SizedBox(height: 8),
          _buildMacronutrienteRow(
            'Carboidratos',
            model.macronutrientes!['Carboidratos']!,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildMacronutrienteRow(String nome, double valor, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: cor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: cor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                nome,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: cor,
                ),
              ),
            ],
          ),
          Text(
            '${valor.toStringAsFixed(1)} g',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlimentosSection() {
    if (model.quantidadesAlimentos == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.restaurant,
                color: Colors.orange,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Quantidades Sugeridas de Alimentos (diárias)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Estas são quantidades aproximadas e podem precisar de ajustes.',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.orange.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          ...model.quantidadesAlimentos!.entries.map((entry) {
            return _buildAlimentoRow(entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildAlimentoRow(String alimento, double quantidade) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              alimento,
              style: TextStyle(
                fontSize: 15,
                color: Colors.orange.withValues(alpha: 0.9),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${quantidade.toStringAsFixed(0)} g',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.orange.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecomendacoesSection() {
    if (model.recomendacoes == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.purple,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Recomendações',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRecomendacaoItem(
            model.recomendacoes!['geral']!,
            Icons.info_outline,
            Colors.blue,
          ),
          const SizedBox(height: 8),
          if (model.recomendacoes!['especie'] != null)
            _buildRecomendacaoItem(
              model.recomendacoes!['especie']!,
              Icons.pets,
              Colors.orange,
            ),
        ],
      ),
    );
  }

  Widget _buildRecomendacaoItem(String texto, IconData icone, Color cor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: cor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: cor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: cor.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareResult() {
    if (model.necessidadeCalorica == null || model.macronutrientes == null) {
      return;
    }

    final especie = model.especieSelecionada ?? '';
    final estadoFisiologico = model.estadoFisiologicoSelecionado ?? '';
    final peso = model.peso?.toString() ?? '';
    final necessidadeCalorica = model.necessidadeCalorica!.toStringAsFixed(0);
    final proteina = model.macronutrientes!['Proteína']!.toStringAsFixed(1);
    final gordura = model.macronutrientes!['Gordura']!.toStringAsFixed(1);
    final carboidratos =
        model.macronutrientes!['Carboidratos']!.toStringAsFixed(1);

    String alimentos = '';
    if (model.quantidadesAlimentos != null) {
      alimentos = model.quantidadesAlimentos!.entries
          .map((entry) => '• ${entry.key}: ${entry.value.toStringAsFixed(0)}g')
          .join('\n');
    }

    Share.share(
      'Cálculo de Dieta Caseira 🐕🐱\n\n'
      'Espécie: $especie\n'
      'Estado: $estadoFisiologico\n'
      'Peso: $peso kg\n\n'
      '🔥 Necessidade Calórica: $necessidadeCalorica kcal/dia\n\n'
      '📊 Macronutrientes (diários):\n'
      '• Proteína: ${proteina}g\n'
      '• Gordura: ${gordura}g\n'
      '• Carboidratos: ${carboidratos}g\n\n'
      '🍖 Alimentos sugeridos:\n'
      '$alimentos\n\n'
      '⚠️ Consulte sempre um veterinário nutricionista!\n\n'
      '📱 Calculado com fNutriTuti',
      subject: 'Cálculo de Dieta Caseira',
    );
  }
}
