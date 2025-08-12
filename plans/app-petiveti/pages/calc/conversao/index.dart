// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../widgets/page_header_widget.dart';
import 'controller/conversao_controller.dart';
import 'model/conversao_model.dart';
import 'widgets/conversao_input_form.dart';
import 'widgets/conversao_result_card.dart';

/// Widget principal da calculadora de conversão
class ConversaoPage extends StatefulWidget {
  const ConversaoPage({super.key});

  @override
  State<ConversaoPage> createState() => _ConversaoPageState();
}

class _ConversaoPageState extends State<ConversaoPage> {
  late final ConversaoModel _model;
  late final ConversaoController _controller;

  @override
  void initState() {
    super.initState();
    _model = ConversaoModel();
    _controller = ConversaoController(_model);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    
    // Responsive maxWidth and padding
    final maxWidth = isSmallScreen ? screenWidth * 0.95 : isTablet ? 800.0 : 1120.0;
    final horizontalPadding = isSmallScreen ? 4.0 : 8.0;
    
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(horizontalPadding, 0, horizontalPadding, 0),
              child: Column(
                children: [
                  ConversaoInputForm(
                    controller: _controller,
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _controller.calculadoNotifier,
                    builder: (context, calculado, child) {
                      return ValueListenableBuilder<double?>(
                        valueListenable: _controller.resultadoNotifier,
                        builder: (context, resultado, child) {
                          return ValueListenableBuilder<bool>(
                            valueListenable: _controller.isLoadingNotifier,
                            builder: (context, isLoading, child) {
                              return ConversaoResultCard(
                                controller: _controller,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
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
            title: 'Calculadora de Conversões',
            subtitle: 'Converta unidades de medida facilmente',
            icon: Icons.calculate,
            showBackButton: true,
            actions: [
              IconButton(
                onPressed: () => _showInfoDialog(context),
                icon: const Icon(Icons.info_outline),
                tooltip: 'Informações sobre conversões',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? screenWidth * 0.9 : 500,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calculate,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Calculadora de Conversões',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Como usar',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        '• Digite o valor que deseja converter\n'
                        '• Clique em "Calcular" para ver o resultado\n'
                        '• Use "Limpar" para resetar os campos',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tips_and_updates,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Dica',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Esta calculadora facilita conversões rápidas de unidades para uso em medicina veterinária e nutrição animal.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
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
      },
    );
  }
}
