// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/style/shadcn_style.dart';
import '../../../../core/themes/manager.dart';
import '../../../widgets/page_header_widget.dart';
import 'controller/dieta_caseira_controller.dart';
import 'widgets/dieta_caseira_input_form.dart';
import 'widgets/dieta_caseira_result_card.dart';

class DietaCaseiraPage extends StatefulWidget {
  const DietaCaseiraPage({super.key});

  @override
  State<DietaCaseiraPage> createState() => _DietaCaseiraPageState();
}

class _DietaCaseiraPageState extends State<DietaCaseiraPage> {
  final _controller = DietaCaseiraController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showInfoDialog() {
    final isDark = ThemeManager().isDark.value;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? ShadcnStyle.backgroundColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: isDark ? Colors.blue.shade300 : Colors.blue,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sobre a Calculadora de Dieta Caseira',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ShadcnStyle.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Informações importantes:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ShadcnStyle.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Esta calculadora permite estimar as necessidades nutricionais para dietas caseiras em cães e gatos.',
                      style: TextStyle(color: ShadcnStyle.textColor),
                    ),
                    const SizedBox(height: 12),
                    _buildBulletPoint(
                        'As dietas caseiras devem ser formuladas adequadamente para garantir que todas as necessidades nutricionais do animal sejam atendidas.'),
                    _buildBulletPoint(
                        'Esta calculadora oferece apenas estimativas gerais. A formulação real de uma dieta caseira deve ser feita por um médico veterinário nutricionista.'),
                    _buildBulletPoint(
                        'Diferentes estágios de vida e condições de saúde requerem diferentes perfis nutricionais.'),
                    _buildBulletPoint(
                        'Sempre inclua suplementações vitamínicas e minerais conforme orientação veterinária.'),
                    const SizedBox(height: 12),
                    Text(
                      'Como usar:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ShadcnStyle.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildNumberedPoint(
                        1, 'Selecione a espécie do seu animal (cão ou gato).'),
                    _buildNumberedPoint(2,
                        'Indique o estado fisiológico (filhote, adulto, idoso, etc.).'),
                    _buildNumberedPoint(
                        3, 'Escolha o nível de atividade do animal.'),
                    _buildNumberedPoint(4,
                        'Selecione o tipo de dieta desejada conforme necessidades específicas.'),
                    _buildNumberedPoint(5,
                        'Informe o peso do animal e a idade (em anos e meses).'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.amber.shade900.withValues(alpha: 0.2)
                            : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? Colors.amber.shade700.withValues(alpha: 0.3)
                              : Colors.amber.shade200,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            color: isDark
                                ? Colors.amber.shade300
                                : Colors.amber.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Nota: Os resultados são aproximações e podem precisar de ajustes baseados na resposta individual do animal. Monitore o peso e a condição corporal regularmente.',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: ShadcnStyle.textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ShadcnStyle.primaryButtonStyle,
                        child: const Text('Fechar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ShadcnStyle.textColor,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: ShadcnStyle.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedPoint(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: ShadcnStyle.textColor,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: ShadcnStyle.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 1120,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DietaCaseiraInputForm(
                        controller: _controller,
                        onCalcular: () {
                          setState(() {});
                        },
                        onLimpar: () {
                          setState(() {});
                        },
                      ),
                      DietaCaseiraResultCard(
                        model: _controller.model,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 16),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: PageHeaderWidget(
            title: 'Calculadora de Dieta Caseira',
            subtitle: 'Planeje a alimentação caseira do seu pet',
            icon: Icons.restaurant,
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: _showInfoDialog,
                tooltip: 'Informações sobre dieta caseira',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
