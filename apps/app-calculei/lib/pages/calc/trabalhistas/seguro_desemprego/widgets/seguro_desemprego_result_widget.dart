// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/pages/calc/trabalhistas/seguro_desemprego/widgets/controllers/seguro_desemprego_controller.dart';
import 'package:app_calculei/pages/calc/trabalhistas/seguro_desemprego/widgets/models/seguro_desemprego_model.dart';
import 'package:app_calculei/services/formatting_service.dart';

class SeguroDesempregoResultWidget extends StatelessWidget {
  final SeguroDesempregoController controller;
  final SeguroDesempregoModel model;
  
  const SeguroDesempregoResultWidget({
    super.key,
    required this.controller,
    required this.model,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final formattingService = FormattingService();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status do Direito
        _buildStatusCard(formattingService, isDark),
        
        if (model.temDireito) ...[
          const SizedBox(height: 20),
          
          // Valores
          _buildValoresCard(formattingService, isDark),
          
          const SizedBox(height: 20),
          
          // Prazos
          _buildPrazosCard(formattingService, isDark),
          
          const SizedBox(height: 20),
          
          // Cronograma
          _buildCronogramaCard(formattingService, isDark),
        ],
        
        const SizedBox(height: 24),
        
        // Botão Novo Cálculo
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.limparCampos,
            icon: const Icon(Icons.refresh),
            label: const Text('Novo Cálculo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ShadcnStyle.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusCard(FormattingService formattingService, bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  model.temDireito ? Icons.check_circle : Icons.cancel,
                  color: model.temDireito ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    model.temDireito 
                        ? 'Tem direito ao seguro-desemprego'
                        : 'Não tem direito ao seguro-desemprego',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: model.temDireito ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            
            if (!model.temDireito) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Text(
                  model.motivoSemDireito,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildValoresCard(FormattingService formattingService, bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Valores',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildValueRow(
              'Valor da Parcela',
              formattingService.formatCurrency(model.valorParcela),
              Icons.payments,
              Colors.green,
            ),
            
            const SizedBox(height: 12),
            
            _buildValueRow(
              'Quantidade de Parcelas',
              formattingService.formatParcelas(model.quantidadeParcelas),
              Icons.format_list_numbered,
              Colors.blue,
            ),
            
            const SizedBox(height: 12),
            
            _buildValueRow(
              'Valor Total',
              formattingService.formatCurrency(model.valorTotal),
              Icons.account_balance_wallet,
              Colors.orange,
            ),
            
            const SizedBox(height: 12),
            
            _buildValueRow(
              'Percentual do Salário',
              '${((model.valorParcela / model.salarioMedio) * 100).toStringAsFixed(1)}%',
              Icons.percent,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPrazosCard(FormattingService formattingService, bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prazos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildValueRow(
              'Prazo para Requerer',
              formattingService.formatDate(model.prazoRequerer),
              Icons.schedule,
              Colors.red,
            ),
            
            const SizedBox(height: 12),
            
            _buildValueRow(
              'Início do Pagamento',
              formattingService.formatDate(model.inicioPagamento),
              Icons.play_arrow,
              Colors.green,
            ),
            
            const SizedBox(height: 12),
            
            _buildValueRow(
              'Fim do Pagamento',
              formattingService.formatDate(model.fimPagamento),
              Icons.stop,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCronogramaCard(FormattingService formattingService, bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cronograma de Pagamento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ...model.cronogramaPagamento.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              final isFirst = index == 0;
              final isLast = index == model.cronogramaPagamento.length - 1;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isFirst 
                            ? Colors.green 
                            : isLast 
                                ? Colors.orange 
                                : Colors.blue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}ª Parcela',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            formattingService.formatDate(data),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formattingService.formatCurrency(model.valorParcela),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildValueRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
