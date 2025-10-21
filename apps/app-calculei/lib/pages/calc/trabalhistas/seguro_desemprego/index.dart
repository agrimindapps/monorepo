// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'controllers/seguro_desemprego_controller.dart';
import 'widgets/seguro_desemprego_form_widget.dart';
import 'widgets/seguro_desemprego_result_widget.dart';

class SeguroDesempregoPage extends StatefulWidget {
  const SeguroDesempregoPage({super.key});

  @override
  State<SeguroDesempregoPage> createState() => _SeguroDesempregoPageState();
}

class _SeguroDesempregoPageState extends State<SeguroDesempregoPage> {
  late SeguroDesempregoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SeguroDesempregoController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.green),
            SizedBox(width: 8),
            Text('Seguro-Desemprego'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.grey.shade900, Colors.black]
                : [Colors.grey.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informações principais
              _buildInfoCard(isDark),
              
              const SizedBox(height: 24),
              
              // Formulário e resultado
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    children: [
                      if (!_controller.showResult) ...[
                        // Formulário
                        Card(
                          elevation: 4,
                          color: isDark ? Colors.grey.shade900 : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Dados para Cálculo',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                SeguroDesempregoFormWidget(
                                  controller: _controller,
                                ),
                                
                                const SizedBox(height: 24),
                                
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _controller.isCalculating 
                                        ? null 
                                        : _controller.calcular,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ShadcnStyle.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: _controller.isCalculating
                                        ? const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text('Calculando...'),
                                            ],
                                          )
                                        : const Text(
                                            'Calcular Seguro-Desemprego',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // Resultado
                        if (_controller.model != null)
                          SeguroDesempregoResultWidget(
                            controller: _controller,
                            model: _controller.model!,
                          ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: ShadcnStyle.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Sobre o Seguro-Desemprego',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildInfoItem(
              'Quem tem direito',
              'Trabalhadores com carteira assinada demitidos sem justa causa',
              Icons.person,
            ),
            
            const SizedBox(height: 8),
            
            _buildInfoItem(
              'Carência',
              '12 meses (1ª vez), 9 meses (2ª vez), 6 meses (demais)',
              Icons.schedule,
            ),
            
            const SizedBox(height: 8),
            
            _buildInfoItem(
              'Prazo para requerer',
              'Até 120 dias após a demissão',
              Icons.warning,
            ),
            
            const SizedBox(height: 8),
            
            _buildInfoItem(
              'Parcelas',
              'De 3 a 5 parcelas conforme tempo trabalhado',
              Icons.payments,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre o Seguro-Desemprego'),
        content: const Text(
          'Esta calculadora verifica o direito ao seguro-desemprego:\n\n'
          '• Tempo de trabalho mínimo conforme histórico\n'
          '• Valor das parcelas baseado no salário médio\n'
          '• Quantidade de parcelas conforme legislação\n'
          '• Cronograma de pagamentos\n'
          '• Prazos para requerimento\n\n'
          'Valores baseados na legislação de 2024.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
