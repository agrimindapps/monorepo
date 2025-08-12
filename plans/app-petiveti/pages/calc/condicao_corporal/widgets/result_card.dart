// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../controller/condicao_corporal_controller.dart';
import '../services/notification_service.dart';
import '../services/share_service.dart';

class ResultCard extends StatelessWidget {
  final CondicaoCorporalController controller;

  const ResultCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: controller.resultadoNotifier,
      builder: (context, resultado, child) {
        final hasResult = resultado != null;

        return ValueListenableBuilder<bool>(
          valueListenable: controller.isLoadingNotifier,
          builder: (context, isLoading, child) {
            return AnimatedOpacity(
              opacity: hasResult ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Visibility(
                visible: hasResult,
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildResultHeader(context, isLoading),
                        const Divider(thickness: 1),
                        if (isLoading)
                          _buildLoadingState()
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildResultValues(),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: _buildInfoSection(),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResultHeader(BuildContext context, bool isLoading) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Resultado da Avaliação',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ShadcnStyle.textColor,
            ),
          ),
        ),
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: 'Agendar lembrete de reavaliação',
                hint: 'Toque para agendar um lembrete para reavaliar a condição corporal',
                button: true,
                child: IconButton(
                  onPressed: () => _showReminders(context),
                  icon: const Icon(Icons.schedule, size: 20),
                  tooltip: 'Agendar lembrete',
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
              Semantics(
                label: 'Opções de compartilhamento',
                hint: 'Toque para ver diferentes formas de compartilhar o resultado',
                button: true,
                child: IconButton(
                  onPressed: () => _showShareOptions(context),
                  icon: const Icon(Icons.more_vert, size: 20),
                  tooltip: 'Mais opções de compartilhamento',
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
              Semantics(
                label: 'Compartilhar resultado',
                hint: 'Compartilha o resultado da avaliação em formato texto',
                button: true,
                child: TextButton.icon(
                  onPressed: () => _compartilhar(context),
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Compartilhar'),
                  style: ShadcnStyle.primaryButtonStyle,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildResultValues() {
    final isDark = ThemeManager().isDark.value;

    if (controller.resultado == null) return const SizedBox.shrink();

    // Extrair informações do resultado
    final lines = controller.resultado!.split('\n\n');
    final classificacaoLine = lines.isNotEmpty ? lines[0] : '';
    final descricaoLine = lines.length > 1 ? lines[1] : '';
    final recomendacaoLine = lines.length > 2 ? lines[2] : '';

    final classificacao = classificacaoLine.replaceAll('Classificação: ', '');
    final descricao = descricaoLine;
    final recomendacao = recomendacaoLine.replaceAll('Recomendação: ', '');

    // Determinar cor baseada no índice
    Color resultColor = Colors.green;
    IconData resultIcon = Icons.pets;

    if (controller.indiceSelecionado != null) {
      if (controller.indiceSelecionado! <= 3) {
        resultColor = isDark ? Colors.orange.shade300 : Colors.orange;
        resultIcon = Icons.trending_down;
      } else if (controller.indiceSelecionado! >= 6) {
        resultColor = isDark ? Colors.red.shade300 : Colors.red;
        resultIcon = Icons.trending_up;
      } else {
        resultColor = isDark ? Colors.green.shade300 : Colors.green;
        resultIcon = Icons.favorite;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultItem(
            'Condição Corporal',
            'ECC ${controller.indiceSelecionado}/9',
            resultIcon,
            resultColor,
          ),
          const SizedBox(height: 12),
          _buildResultItem(
            'Classificação',
            classificacao,
            Icons.assessment,
            resultColor,
          ),
          const SizedBox(height: 12),
          _buildDescriptionCard(descricao, isDark),
          const SizedBox(height: 12),
          _buildRecommendationCard(recomendacao, isDark),
        ],
      ),
    );
  }

  Widget _buildResultItem(
      String label, String value, IconData icon, Color color) {
    final isDark = ThemeManager().isDark.value;

    return Semantics(
      label: '$label: $value',
      readOnly: true,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: ShadcnStyle.mutedTextColor,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ShadcnStyle.textColor,
                      ),
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

  Widget _buildDescriptionCard(String description, bool isDark) {
    return Card(
      elevation: 0,
      color:
          isDark ? Colors.blue.shade900.withValues(alpha: 0.2) : Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark
              ? Colors.blue.shade700.withValues(alpha: 0.3)
              : Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: isDark ? Colors.blue.shade300 : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Descrição da Condição',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.blue.shade300 : Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: ShadcnStyle.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(String recommendation, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark
          ? Colors.amber.shade900.withValues(alpha: 0.2)
          : Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark
              ? Colors.amber.shade700.withValues(alpha: 0.3)
              : Colors.amber.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recomendação',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color:
                        isDark ? Colors.amber.shade300 : Colors.amber.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              recommendation,
              style: TextStyle(
                fontSize: 14,
                color: ShadcnStyle.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    final isDark = ThemeManager().isDark.value;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? ShadcnStyle.borderColor.withValues(alpha: 0.3)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? ShadcnStyle.borderColor : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Escala ECC:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: ShadcnStyle.textColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildScaleItem('1-3', 'Abaixo do peso', Colors.orange),
          const SizedBox(height: 4),
          _buildScaleItem('4-5', 'Peso ideal', Colors.green),
          const SizedBox(height: 4),
          _buildScaleItem('6-9', 'Acima do peso', Colors.red),
          const SizedBox(height: 12),
          Text(
            'Sempre consulte um veterinário para avaliação completa.',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: ShadcnStyle.mutedTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Semantics(
      label: 'Calculando resultado da avaliação',
      liveRegion: true,
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Calculando resultado...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScaleItem(String range, String description, Color color) {
    final isDark = ThemeManager().isDark.value;

    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isDark ? color.withValues(alpha: 0.7) : color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$range: $description',
            style: TextStyle(
              fontSize: 12,
              color: ShadcnStyle.textColor,
            ),
          ),
        ),
      ],
    );
  }

  void _compartilhar(BuildContext context) {
    ShareService.shareResult(
      context: context,
      controller: controller,
      format: ShareFormat.text,
    );
  }

  void _showShareOptions(BuildContext context) {
    ShareService.showShareOptionsDialog(context, controller);
  }

  void _showReminders(BuildContext context) {
    NotificationService.showReminderDialog(context, controller);
  }
}
